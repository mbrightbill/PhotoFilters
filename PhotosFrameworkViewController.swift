//
//  PhotosFrameworkViewController.swift
//  PhotoFilters
//
//  Created by Matthew Brightbill on 10/15/14.
//  Copyright (c) 2014 Matthew Brightbill. All rights reserved.
//

import UIKit
import Photos

class PhotosFrameworkViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var assetFetchResults : PHFetchResult!
    var assetCollection : PHAssetCollection!
    var imageManager : PHCachingImageManager!
    var assetCellSize : CGSize!
    var delegate : GalleryDelegate?

    @IBOutlet weak var photosFrameworkCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.photosFrameworkCollectionView.delegate = self
        self.photosFrameworkCollectionView.dataSource = self

        // get image manager , asset fetch results
        self.imageManager = PHCachingImageManager()
        
        // Pass nil, fetch all assets
        self.assetFetchResults = PHAsset.fetchAssetsWithOptions(nil)
        
        // Determine device scale, adjust asset cell size
        var scale = UIScreen.mainScreen().scale
        var flowLayout = self.photosFrameworkCollectionView.collectionViewLayout as UICollectionViewFlowLayout
        
        var cellSize = flowLayout.itemSize
        self.assetCellSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale)
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetFetchResults.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = photosFrameworkCollectionView.dequeueReusableCellWithReuseIdentifier("PHOTOS_CELL", forIndexPath: indexPath) as PhotosFrameworkCell
        
        var currentTag = cell.tag + 1
        cell.tag = currentTag
        
        var asset = self.assetFetchResults[indexPath.row] as PHAsset
        
        self.imageManager.requestImageForAsset(asset, targetSize: self.assetCellSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
            if cell.tag == currentTag {
                cell.photosFrameworkImageView.image = image
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        var asset = self.assetFetchResults[indexPath.row] as PHAsset
        
        self.imageManager.requestImageDataForAsset(asset, options: nil) { (data : NSData!, string : String!, orientation : UIImageOrientation, object ) -> Void in
            
            var image = UIImage(data: data)
            
            self.delegate?.didTapOnPicture(image)
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }
    }
}
