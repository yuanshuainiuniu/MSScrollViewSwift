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
                      "xxx",
                      "http://e.hiphotos.baidu.com/image/pic/item/7a899e510fb30f241e175064ca95d143ac4b0e3c3.jpg"]
        let msScrollView = MSScrollView()
        msScrollView.backgroundColor = UIColor.yellow
        msScrollView.frame = CGRect.init(x: 0, y: 100, width: self.view.frame.size.width, height: 200)
        msScrollView.isAutoPlay = false
        msScrollView.timeInterval = 8
        msScrollView.pageControlOffset = UIOffset.init(horizontal: -5, vertical: 5)
        msScrollView.pageControlDir = MSPageControlDirection.MSPageControl_Center
        self.view.addSubview(msScrollView)
        msScrollView.urlImages = urlArr
        msScrollView.delegate = self
        msScrollView.pageControl?.currentPageIndicatorTintColor = UIColor.orange
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

