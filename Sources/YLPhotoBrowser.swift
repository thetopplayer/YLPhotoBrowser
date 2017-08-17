//
//  YLPhotoBrowser.swift
//  YLPhotoBrowser
//
//  Created by yl on 2017/7/25.
//  Copyright © 2017年 February12. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

let PhotoBrowserBG = UIColor.black
let ImageViewTag = 1000
let CoverViewTag = 10000

var ImageViewCenter = CGPoint.init(x: YLScreenW / 2, y: YLScreenH / 2)
var YLScreenW = UIScreen.main.bounds.width
var YLScreenH = UIScreen.main.bounds.height

public typealias GetTransitionImageView = (_ currentIndex: Int,_ image: UIImage?,_ isBack: Bool) -> (UIView?)

public typealias GetViewOnTheBrowser = (_ currentIndex: Int) -> (UIView?)

public class YLPhotoBrowser: UIViewController {
    
    // 非矩形图片需要实现(比如聊天界面带三角形的图片) 默认是矩形图片
    public var getTransitionImageView: GetTransitionImageView? {
        didSet {
            if let photo = photos?[currentIndex] {
                editTransitioningDelegate(photo,isBack: false)
            }
        }
    }
    
    // 每张图片上的 View 视图
    public var getViewOnTheBrowser: GetViewOnTheBrowser?
    
    fileprivate var photos: [YLPhoto]? // 图片
    fileprivate var currentIndex: Int = 0 // 当前row
    
    fileprivate var appearAnimatedTransition:YLAnimatedTransition? // 进来的动画
    fileprivate var disappearAnimatedTransition:YLAnimatedTransition? // 出去的动画
    
    fileprivate var collectionView:UICollectionView!
    fileprivate var pageControl:UIPageControl?
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    var transitionImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.backgroundColor = UIColor.clear
        imgView.contentMode = UIViewContentMode.scaleAspectFit
        imgView.isHidden = true
        return imgView
    }()
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        disappearAnimatedTransition = nil
    }
    
    deinit {
        removeObserver(self, forKeyPath: "view.frame")
        panGestureRecognizer = nil
        getTransitionImageView = nil
        transitioningDelegate = nil
        appearAnimatedTransition = nil
    }
    
    // 是否支持屏幕旋转
    override public var shouldAutorotate: Bool {
        return true
    }
    
    // 初始化
    public convenience init(_ photos: [YLPhoto],index: Int) {
        self.init()
        
        self.photos = photos
        self.currentIndex = index
        
        let photo = photos[index]
        
        editTransitioningDelegate(photo,isBack: false)
    }
    
    // 键盘 View frame 改变
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "view.frame" {
            
            YLScreenW = view.bounds.width
            YLScreenH = view.bounds.height
            ImageViewCenter = CGPoint.init(x: YLScreenW / 2, y: YLScreenH / 2)
            
            collectionView.reloadData()
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.scrollToItem(at: IndexPath.init(row: self?.currentIndex ?? 0, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
            }
        }
    }
    
    override public func viewDidLoad() {
        
        view.backgroundColor = PhotoBrowserBG
        
        view.isUserInteractionEnabled = true
        
        panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(YLPhotoBrowser.pan(_:)))
        view.addGestureRecognizer(panGestureRecognizer!)
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(YLPhotoBrowser.singleTap))
        view.addGestureRecognizer(singleTap)
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(YLPhotoBrowser.doubleTap))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        // 优先识别 双击
        singleTap.require(toFail: doubleTap)
        
        layoutUI()
        
        collectionView.scrollToItem(at: IndexPath.init(row: currentIndex, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
        
        addObserver(self, forKeyPath: "view.frame", options: NSKeyValueObservingOptions.old, context: nil)
        
    }
    
    // 绘制 UI
    private func layoutUI() {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        collectionView.register(YLPhotoCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        
        // collectionView 约束
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let cConstraintsTop = NSLayoutConstraint.init(item: collectionView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        let cConstraintsLeft = NSLayoutConstraint.init(item: collectionView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
        let cConstraintsRight = NSLayoutConstraint.init(item: collectionView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0)
        let cConstraintsBottom = NSLayoutConstraint.init(item: collectionView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([cConstraintsTop,cConstraintsLeft,cConstraintsRight,cConstraintsBottom])
        
        if (photos?.count)! > 1 {
            
            pageControl = UIPageControl()
            pageControl?.pageIndicatorTintColor = UIColor.lightGray
            pageControl?.currentPageIndicatorTintColor = UIColor.white
            pageControl?.numberOfPages = (photos?.count)!
            pageControl?.currentPage = currentIndex
            pageControl?.backgroundColor = UIColor.clear
            
            view.addSubview(pageControl!)
            
            // pageControl 约束
            pageControl?.translatesAutoresizingMaskIntoConstraints = false
            let pConstraintsCenterX = NSLayoutConstraint.init(item: pageControl!, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            let pConstraintsBottom = NSLayoutConstraint.init(item: pageControl!, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -30)
            NSLayoutConstraint.activate([pConstraintsCenterX,pConstraintsBottom])
            
        }
        
        view.addSubview(transitionImageView)
        
        view.layoutIfNeeded()
    }
    
    // 单击手势
    func singleTap() {
        
        if let photo = photos?[currentIndex]{
            editTransitioningDelegate(photo,isBack: true)
            dismiss(animated: true, completion: nil)
        }
    }
    
    // 双击手势
    func doubleTap() {
        
        let currentImageView = getCurrentImageView()
        
        if currentImageView == nil {
            return
        }else if currentImageView?.image == nil {
            return
        }
        
        if currentImageView?.superview is UIScrollView {
            let scrollView = currentImageView?.superview as! UIScrollView
            if scrollView.zoomScale == 1 {
                
                var scale:CGFloat = 0
                
                if YLScreenW < YLScreenH {
                    scale = YLScreenH / (currentImageView?.frame.size.height ?? YLScreenH)
                }else {
                    scale = YLScreenW / (currentImageView?.frame.size.width ?? YLScreenW)
                }
                
                scale = scale > 4 ? 4: scale
                scale = scale < 1 ? 2: scale
                
                scrollView.setZoomScale(scale, animated: true)
            }else {
                scrollView.setZoomScale(1, animated: true)
            }
        }
        
    }
    
    // 慢移手势
    func pan(_ pan: UIPanGestureRecognizer) {
        
        let currentImageView = getCurrentImageView()
        
        if currentImageView == nil {
            return
        }else if currentImageView?.image == nil {
            return
        }else if currentImageView?.superview is UIScrollView {
            
            let scrollView = currentImageView?.superview as! UIScrollView
            if scrollView.zoomScale != 1 {
                return
            }
            
            if transitionImageView.isHidden == true {
                currentImageView?.isHidden = true
                transitionImageView.isHidden = false
                transitionImageView.image = currentImageView?.image
                transitionImageView.frame = currentImageView?.frame ?? CGRect.zero
            }
            
            scrollView.delegate = nil
            
            let translation = pan.translation(in:  pan.view)
            
            var scale = 1 - translation.y / YLScreenH
            
            scale = scale > 1 ? 1:scale
            scale = scale < 0 ? 0:scale
            
            switch pan.state {
            case .possible:
                break
            case .began:
                
                disappearAnimatedTransition = nil
                disappearAnimatedTransition = YLAnimatedTransition()
                disappearAnimatedTransition?.gestureRecognizer = pan
                self.transitioningDelegate = disappearAnimatedTransition
                
                dismiss(animated: true, completion: nil)
                
                break
            case .changed:
                
                transitionImageView.frame.size = CGSize.init(width: (currentImageView?.frame.size.width ?? 0) * scale, height: (currentImageView?.frame.size.height ?? 0) * scale)
                
                transitionImageView.frame.origin = CGPoint.init(x: (currentImageView?.frame.origin.x ?? 0) + translation.x, y: (currentImageView?.frame.origin.y ?? 0) + translation.y)
                
                break
            case .failed,.cancelled,.ended:
                
                if translation.y <= 80 {
                    UIView.animate(withDuration: 0.2, animations: {
                        
                        self.transitionImageView.frame = YLPhotoBrowser.getImageViewFrame(self.photos?[self.currentIndex].image?.size ?? CGSize.zero)
                        
                    }, completion: { (finished: Bool) in
                        
                        self.transitionImageView.isHidden = true
                        currentImageView?.isHidden = false
                        
                    })
                    
                    let cell = collectionView.cellForItem(at: IndexPath.init(row: currentIndex, section: 0))
                    scrollView.delegate = cell as! UIScrollViewDelegate?
                    
                }else {
                    
                    transitionImageView.isHidden = true
                    let imageView = getTransitionImageView?(currentIndex,photos?[currentIndex].image,true)
                    disappearAnimatedTransition?.transitionImage = photos?[currentIndex].image
                    disappearAnimatedTransition?.transitionImageView = imageView
                    disappearAnimatedTransition?.transitionBrowserImgFrame = transitionImageView.frame
                    disappearAnimatedTransition?.transitionOriginalImgFrame = photos?[currentIndex].frame ?? CGRect.zero
                }
                
                break
            }
        }
        
    }
    
    // 获取imageView frame
    class func getImageViewFrame(_ size: CGSize) -> CGRect {
        
        if YLScreenW < YLScreenH {
            
            if size.width > YLScreenW {
                let height = YLScreenW * (size.height / size.width)
                if height <= YLScreenH {
                    
                    let frame = CGRect.init(x: 0, y: YLScreenH/2 - height/2, width: YLScreenW, height: height)
                    return frame
                }else {
                    
                    let frame = CGRect.init(x: 0, y: 0, width: YLScreenW, height: height)
                    return frame
                    
                }
            }else {
                let frame = CGRect.init(x: YLScreenW/2 - size.width/2, y: YLScreenH/2 - size.height/2, width: size.width, height: size.height)
                return frame
            }
            
        }else {
            
            if size.height > YLScreenH {
                let width = YLScreenH * (size.width / size.height)
                if width <= YLScreenW {
                    let frame = CGRect.init(x: YLScreenW/2 - width/2, y: 0, width: width, height: YLScreenH)
                    return frame
                }else {
                    
                    let frame = CGRect.init(x: 0, y: 0, width: width, height: YLScreenH)
                    
                    return frame
                    
                }
            }else {
                let frame = CGRect.init(x: YLScreenW/2 - size.width/2, y: YLScreenH/2 - size.height/2, width: size.width, height: size.height)
                return frame
            }
        }
    }
    
    // 获取 currentImageView
    func getCurrentImageView() -> UIImageView? {
        
        if collectionView == nil {
            return nil
        }
        
        let cell = collectionView.cellForItem(at: IndexPath.init(row: currentIndex, section: 0))
        
        if let imgView = cell?.viewWithTag(ImageViewTag) {
            return imgView as? UIImageView
        }else {
            return nil
        }
    }
    
    // 修改 transitioningDelegate
    func editTransitioningDelegate(_ photo: YLPhoto,isBack: Bool) {
        
        if photo.image == nil {
            
            let isCached = KingfisherManager.shared.cache.isImageCached(forKey: photo.imageUrl).cached
            
            if isCached {
                KingfisherManager.shared.retrieveImage(with: URL.init(string: photo.imageUrl)!, options: [.preloadAllAnimationData,.transition(.fade(1))], progressBlock: nil, completionHandler: { (image:Image?, _, _, _) in
                    photo.image = image
                })
            }
        }
        
        let currentImageView = getCurrentImageView()
        
        var transitionBrowserImgFrame = CGRect.zero
        if currentImageView != nil {
            transitionBrowserImgFrame = (currentImageView?.frame)!
        }else if photo.image != nil {
            transitionBrowserImgFrame = YLPhotoBrowser.getImageViewFrame((photo.image?.size)!)
        }else {
            transitionBrowserImgFrame = YLPhotoBrowser.getImageViewFrame(CGSize.init(width: YLScreenW, height: YLScreenW))
        }
        
        appearAnimatedTransition = nil
        let imageView = getTransitionImageView?(currentIndex,photo.image,isBack)
        appearAnimatedTransition = YLAnimatedTransition.init(photo.image,transitionImageView: imageView, transitionOriginalImgFrame: photo.frame, transitionBrowserImgFrame: transitionBrowserImgFrame)
        
        self.transitioningDelegate = appearAnimatedTransition
        
    }
}

// MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension YLPhotoBrowser:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let photos = self.photos {
            return photos.count
        }else {
            return 0
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: YLPhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! YLPhotoCell
        
        if let photo = photos?[indexPath.row] {
            cell.panGestureRecognizer = panGestureRecognizer
            cell.updatePhoto(photo)
            
            if let coverView = getViewOnTheBrowser?(indexPath.row) {
                coverView.tag = CoverViewTag
                
                if let subView = cell.viewWithTag(CoverViewTag) {
                    subView.removeFromSuperview()
                }
                
                coverView.frame = cell.bounds
                cell.addSubview(coverView)
            }
            
        }
        
        return cell
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize.init(width: YLScreenW, height: YLScreenH)
    }
    
    // 已经停止减速
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == collectionView {
            currentIndex = Int(scrollView.contentOffset.x / YLScreenW)
            pageControl?.currentPage = currentIndex
        }
    }
}
