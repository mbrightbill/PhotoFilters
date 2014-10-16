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


class ViewController: UIViewController, GalleryDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var managedObjectContext : NSManagedObjectContext!
    var originalThumbnail : UIImage?
    // this is the coreData array
    var filters : [Filter]?
    // this is the array of thumbnail wrapper objects
    var thumbnailContainers = [ThumbnailContainer]()
    var gpuContext : CIContext?
    
    var imageQueue = NSOperationQueue()
    
    @IBOutlet weak var thumbnailCollectionView: UICollectionView!
    
    @IBOutlet weak var imageViewMain: UIImageView!
    
    @IBOutlet weak var thumbnailCollectionViewBottom : NSLayoutConstraint!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.thumbnailCollectionView.delegate = self
        
        // setting up Core Image context, GPU
        var options = [kCIContextWorkingColorSpace : NSNull()]
        var myEAGLContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        self.gpuContext = CIContext(EAGLContext: myEAGLContext, options: options)
        
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Filter")
        var error : NSError?
        
        if let filters = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [Filter] {
            if filters.isEmpty {
                self.seedCoreData()
                self.filters = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [Filter]
            } else {
                self.filters = filters
            }
        }
        
        self.thumbnailCollectionView.dataSource = self
        
        self.thumbnailCollectionViewBottom.constant = -100
    }
    
    func seedCoreData() {
        var sepia = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        sepia.name = "CISepiaTone"
        
        var gaussianBlur = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        gaussianBlur.name = "CIGaussianBlur"
        gaussianBlur.favorited = true
        
        var pixellate = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        pixellate.name = "CIPixellate"
        
        var gammaAdjust = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        gammaAdjust.name = "CIGammaAdjust"
        
        var exposureAdjust = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        exposureAdjust.name = "CIExposureAdjust"
        
        var photoEffectChrome = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectChrome.name = "CIPhotoEffectChrome"
        
        var photoEffectInstant = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectInstant.name = "CIPhotoEffectInstant"
        
        var photoEffectMono = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectMono.name = "CIPhotoEffectMono"
        
        var photoEffectNoir = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectNoir.name = "CIPhotoEffectNoir"
        
        var photoEffectTonal = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        photoEffectTonal.name = "CIPhotoEffectTonal"
        
        var error : NSError?
        self.managedObjectContext.save(&error)
        
        if error != nil {
            println(error!.localizedDescription)
        }
        
    }
    
    

    
    func resetThumbnails() {
        
        // first we generate the thumbnail from the image that was selected
        var size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        self.imageViewMain.image?.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
        self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // now we need to setup our thumbnail containers
        var newThumbnailContainers = [ThumbnailContainer]()
        for var index = 0; index < self.filters?.count; ++index {
            let filter = self.filters![index]
            var thumbnailContainers = ThumbnailContainer(filterName: filter.name, thumbNail: self.originalThumbnail!, queue: self.imageQueue, context: self.gpuContext!)
            newThumbnailContainers.append(thumbnailContainers)
        }
        self.thumbnailContainers = newThumbnailContainers
        self.thumbnailCollectionView.reloadData()
    }

    //prepare for segue outside of any selecting
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_GALLERY" {
            let destinationVC = segue.destinationViewController as GalleryViewController
            destinationVC.delegate = self
        }
        
        if segue.identifier == "SHOW_PHOTOS_FRAMEWORK" {
            let destinationVC = segue.destinationViewController as PhotosFrameworkViewController
            destinationVC.delegate = self
        }
    }
    
    
    
    func enterFilterMode() {

        self.thumbnailCollectionViewBottom.constant = 100
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
        var doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "exitFilteringMode")
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    func exitFilteringMode() {
        
        self.thumbnailCollectionViewBottom.constant = -100
        
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
        
        let photosActions = UIAlertAction(title: "Photos Framework", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.performSegueWithIdentifier("SHOW_PHOTOS_FRAMEWORK", sender: self)
        }
        
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        alertController.addAction(cameraAction)
        alertController.addAction(filterAction)
        alertController.addAction(photosActions)
        self.presentViewController(alertController, animated: true, completion: nil) // because we present it, a strong reference is stored, rather than the local variable just dying
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.imageViewMain.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didTapOnPicture(image : UIImage) {
        println("didTapOnPicture")
        self.imageViewMain.image = image
        self.resetThumbnails()
        self.thumbnailCollectionView.reloadData()
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let thumbnailContainer = self.thumbnailContainers[indexPath.row]
        thumbnailContainer.generateFilterThumbnail { (filteredThumb) -> Void in
            self.imageViewMain.image = filteredThumb
        }
        
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.thumbnailContainers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = thumbnailCollectionView.dequeueReusableCellWithReuseIdentifier("THUMBNAIL_CELL", forIndexPath: indexPath) as ThumbnailCell
        let thumbnailContainer = self.thumbnailContainers[indexPath.row]
        // lazy loading
        if thumbnailContainer.filteredThumbnail != nil {
            cell.imageViewThumbnail.image = thumbnailContainer.filteredThumbnail
        } else {
            cell.imageViewThumbnail.image = thumbnailContainer.originalThumbnail
            thumbnailContainer.generateFilterThumbnail({ (filteredThumb) -> Void in
                if let cell = self.thumbnailCollectionView.cellForItemAtIndexPath(indexPath) as? ThumbnailCell {
                    cell.imageViewThumbnail.image = filteredThumb
                }
            })
        }
        return cell
    }
    
    
  }
