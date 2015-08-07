//
//  Location.swift
//  MyLocations
//
//  Created by Rachana Acharya on 8/7/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class Location: NSManagedObject {
    
    // the @NSManaged keyword tells the compiler that these resolve at runtime by Core Data
    @NSManaged var lattitude: Double
    @NSManaged var longitude: Double
    @NSManaged var locationDescription: String
    @NSManaged var category: String
    @NSManaged var placemark: CLPlacemark?
    @NSManaged var date: NSDate

}
