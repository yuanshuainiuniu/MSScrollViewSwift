//
//  ViewController.swift
//  MSScrollViewSwift
//
//  Created by Marshal on 2017/7/11.
//  Copyright © 2017年 Marshal. All rights reserved.
//

import UIKit

class ViewController: UIViewController,MSScrollViewDelegate {
    
    func MSScrollViewSelected(_ msScrollView: MSScrollView, didSelectPage: NSInteger) {
        print(didSelectPage)

    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let urlArr = ["http://b.hiphotos.baidu.com/image/pic/item/4610b912c8fcc3ce5254cb2e9045d688d43f2012.jpg",
                      "http://e.hiphotos.baidu.com/image/pic/item/f31fbe096b63f624d7f185648544ebf81a4ca32d.jpg",
                      "http://fs.test.ztosys.com/fs3/M00/75/46/CgkkEGDixWOIVDAuAA90UTqzimgAAAARwFt0h0AD3Rp498.jpg",
                      "https://fscdn.zto.com/fs8/M02/C8/CB/wKhBEGDjxTiAU8WpAAPdRHxn8tM103.png"]
        let msScrollView = MSScrollView()
        msScrollView.backgroundColor = UIColor.yellow
        msScrollView.frame = CGRect.init(x: 0, y: 100, width: self.view.frame.size.width, height: 200)
        msScrollView.isAutoPlay = true
        msScrollView.timeInterval = 5
        msScrollView.expireTimeInterval = 0
        msScrollView.pageControlOffset = UIOffset.init(horizontal: -5, vertical: 5)
        msScrollView.pageControlDir = MSPageControlDirection.MSPageControl_Center
        msScrollView.pageControl?.currentPageIndicatorTintColor = UIColor.orange
//        msScrollView.clearCache()
//        msScrollView.direction = .MSCycleDirectionVertical
        self.view.addSubview(msScrollView)
        
        var modelArr = [MSImageModel]()
        
        for url in urlArr {
            let m = MSImageModel()
            m.url = url
            m.image = #imageLiteral(resourceName: "WechatIMG7")
            modelArr.append(m)
        }
        
        msScrollView.imageModels = modelArr
        msScrollView.delegate = self
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            msScrollView.expireTimeInterval = 0
            msScrollView.imageModels = modelArr
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

