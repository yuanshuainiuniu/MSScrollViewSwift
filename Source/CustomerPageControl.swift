//
//  CustomerPageControl.swift
//  lyfSwift
//
//  Created by Marshal on 2017/7/10.
//  Copyright © 2017年 Marshal. All rights reserved.
//

import UIKit

public class CustomerPageControl: UIView {
  public  var currentPageView :UIView?
  public  var pageBackColor = UIColor.init(white: 1, alpha: 0.3)
    
  public  var numberOfPages :NSInteger = 0{
        didSet{
            self.frame.size = CGSize.init(width: CGFloat((numberOfPages + 1))*margin + self.frame.size.height * CGFloat(numberOfPages), height: self.frame.size.height)
            
            while self.subviews.count > 0{
                self.subviews.last?.removeFromSuperview()
            }
            for index in 0..<numberOfPages{
                let page = UIView()
                page.layer.masksToBounds = true
                page.layer.borderColor = pageIndicatorTintColor.cgColor
                page.layer.borderWidth = 0.8
                page.backgroundColor = pageBackColor
                self.addSubview(page)
                if index == 0 {
                    currentPageView = page
                    currentPageView?.backgroundColor = currentPageIndicatorTintColor
                }
            }
        }
    }
    var margin:CGFloat = 5.0
    
   public var currentPage : NSInteger = 0{
        didSet{
            self.setCurrentPage(currentPage, withAnimation: false)
        }
    }
   public var pageIndicatorTintColor : UIColor = UIColor.gray
   public  var currentPageIndicatorTintColor : UIColor = UIColor.white
   public var pageWidth : CGFloat?
    
   public func setCurrentPage(_ currentPage:NSInteger,withAnimation animation:Bool) -> Void {
        if animation {
            let transition = CATransition()
            transition.type = CATransitionType.push;
            transition.duration = 0.2;
            transition.isRemovedOnCompletion = true;
            transition.subtype = currentPage<self.currentPage ? CATransitionSubtype.fromRight : CATransitionSubtype.fromLeft;
            currentPageView?.layer.add(transition, forKey: "transition")
        }
        if self.currentPage < self.subviews.count {
            self.currentPageView?.backgroundColor = pageBackColor
            self.currentPageView?.layer.borderColor = pageIndicatorTintColor.cgColor
            self.currentPageView?.layer.borderWidth = 0.8
            
            let page = self.subviews[currentPage]
            page.backgroundColor = currentPageIndicatorTintColor
            page.layer.borderWidth = 0.0
            self.currentPageView = page;
        }
    }
  public  func updateCurrentPageDisplay() -> Void {
        
    }
  public  override func layoutSubviews() {
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
