//
//  GalleryViewController.swift
//  PhotoFilters
//
//  Created by Matthew Brightbill on 10/13/14.
//  Copyright (c) 2014 Matthew Brightbill. All rights reserved.
//

import UIKit

@objc protocol GalleryDelegate {
    func didTapOnPicture(image : UIImage)
}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var flowLayout : UICollectionViewFlowLayout!
    
    // strong reference by default, weak is better
    weak var delegate: GalleryDelegate? // whatever this thing is, It will conform to this GalleryDelegate protocol
    
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        var image1 = UIImage(named: "photo2.jpg")
        var image2 = UIImage(named: "photo3.jpg")
        var image3 = UIImage(named: "photo4.jpg")
        var image4 = UIImage(named: "photo5.jpg")
        var image5 = UIImage(named: "photo6.jpg")
        var image6 = UIImage(named: "photo7.jpg")
        var image7 = UIImage(named: "photo8.jpg")
        
        self.images.append(image1!)
        self.images.append(image2!)
        self.images.append(image3!)
        self.images.append(image4!)
        self.images.append(image5!)
        self.images.append(image6!)
        self.images.append(image7!)
        
        self.flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        var pinch = UIPinchGestureRecognizer(target: self, action: "pinchAction:")
        self.collectionView.addGestureRecognizer(pinch)
    }
    
    func pinchAction(pinch : UIPinchGestureRecognizer) {
        
        println("test 1")
        
        if pinch.state == UIGestureRecognizerState.Ended {
            println("test 2")
            println(pinch.velocity)
            self.collectionView.performBatchUpdates({ () -> Void in
                if pinch.velocity > 0 {
                    if self.flowLayout.itemSize.width < 200.0 {
                        self.flowLayout.itemSize = CGSize(width: self.flowLayout.itemSize.width * 2, height: self.flowLayout.itemSize.height * 2)
                        println(self.flowLayout.itemSize.width)
                    }
                } else {
                    if self.flowLayout.itemSize.width > 50.0 {
                        self.flowLayout.itemSize = CGSize(width: self.flowLayout.itemSize.width * 0.5, height: self.flowLayout.itemSize.height * 0.5)
                        println(self.flowLayout.itemSize.width)
                    }
                }
            }, completion: nil)
        }
    }
        
        


    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCell
        cell.imageView.image = self.images[indexPath.row]
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("indexpath: \(indexPath)")
        self.delegate?.didTapOnPicture(self.images[indexPath.row])
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

