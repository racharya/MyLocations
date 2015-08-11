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
    
    //calls regionForAnnotations() to calculate reasonable region that fits all the 
    //Location objs and then sets that region on the map view
    @IBAction func showLocations() {
        let region = regionForAnnotations(locations)
        mapView.setRegion(region, animated: true)
        
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
        //show user's location by default the first time
        if !locations.isEmpty {
            showLocations()
        }
    }
    
    func regionForAnnotations(annotations: [MKAnnotation]) -> MKCoordinateRegion {
        var region: MKCoordinateRegion
        
        switch annotations.count {
            //if no annotation, center the map on the user curr position
        case 0:
            region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
            //If 1 annotation, center the map on that one annotation
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
            //if 2 or more annotation, calculate the extent of their reach and add a little padding
        default:
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            for annotation in annotations {
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude,annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D( latitude: topLeftCoord.latitude -
                (topLeftCoord.latitude - bottomRightCoord.latitude) / 2, longitude: topLeftCoord.longitude -          (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
            
            let extraSpace = 1.1
            let span = MKCoordinateSpan(
                latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace,
                longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
            region = MKCoordinateRegion(center: center, span: span)
        }
        return mapView.regionThatFits(region)
    }
    
    func showLocationDetails(sender: UIButton){
                    
    }
}//end of MapViewController class

extension MapViewController: MKMapViewDelegate {
                    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
            //1. Determines if annotation is really a Location obj
            if annotation is Location {
                //2. Ask map view to reuse an annotation view object, if no recyclable then create a new one
                let identifier = "Location"
                var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as! MKPinAnnotationView!
                if annotationView == nil {
                        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                        //3. sets some properties to configure the look and feel of the annotation view
                        annotationView.enabled = true
                        annotationView.canShowCallout = true
                        annotationView.animatesDrop = false
                        annotationView.pinColor = .Green
                        
                        //4.create new UIButton that looks like a detail disclosure button (blue circled i, or info button).
                        // Hook up button event to a new showLocationDetails() method and add the button to the 
                        // annotation view's accessory view
                        let rightButton = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
                        rightButton.addTarget(self, action: Selector("showLocationDetails:"), forControlEvents: .TouchUpInside)
                        annotationView.rightCalloutAccessoryView = rightButton
                    } else {
                        annotationView.annotation = annotation
        }
        //5. obtain a reference to the detail disclosure button again and sets its tag to the index of location obj in the location array
        let button = annotationView.rightCalloutAccessoryView as! UIButton
        if let index = find(locations, annotation as! Location) {
                            button.tag = index
        }
        return annotationView
        
            }
            return nil
                    }
                    
        
                    
}// end of MKMapViewDelegate
