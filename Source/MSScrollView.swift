//
//  MSScrollView.swift
//  lyfSwift
//
//  Created by Marshal on 2017/7/10.
//  Copyright © 2017年 Marshal. All rights reserved.
//

import UIKit

public enum MSCycleDirection :Int{
    case MSCycleDirectionHorizontal
    case MSCycleDirectionVertical
}
public enum MSPageControlDirection :Int{
    case MSPageControl_Center
    case MSPageControl_Left
    case MSPageControl_Right
}
@objc public protocol MSScrollViewDelegate:NSObjectProtocol{
    
    @objc optional func MSScrollViewSelected(_ msScrollView:MSScrollView,didSelectPage:NSInteger)
    @objc optional func MSScrollViewDidAppear(_ msScrollView:MSScrollView,currentPage:NSInteger)
}
public class MSImageModel:NSObject{
    //占位图
    public var image:UIImage?
    //链接图
    public var url:String?
    //过渡动画
    public var animated = true
    //图片显示模式
    public var contentMode:UIView.ContentMode = .scaleAspectFill
    //是否是本地图片
    fileprivate var isLocal = true
}
public class MSScrollView: UIView,UIScrollViewDelegate,UIGestureRecognizerDelegate, URLSessionDelegate {
   public var isAutoPlay :Bool = false{
        didSet{
            commoninit()
        }
    }
   public weak var delegate:MSScrollViewDelegate?
    
    private let MSScrollView_expire = "MSScrollView_expire"
    /// 缓存时长，单位s
    public var expireTimeInterval:TimeInterval?{
        didSet{
            //设置缓存时长
            guard let expireTime = expireTimeInterval else { return  }
            //清理过期缓存
            DispatchQueue.main.async {
                var temp = self.cacheExpireDict
                for (key,value) in  temp{
                    let path = (self.msCachePath as NSString).appendingPathComponent(key)
                    let fileManager = FileManager.default
                    if Date().timeIntervalSince1970 > value + expireTime {
                        if fileManager.fileExists(atPath: path) {
                          try?fileManager.removeItem(atPath: path)
                            temp.removeValue(forKey: path)
                        }
                        
                    }
                }
                //线程安全
                if let data = try?JSONSerialization.data(withJSONObject: temp, options: JSONSerialization.WritingOptions.fragmentsAllowed) {
                    try?data.write(to: URL(fileURLWithPath: self.expirePath))
                }
                
            }
            
            
        }
    }
   public var pageControl : CustomerPageControl?
   public var timeInterval:TimeInterval = 0.0{
        didSet{
            commoninit()
        }
    }
   public var pageControlOffset :UIOffset = UIOffset.zero{
        didSet{
            addPageControl()
        }
    }
    
    
   public var direction :MSCycleDirection = MSCycleDirection.MSCycleDirectionHorizontal{
        didSet{
            commoninit()
        }
    }
   private var images = [MSImageModel]()
   public var pageControlDir :MSPageControlDirection = MSPageControlDirection.MSPageControl_Center{
        didSet{
            addPageControl()
        }
    }
    //后台停用定时器
    public var stopPlayInBackGround = true
    
    public var imageModels : [MSImageModel] = []{
        didSet{
            initImages(imageModels)
        }
    }
    
    var scrollView : UIScrollView!
    var currentPage:Int = 0
    var lastPage:Int = -1
    
    private var AutoTimer :Timer?
    
    var firstImageView :UIImageView!
    var secondImageView :UIImageView!
    var threeImageView :UIImageView!
    var tapGestureRecognizer :UITapGestureRecognizer?
    var downloadTaskArray = [URLSession]()
    
   
    
    func ImageView() -> UIImageView {
        let imagv = UIImageView()
        imagv.contentMode = UIView.ContentMode.scaleAspectFill;
      
        imagv.isUserInteractionEnabled = true;
        imagv.layer.masksToBounds = true;
        return imagv;
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        firstImageView = self.ImageView()
        secondImageView = self.ImageView()
        threeImageView = self.ImageView()
        self.commoninit()
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    @objc func enterBackground(){
        if stopPlayInBackGround{
            removeTimer()
        }
    }
    @objc func enterForground(){
        if self.isAutoPlay && stopPlayInBackGround{
            addTimer()
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func addScrollView() -> Void {
        if scrollView == nil {
            scrollView = UIScrollView()
            scrollView.delegate = self
            scrollView.isPagingEnabled = true
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.scrollsToTop = false
            scrollView.bounces = false
        }
        scrollView.frame = self.bounds
        let width = self.frame.size.width
        let height = self.frame.size.height
        scrollView.addSubview(firstImageView)
        scrollView.addSubview(secondImageView)
        scrollView.addSubview(threeImageView)
        
        if direction == MSCycleDirection.MSCycleDirectionHorizontal {
            firstImageView.frame = CGRect.init(x: 0, y: 0, width: width, height: height)
            secondImageView.frame = CGRect.init(x: width, y: 0, width: width, height: height)
            threeImageView.frame = CGRect.init(x: width*2, y: 0, width: width, height: height)
            scrollView.contentSize = CGSize.init(width: self.frame.size.width * 3, height: self.frame.size.height)
        }else if direction == MSCycleDirection.MSCycleDirectionVertical{
            firstImageView.frame = CGRect.init(x: 0, y: 0, width: width, height: height)
            secondImageView.frame = CGRect.init(x: 0, y: height, width: width, height: height)
            threeImageView.frame = CGRect.init(x: 0, y: height*2, width: width, height: height)
            scrollView.contentSize = CGSize.init(width: self.frame.size.width, height: self.frame.size.height * 3)
        }
        if tapGestureRecognizer == nil {
            tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(MSScrollView.singleTapGestureRecognizer))
            tapGestureRecognizer?.numberOfTapsRequired = 1
            tapGestureRecognizer?.delegate = self
        }
        scrollView.addGestureRecognizer(tapGestureRecognizer!)
        self.addSubview(scrollView)
        if self.isAutoPlay {
            addTimer()
        }else{
            removeTimer()
        }
        
        
    }
    func initImages(_ images:[MSImageModel]) -> Void {
        DispatchQueue.main.async {
            self.images = images
            self.cancleAllTask()
            self.commoninit()
            for (idx,model) in images.enumerated(){
                let tempM = model
                if var url = tempM.url {
                    url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    self.downLoadImageWithURL(URL(string: url), success: {[weak self] (image:UIImage, url:URL,fromCache:Bool) in
                        tempM.image = image
                        tempM.isLocal = fromCache
                        self?.images.replaceSubrange(idx..<idx+1, with: [tempM])
                        DispatchQueue.main.async {
                            self?.commoninit()
                        }
                    })
                }
            }
        }
    }
    lazy var downloadQueue:OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10
        return queue
    }()
    
    lazy var expirePath:String = {
        return (msCachePath as NSString).appendingPathComponent("expireTime")
    }()
    lazy var cacheExpireDict:[String:Double] = {
        guard let cache = try? JSONSerialization.jsonObject(with: Data.init(contentsOf: URL(fileURLWithPath: expirePath)), options: JSONSerialization.ReadingOptions.fragmentsAllowed) as? [String:Double] else {
            return [String:Double]()
        }
        return cache
    }()
    func downLoadImageWithURL(_ url:URL? ,success:@escaping ((_ image:UIImage,_ url:URL,_ fromCache:Bool)->())) {
        guard let url = url else { return }
        let path = msCachePath
        let fileManage = FileManager.default
        if !fileManage .fileExists(atPath: path) {
          try? fileManage.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    
        }
        let fileName = url.absoluteString.ms_md5
        let cachePatch = (path as NSString).appendingPathComponent(fileName)
        if fileManage .fileExists(atPath: cachePatch) {
            let semaphore = DispatchSemaphore(value: 1)
            semaphore.wait()
            if let image = UIImage.init(contentsOfFile: cachePatch){
                success(image,url,true)
            }else{//图片加载失败清缓存
                try? fileManage.removeItem(atPath: cachePatch)
            }
            semaphore.signal()
        }else{
            let sessionConfiguration = URLSessionConfiguration.default
            sessionConfiguration.timeoutIntervalForRequest = 15
            
            let session = URLSession.init(configuration: sessionConfiguration, delegate: self, delegateQueue: downloadQueue)
            session.downloadTask(with: url, completionHandler: {(location:URL?, respone:URLResponse?, error:Error?) in
                session.finishTasksAndInvalidate()
                if error == nil{
                    do {
                        let semaphore = DispatchSemaphore(value: 1)
                        semaphore.wait()
                        try fileManage.moveItem(atPath: (location?.path)!, toPath: cachePatch)
                        if let image = UIImage.init(contentsOfFile: cachePatch){
                            success(image,url,false)
                            self.cacheExpireDict[fileName] = NSDate().timeIntervalSince1970
                            if let data = try? JSONSerialization.data(withJSONObject: self.cacheExpireDict, options: JSONSerialization.WritingOptions.fragmentsAllowed) {
                                try data.write(to: URL(fileURLWithPath: self.expirePath))
                            }
                        }
                        semaphore.signal()
                    } catch {
                        
                    }
                    
                }
                
            }).resume()
            self.downloadTaskArray.append(session)
            
        }
        
        
    }
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        DispatchQueue.main.async {
            self.downloadTaskArray.removeAll(where: {$0 == session})
        }
        
    }
    
    func cancleAllTask() -> Void {
        for session in self.downloadTaskArray {
            session.invalidateAndCancel()
        }
        self.downloadTaskArray.removeAll()
    }
    @objc func singleTapGestureRecognizer() -> Void {
        delegate?.MSScrollViewSelected?(self, didSelectPage: currentPage)
    }
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            return false
        }
        return true
    }
    func addTimer() -> Void {
        self.removeTimer()
        AutoTimer = Timer.scheduledTimer(timeInterval: timeInterval > 0 ? timeInterval : 2.5, target: self, selector: #selector(MSScrollView.autoShowNextImage), userInfo: nil, repeats: true)
        RunLoop.main.add(AutoTimer!, forMode: .common)
    }
    func removeTimer() -> Void {
        if AutoTimer != nil {
            AutoTimer?.invalidate()
            AutoTimer = nil
        }
    }
    func reloadData() -> Void {
        if (images.count) <= 0 {
            return
        }
        if currentPage == 0 {
            self.firstImageView.fillImageModel(images.last)
            self.secondImageView.fillImageModel(images[currentPage])
            if images.count == 1 {
                self.threeImageView.fillImageModel(images.last)
            }else{
                self.threeImageView.fillImageModel(images[currentPage + 1])
            }
        }else if currentPage == (images.count) - 1{
            self.firstImageView.fillImageModel(images[currentPage - 1])
            self.secondImageView.fillImageModel(images[currentPage])
            self.threeImageView.fillImageModel(images.first)
        }else{
            self.firstImageView.fillImageModel(images[currentPage - 1])
            self.secondImageView.fillImageModel(images[currentPage])
            self.threeImageView.fillImageModel(images[currentPage + 1])
        }
        pageControl?.currentPage = currentPage
        if self.direction == MSCycleDirection.MSCycleDirectionHorizontal {
            scrollView.setContentOffset(CGPoint.init(x: self.frame.size.width, y: 0), animated: false)
        }else{
            scrollView.setContentOffset(CGPoint.init(x: 0, y: self.frame.size.height), animated: false)
        }
        if lastPage != currentPage {
            lastPage = currentPage
            delegate?.MSScrollViewDidAppear?(self, currentPage: currentPage)
        }

    }
    @objc func autoShowNextImage() -> Void {
        if self.direction == MSCycleDirection.MSCycleDirectionHorizontal {
            scrollView.setContentOffset(CGPoint.init(x: self.frame.size.width*2, y: 0), animated: true)
        }else{
            scrollView.setContentOffset(CGPoint.init(x: 0, y: self.frame.size.height*2), animated: true)
        }
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        commoninit()
    }
    func commoninit() -> Void {
        currentPage = 0
        addScrollView()
        addPageControl()
        reloadData()
    }
    let kPageHeight:CGFloat = 8.0
    func addPageControl() -> Void {
        if pageControl == nil {
            pageControl = CustomerPageControl()
            pageControl?.pageIndicatorTintColor = UIColor.init(white: 0.7, alpha: 0.5)
            pageControl?.isUserInteractionEnabled = false
        }
        pageControl?.numberOfPages = (images.count)
        
        if pageControlDir == MSPageControlDirection.MSPageControl_Center {
            pageControl?.frame = CGRect.init(x: (self.frame.size.width - (pageControl?.frame.size.width)!)/2, y: self.frame.size.height - kPageHeight - (pageControlOffset.vertical) - 1, width: self.frame.size.width - (pageControlOffset.horizontal), height: kPageHeight)
        }else if pageControlDir == MSPageControlDirection.MSPageControl_Left{
            pageControl?.frame = CGRect.init(x: (pageControlOffset.horizontal), y: self.frame.size.height - kPageHeight - (pageControlOffset.vertical) - 1, width: self.frame.size.width - (pageControlOffset.horizontal), height: kPageHeight)
        }else if pageControlDir == MSPageControlDirection.MSPageControl_Right{
            pageControl?.frame = CGRect.init(x: (pageControlOffset.horizontal) + self.frame.size.width - (pageControl?.frame.size.width)!, y: self.frame.size.height - kPageHeight - (pageControlOffset.vertical) - 1, width: self.frame.size.width - (pageControlOffset.horizontal), height: kPageHeight)
        }
        addSubview(pageControl!)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        playImages()
    }
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.removeTimer()
    }
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.isAutoPlay {
            self.addTimer()
        }
    }
    func playImages() -> Void {
        if direction == MSCycleDirection.MSCycleDirectionHorizontal {
            let x = scrollView.contentOffset.x;
            
            //往前翻
            if x <= 0  {
                if currentPage - 1 < 0 {
                    currentPage = (images.count) - 1;
                }else{
                    currentPage -= 1
                }
                self.reloadData()
            }
            
            //往后翻
            if x >= floor(self.frame.size.width * 2){
                if currentPage == (images.count) - 1 {
                    currentPage = 0;
                }else{
                    currentPage += 1
                }
                self.reloadData()
            }
        }else{
            let y = scrollView.contentOffset.y
            if y <= 0 {
                if currentPage - 1 < 0 {
                    currentPage = (images.count) - 1
                }else{
                    currentPage -= 1
                }
                self.reloadData()
                
            }
            if y >= floor(self.frame.size.height * 2) {
                if currentPage == (images.count) - 1 {
                    currentPage = 0
                }else{
                    currentPage += 1
                }
                self.reloadData()
            }
            
        }

    }
    lazy var msCachePath:String = {
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
        let box = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as! String + ".MSCache"
        
        return docPath.appendingPathComponent(box)
    }()
    @objc public func clearCache() -> Void {
        
        let path = msCachePath
        
        let fileManage = FileManager.default
        if fileManage .fileExists(atPath: path) {
           try? fileManage.removeItem(atPath: path)
        }
        
    }
}
fileprivate extension UIImageView{
    func fillImageModel(_ model:MSImageModel?) {
        if let model = model,model.animated && !model.isLocal {
            model.isLocal = true
            let transition = CATransition()
            transition.type = .fade
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.layer.add(transition, forKey: "animated")
        }
        if let mode = model,mode.contentMode.rawValue != self.contentMode.rawValue {
            self.contentMode = mode.contentMode
        }
        self.image = model?.image
        
    }
}

