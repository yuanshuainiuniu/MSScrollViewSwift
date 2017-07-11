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
let urlArr = []
let msScrollView = MSScrollView()
msScrollView.frame = CGRect.init(x: 0, y: 30, width: self.view.frame.size.width, height: 200)
msScrollView.isAutoPlay = true
msScrollView.timeInterval = 4
msScrollView.pageControlOffset = UIOffset.init(horizontal: -5, vertical: 5)
msScrollView.pageControlDir = MSPageControlDirection.MSPageControl_Right
self.view.addSubview(msScrollView)
msScrollView.urlImages = urlArr
/*
 frame:set MSScrollView frame
 images:your imagenames
 delegate:
 direciton:MSCycleDirectionHorizontal or MSCycleDirectionVertical
 autoPlay:or play auto
 delay:tmer
*/
```
### MSScrollViewDelegate
```Objective-c
- (void)MSScrollView:(MSScrollView *)MSScrollView didSelectPage:(NSInteger)index;

- (void)MSScrollViewDidScroll:(UIScrollView *)scrollView;


