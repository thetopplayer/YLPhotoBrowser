//
//  YLPhotoBrowser.swift
//  YLPhotoBrowser
//
//  Created by yl on 2017/7/25.
//  Copyright © 2017年 February12. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

let PhotoBrowserBG = UIColor.black

let YLScreenW = UIScreen.main.bounds.width
let YLScreenH = UIScreen.main.bounds.height

class YLPhotoBrowser: UIViewController {
    
    fileprivate var photos: [YLPhoto]? // 图片
    fileprivate var currentIndex: Int = 0 // 当前row
    fileprivate var currentImageView:UIImageView? // 当前图片
    // 默认用户选择的图片位置
    fileprivate var defaultBeforeImgFrame = CGRect.zero
    
    fileprivate var appearAnimatedTransition:YLAnimatedTransition? // 进来的动画
    fileprivate var disappearAnimatedTransition:YLAnimatedTransition? // 出去的动画
    
    fileprivate var collectionView:UICollectionView!
    fileprivate var pageControl:UIPageControl?
    
    fileprivate var imageViewCenter = CGPoint.init(x: YLScreenW/2, y: YLScreenH/2)
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        disappearAnimatedTransition = nil
    }
    
    deinit {
        transitioningDelegate = nil
        appearAnimatedTransition = nil
        print("释放:\(self)")
    }
    
    convenience init(_ photos: [YLPhoto],index: Int) {
        self.init()
        
        self.photos = photos
        self.currentIndex = index
        
        let photo = photos[index]
        
        defaultBeforeImgFrame = photo.frame ?? CGRect.zero
        
        editTransitioningDelegate(photo)
    }
    
    override func viewDidLoad() {
        
        view.backgroundColor = PhotoBrowserBG
        
        view.isUserInteractionEnabled = true

        view.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(YLPhotoBrowser.pan(_:))))
        view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(YLPhotoBrowser.tap)))
        
        layoutUI()
        
        collectionView.contentOffset.x = YLScreenW * CGFloat(currentIndex)
    }
    
    private func layoutUI() {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: YLScreenW, height: YLScreenH)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        
        if (photos?.count)! > 1 {
            
            pageControl = UIPageControl()
            pageControl?.center = CGPoint(x: YLScreenW / 2 , y: YLScreenH - 30)
            pageControl?.pageIndicatorTintColor = UIColor.lightGray
            pageControl?.currentPageIndicatorTintColor = UIColor.white
            pageControl?.numberOfPages = (photos?.count)!
            pageControl?.currentPage = currentIndex
            pageControl?.backgroundColor = UIColor.clear
            
            view.addSubview(pageControl!)
            
        }
    }
    
    // 点击手势
    func tap() {
        if let photo = photos?[currentIndex]{
            editTransitioningDelegate(photo)
            dismiss(animated: true, completion: nil)
        }
    }
    
    // 慢移手势
    func pan(_ pan: UIPanGestureRecognizer) {
        
        if currentImageView == nil {
            return
        }
        
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

            currentImageView?.transform = CGAffineTransform.init(scaleX: scale, y: scale)
            
            currentImageView?.center = CGPoint.init(x: imageViewCenter.x + translation.x * scale, y: imageViewCenter.y + translation.y * scale)
            
            break
        case .failed,.cancelled,.ended:
            
            if translation.y <= 80 {
                UIView.animate(withDuration: 0.2, animations: {
                    [weak self] in
                    
                    self?.currentImageView?.center = (self?.imageViewCenter)!
                    self?.currentImageView?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                    }, completion: { [weak self] (finished: Bool) in
                    
                        self?.currentImageView?.transform = CGAffineTransform.identity
                        
                })
            }else {
                self.currentImageView?.isHidden = true
                disappearAnimatedTransition?.currentImage = currentImageView?.image
                disappearAnimatedTransition?.currentImageViewFrame = currentImageView?.frame ?? CGRect.zero
                disappearAnimatedTransition?.beforeImageViewFrame = photos?[currentIndex].frame ?? defaultBeforeImgFrame
            }
            
            break
        }
    }
    
    // 获取imageView frame
    func getImageViewFrame(_ size: CGSize) -> CGRect {
        
        let height = YLScreenW * (size.height / size.width)
        let frame = CGRect.init(x: 0, y: YLScreenH/2 - height/2, width: YLScreenW, height: height)
        
        return frame
    }
    
    // 修改 transitioningDelegate
    func editTransitioningDelegate(_ photo: YLPhoto) {
    
        appearAnimatedTransition = nil
        appearAnimatedTransition = YLAnimatedTransition.init(photo.image, beforeImgFrame: photo.frame ?? defaultBeforeImgFrame, afterImgFrame: photo.image != nil ? getImageViewFrame((photo.image?.size)!):getImageViewFrame(CGSize.init(width: YLScreenW, height: YLScreenW)))
        
        self.transitioningDelegate = appearAnimatedTransition
        
    }
}

// MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension YLPhotoBrowser:UICollectionViewDelegate,UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let photos = self.photos {
            return photos.count
        }else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        for view in cell.subviews {
            view.removeFromSuperview()
        }
        
        let photo = photos?[indexPath.row]
        
        let imageView = UIImageView()
        
        if photo?.imageUrl != "" {
            
            imageView.frame.size = CGSize.init(width: YLScreenW, height: YLScreenW)
            imageView.center = imageViewCenter
            imageView.sd_setShowActivityIndicatorView(true)
            imageView.sd_setIndicatorStyle(.white)
            var webImageOptions = SDWebImageOptions.retryFailed
            webImageOptions.formUnion(SDWebImageOptions.progressiveDownload)
            imageView.sd_setImage(with: URL(string: (photo?.imageUrl)!), placeholderImage: nil, options: webImageOptions, completed: { [weak self] (image:UIImage?, error:Error?, cacheType:SDImageCacheType, url:URL?) in
                guard let img = image else {
                    
                    return
                }
                imageView.frame = (self?.getImageViewFrame(img.size))!
                imageView.image = img
                photo?.image = image
            })
        }else if photo?.image != nil {
            
            imageView.image = photo?.image
            imageView.frame = getImageViewFrame((photo?.image?.size)!)
            
        }
        
        imageView.tag = 100
        
        imageView.contentMode = UIViewContentMode.scaleAspectFit

        cell.addSubview(imageView)

        if indexPath.row == currentIndex {
            currentImageView = imageView
        }
        
        return cell
        
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        currentIndex = Int(scrollView.contentOffset.x / YLScreenW)
        
        pageControl?.currentPage = currentIndex
        
        let cell = collectionView.cellForItem(at: IndexPath.init(row: currentIndex, section: 0))
        
        if let imgView = cell?.viewWithTag(100) {
            currentImageView = imgView as? UIImageView
        }
    }
    
}
