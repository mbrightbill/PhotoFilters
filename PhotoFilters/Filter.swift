//
//  Filter.swift
//  PhotoFilters
//
//  Created by Matthew Brightbill on 10/17/14.
//  Copyright (c) 2014 Matthew Brightbill. All rights reserved.
//

import Foundation
import CoreData

class Filter: NSManagedObject {

    @NSManaged var favorited: NSNumber
    @NSManaged var name: String
    @NSManaged var inputRadius: NSNumber
    @NSManaged var inputIntensity: NSNumber

}
