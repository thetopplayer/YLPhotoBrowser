//
//  YLPhotoCell.swift
//  YLPhotoBrowser
//
//  Created by yl on 2017/7/27.
//  Copyright © 2017年 February12. All rights reserved.
//

import UIKit
import SDWebImage

class YLPhotoCell: UICollectionViewCell {
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView(frame: CGRect.zero)
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.maximumZoomScale = 4.0
        sv.minimumZoomScale = 1.0
        return sv
    }()
    
    let imageView: UIImageView = {
        
        let imgView = UIImageView()
        imgView.backgroundColor = UIColor.init(red: 244/255.0, green: 244/255.0, blue: 244/255.0, alpha: 0.1)
        imgView.tag = ImageViewTag
        imgView.contentMode = UIViewContentMode.scaleAspectFit
        return imgView
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutUI()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutUI() {
        
        self.backgroundColor = UIColor.clear
        
        scrollView.frame = self.bounds
        scrollView.delegate = self
        
        self.addSubview(scrollView)
        
        scrollView.contentSize = imageView.frame.size
        scrollView.addSubview(imageView)
    }
    
    func updatePhoto(_ photo: YLPhoto?) {
    
        if photo?.imageUrl != "" {
            
            imageView.frame.size = CGSize.init(width: YLScreenW, height: YLScreenW)
            imageView.center = ImageViewCenter
            
            imageView.sd_setShowActivityIndicatorView(true)
            imageView.sd_setIndicatorStyle(.white)
            
            var webImageOptions = SDWebImageOptions.retryFailed
            webImageOptions.formUnion(SDWebImageOptions.progressiveDownload)
            imageView.sd_setImage(with: URL(string: (photo?.imageUrl)!), placeholderImage: nil, options: webImageOptions, completed: { [weak self] (image:UIImage?, error:Error?, cacheType:SDImageCacheType, url:URL?) in
                guard let img = image else {
                    let image = UIImage.init(named: "load_error")
                    self?.imageView.frame = YLPhotoBrowser.getImageViewFrame(image?.size ?? CGSize.zero)
                    self?.imageView.image = image
                    
                    return
                }
                self?.imageView.frame = YLPhotoBrowser.getImageViewFrame(img.size)
                self?.imageView.image = img
                photo?.image = image
            })
        }else if photo?.image != nil {
            
            imageView.image = photo?.image
            imageView.frame = YLPhotoBrowser.getImageViewFrame((photo?.image?.size)!)
            
        }
    }
    
}

extension YLPhotoCell: UIScrollViewDelegate {
    
    // 设置UIScrollView中要缩放的视图
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // 让UIImageView在UIScrollView缩放后居中显示
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        let size = scrollView.bounds.size
        
        let offsetX = (size.width > scrollView.contentSize.width) ?
            (size.width - scrollView.contentSize.width) * 0.5 : 0.0
        
        let offsetY = (size.height > scrollView.contentSize.height) ?
            (size.height - scrollView.contentSize.height) * 0.5 : 0.0
        
        imageView.center = CGPoint.init(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
        
    }
    
}
