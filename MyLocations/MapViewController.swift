//
//  MapViewController.swift
//  MyLocations
//
//  Created by Rachana Acharya on 8/10/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var managedObjectContext: NSManagedObjectContext!
    
    var locations = [Location]()
    
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    @IBAction func showLocations() {
        
    }
    
    //Use NSFetchedR...ller obj to handle all the fetching and automatic change detection
    func updateLocations() {
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        
        var error: NSError?
        let foundObjects = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
        
        if foundObjects == nil {
            fatalCoreDataError(error)
            return
        }
        mapView.removeAnnotations(locations)// remove the pins for old obj
        locations = foundObjects as! [Location]
        mapView.addAnnotations(locations) //add a pin for each location on the map
    }
    
   //fetches the Location obj and shows them on the map when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations()
    }
}//end of MapViewController class

extension MapViewController: MKMapViewDelegate {
    
}// end of MKMapViewDelegate
