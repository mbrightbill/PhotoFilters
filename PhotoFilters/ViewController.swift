//
//  ViewController.swift
//  PhotoFilters
//
//  Created by Matthew Brightbill on 10/13/14.
//  Copyright (c) 2014 Matthew Brightbill. All rights reserved.
//

import UIKit


class ViewController: UIViewController, GalleryDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageViewMain: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    //prepare for segue outside of any selecting
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_GALLERY" {
            let destinationVC = segue.destinationViewController as GalleryViewController
            destinationVC.delegate = self
        }
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
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        alertController.addAction(cameraAction)
        self.presentViewController(alertController, animated: true, completion: nil) // because we present it, a strong reference is stored, rather than the local variable just dying
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.imageViewMain.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didTapOnPicture(image : UIImage) {
        println("didTapOnPicture")
        self.imageViewMain.image = image
        
    }


}

