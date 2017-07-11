//
//  CustomerPageControl.swift
//  lyfSwift
//
//  Created by Marshal on 2017/7/10.
//  Copyright © 2017年 Marshal. All rights reserved.
//

import UIKit

class CustomerPageControl: UIView {
    var currentPageView :UIView?
    var pageBackColor = UIColor.init(white: 1, alpha: 0.3)
    
    var numberOfPages :NSInteger = 0{
        didSet(value){
            self.frame.size = CGSize.init(width: CGFloat((value + 1))*margin + self.frame.size.height * CGFloat(value), height: self.frame.size.height)
            
            while self.subviews.count > 0{
                self.subviews.last?.removeFromSuperview()
            }
            for index in 0..<value{
                let page = UIView()
                page.layer.masksToBounds = true
                page.layer.borderColor = UIColor.lightGray.cgColor
                page.layer.borderWidth = 0.8
                page.backgroundColor = pageBackColor
                self.addSubview(page)
                if index == 0 {
                    currentPageView = page
                    currentPageView?.backgroundColor = UIColor.orange
                }
            }
        }
    }
    var margin:CGFloat = 5.0
    
    var currentPage : NSInteger = 0{
        didSet(value){
            self.setCurrentPage(value, withAnimation: false)
        }
    }
    var pageIndicatorTintColor : UIColor = UIColor.gray
    var currentPageIndicatorTintColor : UIColor = UIColor.white
    var pageWidth : CGFloat?
    
    func setCurrentPage(_ currentPage:NSInteger,withAnimation animation:Bool) -> Void {
        if animation {
            let transition = CATransition()
            transition.type = kCATransitionPush;
            transition.duration = 0.2;
            transition.isRemovedOnCompletion = true;
            transition.subtype = currentPage<self.currentPage ? kCATransitionFromRight : kCATransitionFromLeft;
            currentPageView?.layer.add(transition, forKey: "transition")
        }
        if self.currentPage < self.subviews.count {
            self.currentPageView?.backgroundColor = pageBackColor
            self.currentPageView?.layer.borderColor = UIColor.lightGray.cgColor;
            self.currentPageView?.layer.borderWidth = 0.8
            
            let page = self.subviews[currentPage]
            page.backgroundColor = UIColor.orange
            page.layer.borderWidth = 0.0
            self.currentPageView = page;
        }
    }
    func updateCurrentPageDisplay() -> Void {
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let count = self.subviews.count
        let height = self.frame.size.height
        
        for idx in 0..<count {
            let idxx = CGFloat(idx)
            let page = self.subviews[idx]
            let x = idxx * height + (idxx + 1) * margin
            let width = height
            page.frame = CGRect.init(x: x, y: page.frame.origin.y, width: width, height: height)
            page.layer.cornerRadius = min(width/2, width/2)
            
        }
        
        
    }
    
    

}
