//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Rachana Acharya on 8/8/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    
    var locations = [Location]() //contains the list of Location objects
    
    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell") as! UITableViewCell
        
        let location = locations[indexPath.row]
        
        let descriptionLabel = cell.viewWithTag(100) as! UILabel
        descriptionLabel.text = location.locationDescription
        
        let addressLabel = cell.viewWithTag(101) as! UILabel
        if let placemark = location.placemark {
            addressLabel.text = "\(placemark.subThoroughfare) \(placemark.thoroughfare)," +
            "\(placemark.locality)"
        } else {
        addressLabel.text = " "
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //1. NSFetchRequest is the object that describes which objects we are going to fetch from the data store
        // to retrieve an object saved in data store, create a fetch request that describes the search parameters of the object
        let fetchRequest = NSFetchRequest()
        
        //2. tells the fetch request you are looking for entities
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity
        
        //3. tells the fetch request to sort on the date attribute in ascending order
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
       // fetch request complete
        
        //4.tell context to execute the fetch request
        var error: NSError?
        let foundObjects = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
        if foundObjects == nil {
            fatalCoreDataError(error)
            return
        }
        
        //5. if no error, assign the contents of the foundObjects array to the locations inst. var
        locations = foundObjects as! [Location]
    }
}
