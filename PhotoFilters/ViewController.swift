//
//  ViewController.swift
//  PhotoFilters
//
//  Created by Matthew Brightbill on 10/13/14.
//  Copyright (c) 2014 Matthew Brightbill. All rights reserved.
//

import UIKit
import CoreImage
import OpenGLES
import CoreData


class ViewController: UIViewController, GalleryDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource {
    
    var context : CIContext?
    var originalThumbnail : UIImage?
    // this is the coreData array
    var filters = [Filter]()
    // this is the array of thumbnail wrapper objects
    var filterThumbnails = [FilterThumbnail]()
    
    let imageQueue = NSOperationQueue()
    
    @IBOutlet weak var thumbNailCollectionView: UICollectionView!
    @IBOutlet weak var thumbNailCollectionViewBottom: NSLayoutConstraint!
    @IBOutlet weak var imageViewMainTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewMainLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewMainBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewMain: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.generateThumbnail()
        
        // setting up Core Image context, GPU
        var options = [kCIContextWorkingColorSpace : NSNull()]
        var myEAGLContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        self.context = CIContext(EAGLContext: myEAGLContext, options: options)
        
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var seeder = CoreDataSeeder(context: appDelegate.managedObjectContext!)
        seeder.seedCoreData()
        
        self.fetchFilters()
        self.resetFilterThumbnails()
        
        self.filters.append("CISepiaTone")
        self.filters.append("CIGaussianBlur")
        self.filters.append("CIPixellate")
        self.filters.append("CIGammaAdjust")
        self.filters.append("CIExposureAdjust")
        self.filters.append("CIPhotoEffectChrome")
        self.filters.append("CIPhotoEffectInstant")
        self.filters.append("CIPhotoEffectMono")
        self.filters.append("CIPhotoEffectNoir")
        self.filters.append("CIPhotoEffectTonal")
        
        var image = UIImage(named: "photo2.jpg")
        self.thumbNailCollectionView.dataSource = self
    }
    
    func generateThumbnail () {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        self.imageViewMain.image?.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
        self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    

    //prepare for segue outside of any selecting
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_GALLERY" {
            let destinationVC = segue.destinationViewController as GalleryViewController
            destinationVC.delegate = self
        }
    }
    
    func enterFilterMode() {
        self.imageViewMainTrailingConstraint.constant = self.imageViewMainTrailingConstraint.constant * 3
        self.imageViewMainLeadingConstraint.constant = self.imageViewMainLeadingConstraint.constant * 3
        self.imageViewMainBottomConstraint.constant = self.imageViewMainBottomConstraint.constant * 3
        self.thumbNailCollectionViewBottom.constant = 100
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
        var doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "exitFilteringMode")
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    func exitFilteringMode() {
        
        //reset the constraints back to normal values and remove Done button
        
        self.navigationItem.rightBarButtonItem = nil
    }
    
    @IBAction func photosPressed(sender: AnyObject) {
        
        let alertController = UIAlertController(title: nil, message: "Choose an option", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
            //perform when this action gets called (upon selecting)
            self.performSegueWithIdentifier("SHOW_GALLERY", sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
        }
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (action) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            imagePicker.delegate = self
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        
        let filterAction = UIAlertAction(title: "Filters", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.enterFilterMode()
        }
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        alertController.addAction(cameraAction)
        alertController.addAction(filterAction)
        self.presentViewController(alertController, animated: true, completion: nil) // because we present it, a strong reference is stored, rather than the local variable just dying
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.imageViewMain.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didTapOnPicture(image : UIImage) {
        println("didTapOnPicture")
        self.imageViewMain.image = image
        self.generateThumbnail()
        self.resetFilterThumbnails()
        self.thumbNailCollectionView.reloadData()
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = thumbNailCollectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as FilterThumbnailCell
        var filterThumbnail = self.filterThumbnails[indexPath.row]
        // lazy loading
        if filterThumbnail.filteredThumbnail != nil {
            cell.imageViewThumbnail.image = filterThumbnail.filteredThumbnail
        } else {
            cell.imageViewThumbnail.image = filterThumbnail.originalThumbnail
            filterThumbnail.generateThumbnail({ (image) -> Void in
                if let cell = self.thumbNailCollectionView.cellForItemAtIndexPath(indexPath) as? FilterThumbnailCell {
                    cell.imageViewThumbnail.image = image
                }
            })
        }
        return cell
    }
    
    func fetchFilters() -> [Filter] {
        var fetchRequest = NSFetchRequest(entityName: "Filter")
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var context = appDelegate.managedObjectContext
        
        var error: NSError?
        let fetchResults = context?.executeFetchRequest(fetchRequest, error: &error)
        if let filters = fetchResults as? [Filter] {
            println("filters: \(filters.count)")
            self.filters = filters
        }
    }
    
    func resetFilterThumbnails () {
        var newFilters = [FilterThumbnail]()
        for var index = 0; index < self.filters.count; ++index {
            var filter = self.filters[index]
            var filterName = filter.name
            var thumbnail = FilterThumbnail(name: filterName, thumbnail: self.originalThumbnail!, queue: self.imageQueue, context: self.context!)
            
        }
        self.filterThumbnails = newFilters
    }


}

