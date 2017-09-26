# YLPhotoBrowser  

![(界面)](http://upload-images.jianshu.io/upload_images/6327326-1a067526d30d6204.gif)

 仿微信图片浏览器(定义转场动画、支持本地和网络gif、拖拽取消）  
​    
# 希望
* 如果您在使用时发现错误，希望您可以 Issues 我


* 如果您发现使用的功能不够，希望您可以 Issues 我

# 导入

```swift
pod 'YLPhotoBrowser-Swift', '~> 0.0.1'
```

# 使用 

```swift
let photoBrowser = YLPhotoBrowser.init(photos, index: index)

// 可选
// 用于遮挡原来图片的View的背景色 public var originalCoverViewBG = UIColor.clear
photoBrowser.originalCoverViewBG = UIColor.white

// 可选
// 非矩形图片需要实现(比如聊天界面带三角形的图片) 默认是矩形图片
photoBrowser.getTransitionImageView = { (index: Int, image: UIImage?, isBack: Bool) -> UIView? in
    if isBack == false {
        return nil
    }
    let messagePhotoImageView = ChatPhotoImageView(frame: CGRect.zero)
    return messagePhotoImageView
}
// 可选
// 每张图片上的 View 视图
photoBrowser.getViewOnTheBrowser = { [weak self] (currentIndex: Int) -> UIView? in
            
    let view = UIView()
    view.backgroundColor = UIColor.clear

    let label = UILabel()
    label.text = "第 \(currentIndex) 张"
    label.textColor = UIColor.red
    view.addSubview(label)
    // label 约束
    label.translatesAutoresizingMaskIntoConstraints = false
    label.addLayoutConstraint(attributes: [.centerX,.top], toItem: view, 						constants: [0,40])

    label.backgroundColor = UIColor.blue
    label.isUserInteractionEnabled = true
    label.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: 					#selector(ViewController.tap)))

    return view
}

present(photoBrowser, animated: true, completion: nil)

// 代理
func epPhotoBrowserGetPhotoCount() -> Int {
    return dataArray.count
}
    
func epPhotoBrowserGetPhotoByCurrentIndex(_ currentIndex: Int) -> YLPhoto {

    var photo: YLPhoto?
    if let cell = collectionView.cellForItem(at: IndexPath.init(row: currentIndex, 					section: 0)) {

        let frame = collectionView.convert(cell.frame, to: collectionView.superview)
        if currentIndex <= 2 {
            let imageName = dataArray[currentIndex]
            var image:UIImage?
            if currentIndex == 2 {
                // gif
                let path = Bundle.main.path(forResource: imageName, ofType: nil)
                let data = try! Data.init(contentsOf: URL.init(fileURLWithPath: path!))
                image = UIImage.yl_gifWithData(data)
            }else {
                // 非 gif
                image = UIImage.init(named: imageName)
            }
            photo =  YLPhoto.addImage(image, imageUrl: nil, frame: frame)
        }else {
            let url = dataArray[currentIndex]
            // 最佳
            let imageView:UIImageView? = cell.viewWithTag(100) as! UIImageView?
            photo = YLPhoto.addImage(imageView?.image, imageUrl: url, frame: frame)
            // 其次
            // photo = YLPhoto.addImage(nil, imageUrl: url, frame: frame)
        }
    }
    return photo ?? YLPhoto()
}

```

   最近更新

- 0.0.1    适配iOS11、iPhoneX、swift 4.0