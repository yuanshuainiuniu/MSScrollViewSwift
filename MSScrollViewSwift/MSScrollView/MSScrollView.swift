//
//  MSScrollView.swift
//  lyfSwift
//
//  Created by Marshal on 2017/7/10.
//  Copyright © 2017年 Marshal. All rights reserved.
//

import UIKit

enum MSCycleDirection :Int{
    case MSCycleDirectionHorizontal
    case MSCycleDirectionVertical
}
enum MSPageControlDirection :Int{
    case MSPageControl_Center
    case MSPageControl_Left
    case MSPageControl_Right
}
class MSScrollView: UIView,UIScrollViewDelegate,UIGestureRecognizerDelegate {
    var isAutoPlay :Bool = false{
        didSet{
            commoninit()
        }
    }
    var pageControl : CustomerPageControl?
    var timeInterval:TimeInterval = 0.0{
        didSet{
            commoninit()
        }
    }
    var pageControlOffset :UIOffset = UIOffset.zero{
        didSet{
            addPageControl()
        }
    }
    var scrollView : UIScrollView!
    var currentPage:Int = 0
    
    var direction :MSCycleDirection = MSCycleDirection.MSCycleDirectionHorizontal{
        didSet{
            commoninit()
        }
    }
    var images = [UIImage]()
    var pageControlDir :MSPageControlDirection = MSPageControlDirection.MSPageControl_Center{
        didSet{
            addPageControl()
        }
    }
    var placeholderImage :String?
    
    
    
    private var AutoTimer :Timer?
    
    var firstImageView :UIImageView!
    var secondImageView :UIImageView!
    var threeImageView :UIImageView!
    var tapGestureRecognizer :UITapGestureRecognizer?
    var downloadTaskArray = [URLSessionDownloadTask]()
    
    var imageNames : [String] = []{
        didSet(value){
            initImages(value, fromUrl: false)
        }
    }
    
    var urlImages : [String] = []{
        willSet(value){
            initImages(value, fromUrl: true)
        }
    }
    
    func ImageView() -> UIImageView {
        let imagv = UIImageView()
        imagv.contentMode = UIViewContentMode.scaleAspectFill;
      
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
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func addScrollView() -> Void {
        if scrollView == nil {
            scrollView = UIScrollView()
            scrollView.backgroundColor = UIColor.red
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
            firstImageView.frame = self.frame
            secondImageView.frame = CGRect.init(x: width, y: 0, width: width, height: height)
            threeImageView.frame = CGRect.init(x: width*2, y: 0, width: width, height: height)
            scrollView.contentSize = CGSize.init(width: self.frame.size.width * 3, height: self.frame.size.height)
        }else if direction == MSCycleDirection.MSCycleDirectionVertical{
            firstImageView.frame = self.frame
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
    func initImages(_ _images:[String],fromUrl:Bool) -> Void {
        DispatchQueue.main.async {
            self.images = []
            self.cancleAllTask()
            if fromUrl{
                for _ in 0..<_images.count{
                    let placeHold = UIImage.init(named: self.placeholderImage ?? "MSSource.bundle/def.jpg")
                    self.images.append(placeHold ?? UIImage())
                }
                for (idx,value) in _images.enumerated(){
                    self.downLoadImageWithURL(URL.init(string: value)!, success: {[unowned self] (image:UIImage?, url:URL?) in
                        if image != nil{
                            let arange = Range(idx..<(idx+1))
                            self.images.replaceSubrange(arange, with: [image!])
                            DispatchQueue.main.async {
                                self.commoninit()
                            }
                        }
                    })
                }
                
            }else{
                for imageName in _images{
                    self.images.append(UIImage.init(named: imageName)!)
                }
            }
        }
    }
    
    func downLoadImageWithURL(_ url:URL ,success:@escaping ((_ image:UIImage,_ url:URL)->())) {
        let path = getCachePatch() 
        let fileManage = FileManager.default
        if !fileManage .fileExists(atPath: path) {
          try? fileManage.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        let cachePatch = (path as NSString).appendingPathComponent(url.absoluteString.ms.md5)
        if fileManage .fileExists(atPath: cachePatch) {
            if let image = UIImage.init(contentsOfFile: cachePatch){
                success(image,url)
            }
        }else{
            let sessionConfiguration = URLSessionConfiguration.default
            sessionConfiguration.timeoutIntervalForRequest = 15
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 6
            let session = URLSession.init(configuration: sessionConfiguration, delegate: nil, delegateQueue: queue)
            let downloadTask = session.downloadTask(with: url, completionHandler: { (location:URL?, respone:URLResponse?, error:Error?) in
                if error == nil{
                    let toPath = (path as NSString).appendingPathComponent(url.absoluteString.ms.md5)
                    try? fileManage.moveItem(atPath: (location?.path)!, toPath: toPath)
                    if let image = UIImage.init(contentsOfFile: toPath){
                        success(image,(respone?.url)!)
                    }
//                    for (idx,value) in self.downloadTaskArray.enumerated(){
//                        if value == downloadTask{
//                            
//                        }
//                    }
                    
                }
            })
            downloadTask.resume()
            self.downloadTaskArray.append(downloadTask)
            
        }
        
        
    }
    
    func cancleAllTask() -> Void {
        for task in self.downloadTaskArray {
            task.cancel()
        }
        self.downloadTaskArray.removeAll()
    }
    func singleTapGestureRecognizer() -> Void {
        
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            return false
        }
        return true
    }
    func addTimer() -> Void {
        self.removeTimer()
        AutoTimer = Timer.scheduledTimer(timeInterval: timeInterval > 0 ? timeInterval : 2.5, target: self, selector: #selector(MSScrollView.autoShowNextImage), userInfo: nil, repeats: true)
        RunLoop.main.add(AutoTimer!, forMode: RunLoopMode.commonModes)
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
            self.firstImageView.image = images.last
            self.secondImageView.image = images[currentPage]
            if images.count == 1 {
                self.threeImageView.image = images.last
            }else{
                self.threeImageView.image = images[currentPage + 1]
            }
        }else if currentPage == (images.count) - 1{
            self.firstImageView.image = images[currentPage - 1]
            self.secondImageView.image = images[currentPage]
            self.threeImageView.image = images.first
        }else{
            self.firstImageView.image = images[currentPage - 1]
            self.secondImageView.image = images[currentPage]
            self.threeImageView.image = images[currentPage + 1]
        }
        pageControl?.currentPage = currentPage
        if self.direction == MSCycleDirection.MSCycleDirectionHorizontal {
            scrollView.setContentOffset(CGPoint.init(x: self.frame.size.width, y: 0), animated: false)
        }else{
            scrollView.setContentOffset(CGPoint.init(x: 0, y: self.frame.size.height), animated: false)
        }
    }
    func autoShowNextImage() -> Void {
        if self.direction == MSCycleDirection.MSCycleDirectionHorizontal {
            scrollView.setContentOffset(CGPoint.init(x: self.frame.size.width*2, y: 0), animated: true)
        }else{
            scrollView.setContentOffset(CGPoint.init(x: 0, y: self.frame.size.height*2), animated: true)
        }
    }
    override func layoutSubviews() {
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
            pageControl?.currentPageIndicatorTintColor = UIColor.purple
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        playImages()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.removeTimer()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
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
            if x >= self.frame.size.width * 2{
                if currentPage == (images.count) - 1 {
                    currentPage = 0;
                }else{
                    currentPage += 1
                }
                self.reloadData()
            }
        }else{
            let y = scrollView.contentOffset.y
            //up
            if y > self.frame.size.height {
                
                if currentPage == (images.count) - 1 {
                    currentPage = 0
                }else{
                    currentPage += 1
                }
                self.reloadData()
            }
            //down
            if y < self.frame.size.height {
                if currentPage - 1 < 0 {
                    currentPage = (images.count) - 1
                }else{
                    currentPage -= 1
                }
                self.reloadData()
            }
        }
    }
    func getCachePatch() -> String {
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
        let box = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as! String + ".MSCache"
        
        return docPath.appendingPathComponent(box)
    }
    func clearCache() -> Void {
        
        let path = getCachePatch()
        
        let fileManage = FileManager.default
        if fileManage .fileExists(atPath: path) {
           try? fileManage.removeItem(atPath: path)
        }
        
    }
}


