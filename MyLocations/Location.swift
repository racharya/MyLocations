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
import MapKit

class Location: NSManagedObject, MKAnnotation {
    
    // the @NSManaged keyword tells the compiler that these resolve at runtime by Core Data
    @NSManaged var lattitude: Double
    @NSManaged var longitude: Double
    @NSManaged var locationDescription: String
    @NSManaged var category: String
    @NSManaged var placemark: CLPlacemark?
    @NSManaged var date: NSDate
    @NSManaged var photoID: NSNumber?

    /* Conforming to MKAnnotation protocol */
    // all of the following variables are read-only computed properties : don't store a value in mem location
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(lattitude, longitude)
    }
    
    var title: String! {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }
    
    var subtitle: String {
        return category
    }
    /* end of MKAnnotation protocol */
    
    var hasPhoto: Bool {
        return photoID != nil
    }
    
    //computes full path to the JPEG file for the photo and save thes files inside app's documents directory
    var photoPath: String {
        assert(photoID != nil, "No photo ID set")// making sure photoID is not nil
        let filename = "Photo-\(photoID!.integerValue).jpg"
        return applicationDocumentsDirectory.stringByAppendingPathComponent(filename)
        
    }
    
    //returns UIImage obj by loading the image file. need this later to show the photos for existing Location objs
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoPath)
    }
}// end of Location class
