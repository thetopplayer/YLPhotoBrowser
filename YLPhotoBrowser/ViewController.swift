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
        layout.itemSize = CGSize(width: 90, height: 90)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView.backgroundColor = UIColor.clear
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.addLayoutConstraint(toItem: view, edgeInsets: UIEdgeInsets.init(top: 64, left: 0, bottom: 0, right: 0))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func tap() {
        print("点击")
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
                let path = Bundle.main.path(forResource: imageName, ofType: nil)
                let data = try! Data.init(contentsOf: URL.init(fileURLWithPath: path!))
                imageView.image = UIImage.yl_gifWithData(data)
                
            }else {
                imageView.image = UIImage.init(named: imageName)
            }
            
        }else {
            let url = dataArray[indexPath.row]
            imageView.kf.setImage(with: URL.init(string: url))
        }
        
        cell.addSubview(imageView)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photoBrowser = YLPhotoBrowser.init(indexPath.row, self)
        // 用白色 遮挡 原来的图
        photoBrowser.originalCoverViewBG = UIColor.white
        
        // 非矩形图片需要实现(比如聊天界面带三角形的图片) 默认是矩形图片
        photoBrowser.getTransitionImageView = { (currentIndex: Int,image: UIImage?, isBack: Bool) -> UIView? in
            
            return nil
            
        }
        
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
            label.addLayoutConstraint(attributes: [.centerX,.top], toItem: view, constants: [0,40])
            
            label.backgroundColor = UIColor.blue
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(ViewController.tap)))
            
            return view
        }
        
        present(photoBrowser, animated: true, completion: nil)
        
    }
}

// MARK: - YLPhotoBrowserDelegate
extension ViewController: YLPhotoBrowserDelegate {
    
    func epPhotoBrowserGetPhotoCount() -> Int {
        return dataArray.count
    }
    
    func epPhotoBrowserGetPhotoByCurrentIndex(_ currentIndex: Int) -> YLPhoto {
        
        var photo: YLPhoto?
        
        if let cell = collectionView.cellForItem(at: IndexPath.init(row: currentIndex, section: 0)) {
            
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
        
        return photo!
    }
}
