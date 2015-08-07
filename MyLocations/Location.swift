//
//  Location.swift
//  MyLocations
//
//  Created by Rachana Acharya on 8/7/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import Foundation
import CoreData

class Location: NSManagedObject {

    @NSManaged var lattitude: Double
    @NSManaged var longitude: Double
    @NSManaged var locationDescription: String
    @NSManaged var category: String
    @NSManaged var placemark: AnyObject
    @NSManaged var date: NSTimeInterval

}
