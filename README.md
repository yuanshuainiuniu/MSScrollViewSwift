# AdvertisingScrollView
![image](https://github.com/yuanshuainiuniu/AdvertisingScrollView/blob/master/shot.gif)

做了一些优化,用3个imageView复用创建,支持横屏和竖屏播放(3imageView for reuse)


支持从网上下载图片(support load images from url)

后续会添加文字描述

a AdvertisingScrollView,can scroll auto,or by yourself.

使用方式:
Installation with CocoaPods：pod 'MS_ScrollViewSwift'
或者下载demo

[Object-c版本点这里](https://github.com/yuanshuainiuniu/AdvertisingScrollView-banner )

init：
```swift
// Do any additional setup after loading the view, typically from a nib.
let urlArr = ["http://b.hiphotos.baidu.com/image/pic/item/4610b912c8fcc3ce5254cb2e9045d688d43f2012.jpg",
              "http://e.hiphotos.baidu.com/image/pic/item/f31fbe096b63f624d7f185648544ebf81a4ca32d.jpg",
              "xxx",
              "http://e.hiphotos.baidu.com/image/pic/item/7a899e510fb30f241e175064ca95d143ac4b0e3c3.jpg",""]
let msScrollView = MSScrollView()
msScrollView.backgroundColor = UIColor.yellow
msScrollView.frame = CGRect.init(x: 0, y: 100, width: self.view.frame.size.width, height: 200)
msScrollView.isAutoPlay = true
msScrollView.timeInterval = 5
msScrollView.pageControlOffset = UIOffset.init(horizontal: -5, vertical: 5)
msScrollView.pageControlDir = MSPageControlDirection.MSPageControl_Center
msScrollView.direction = .MSCycleDirectionVertical
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
msScrollView.pageControl?.currentPageIndicatorTintColor = UIColor.orange
```
### MSScrollViewDelegate
```swift
//点击代理
optional func MSScrollViewSelected(_ msScrollView:MSScrollView,didSelectPage:NSInteger)
//滚动代理
optional func MSScrollViewDidAppear(_ msScrollView:MSScrollView,currentPage:NSInteger)


