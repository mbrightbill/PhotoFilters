//
//  FilterThumbnail.swift
//  PhotoFilters
//
//  Created by Matthew Brightbill on 10/14/14.
//  Copyright (c) 2014 Matthew Brightbill. All rights reserved.
//

import UIKit
import CoreImage

class ThumbnailContainer {
    var originalThumbnail : UIImage
    var filteredThumbnail : UIImage?
    var imageQueue : NSOperationQueue?
    var gpuContext : CIContext
    var cifilter : CIFilter?
    var filterName : String
    
    init(filterName : String, thumbNail : UIImage, queue : NSOperationQueue, context : CIContext) {
        self.filterName = filterName
        self.originalThumbnail = thumbNail
        self.imageQueue = queue
        self.gpuContext = context
        
    }
    
    func generateFilterThumbnail( completionHandler : (filteredThumb : UIImage) -> Void ) {
        
        self.imageQueue?.addOperationWithBlock({ () -> Void in
            
            // setting up your filter with a CIImage
            var image = CIImage(image: self.originalThumbnail)
            var imgFilter = CIFilter(name: self.filterName) // "an initializer that just takes in a name"
            imgFilter.setDefaults()
            imgFilter.setValue(image, forKey: kCIInputImageKey)
        
            //generate results
            var result = imgFilter.valueForKey(kCIOutputImageKey) as CIImage
            var extent = result.extent()
            var imgRef = self.gpuContext.createCGImage(result, fromRect: extent)
            self.cifilter = imgFilter
        
            // run callback on main thread 
            NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                self.filteredThumbnail = UIImage(CGImage: imgRef)
                completionHandler(filteredThumb: self.filteredThumbnail!)
            }
        })
    }
}