//
//  ViewController.swift
//  YLPhotoBrowser
//
//  Created by yl on 2017/7/25.
//  Copyright © 2017年 February12. All rights reserved.
//

import UIKit
//import YLPhotoBrowser_Swift

class ViewController: UIViewController {
    
    fileprivate var collectionView:UICollectionView!
    fileprivate var dataArray = [String]()
    
    var imageView:UIImageView!
    var imageView1:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataArray += ["1.png","2.png","3.gif"]
        dataArray += ["http://ww2.sinaimg.cn/bmiddle/72635b6agw1eyqehvujq1j218g0p0qai.jpg",
                      "http://ww2.sinaimg.cn/bmiddle/e67669aagw1f1v6w3ya5vj20hk0qfq86.jpg",
                      "http://ww3.sinaimg.cn/bmiddle/61e36371gw1f1v6zegnezg207p06fqv6.gif",
                      "http://ww4.sinaimg.cn/bmiddle/7f02d774gw1f1dxhgmh3mj20cs1tdaiv.jpg"]
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.width / 3 - 10, height: view.bounds.width / 3 - 20)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

// MARK: - UICollectionViewDelegate,UICollectionViewDataSource
extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        for view in cell.subviews {
            view.removeFromSuperview()
        }
        
        let imageView = UIImageView.init(frame: cell.bounds)
        imageView.tag = 100
        
        if indexPath.row <= 2 {
            
            let imageName = dataArray[indexPath.row]
            
            if indexPath.row == 2 {
                
                imageView.image = UIImage.yl_gifAnimated(imageName)
                
            }else {
                imageView.image = UIImage.init(named: imageName)
            }
            
        }else {
//            let url = dataArray[indexPath.row]
//            imageView.kf.setImage(with: URL.init(string: url))
        }
        
        cell.addSubview(imageView)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var photos = [YLPhoto]()
        
        for i in 0...dataArray.count - 1 {
            
            let window = UIApplication.shared.keyWindow
            
            let cell = collectionView.cellForItem(at: IndexPath.init(row: i, section: 0))
            
            let rect1 = cell?.convert(cell?.frame ?? CGRect.zero, from: collectionView)
            let rect2 = cell?.convert(rect1 ?? CGRect.zero, to: window)
            
            if i <= 2 {
                
                let imageName = dataArray[i]
                
                var image:UIImage?
                
                if i == 2 {
                    // gif
                    image = UIImage.yl_gifAnimated(imageName)
                    
                }else {
                    // 非 gif
                    image = UIImage.init(named: imageName)
                }
                
                photos.append(YLPhoto.addImage(image, imageUrl: nil, frame: rect2))
                
            }else {
                
                let url = dataArray[i]
                
                 // 最佳
                 let imageView:UIImageView? = cell?.viewWithTag(100) as! UIImageView?
                 photos.append(YLPhoto.addImage(imageView?.image, imageUrl: url, frame: rect2))
                
                // 其次
                // photos.append(YLPhoto.addImage(nil, imageUrl: url, frame: rect2))
            }
        }
        
        let photoBrowser = YLPhotoBrowser.init(photos, index: indexPath.row)
        
        // 非矩形图片需要实现(比如聊天界面带三角形的图片) 默认是矩形图片
        photoBrowser.getTransitionImageView = { (currentIndex: Int,image: UIImage?, isBack: Bool) -> UIView? in
        
            return nil
            
        }
        
        // 每张图片上的 View 视图
        photoBrowser.getViewOnTheBrowser = { (currentIndex: Int) -> UIView? in
        
            let view = UIView()
            view.backgroundColor = UIColor.clear
            
            let label = UILabel()
            label.text = "第 \(currentIndex) 张"
            label.textColor = UIColor.red
            view.addSubview(label)
            // label 约束
            label.translatesAutoresizingMaskIntoConstraints = false
            let lConstraintsCX = NSLayoutConstraint.init(item: label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            let lConstraintsTop = NSLayoutConstraint.init(item: label, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 40)
            
            NSLayoutConstraint.activate([lConstraintsCX,lConstraintsTop])
            
            return view
        }
        
        present(photoBrowser, animated: true, completion: nil)
        
    }
}
