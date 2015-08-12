//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Rachana Acharya on 8/2/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import UIKit
import CoreLocation //adds Core Location Framework to the project
import CoreData

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    let locationManager = CLLocationManager() // CLLocationManager is the object that gives us the GPS coordinates
    var location: CLLocation? //stores user's current location
    
    var updatingLocation = false
    var lastLocationError: NSError?
    
    let geocoder = CLGeocoder()// performs geocoding
    var placemark: CLPlacemark?// contains the address result
    var performingReverseGeocoding = false
    var lastGeocodingError: NSError?
    
    var timer: NSTimer?
    
    var managedObjectContext: NSManagedObjectContext!
    
    @IBAction func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authStatus == .Denied || authStatus == .Restricted {
            showLocationServicesDeniedAlert()
            return
        }
        if updatingLocation {
            startLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
        configureGetButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetButton()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //protocol method implementation
    //MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("didFailWithError \(error)")
        
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateLabels()
        configureGetButton()
    }
    
    func locationManager(manager:CLLocationManager!, didUpdateLocations locations:[AnyObject]!) {
        let newLocation = locations.last as! CLLocation
        println("didUpdateLocations \(newLocation)")
        
        //1 makes sure to give the latest location if user haven't moved much since last time
        // called cached result
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        //2 Horizontal Accuracy determiens if new readings are more accurate
        //than the previous ones
        //if horizontalAccuracy is < 0, ignore.
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        //improving this method so that it works in the actual device
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location{
            distance = newLocation.distanceFromLocation(location)
        }
        //3 determining if new reading is more useful
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            
            //4 clears out previous error if any and stores the new location
            lastLocationError = nil
            location = newLocation
            updateLabels()
            
            //5 if new location accuracy is equal or better than the desired accuracy, stop asking location
            //manager for updates
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                println("*** We're done!")
                stopLocationManager()
                configureGetButton()
                //improving code to run in real device
                if distance > 0 {//forces reverse geocoding for the final location even if the app
                    //is already currently performing another geocoding request
                    performingReverseGeocoding = false
                }
            }
            if !performingReverseGeocoding {
                println("*** Going to geocode")
                performingReverseGeocoding = true
                
                //use closure. things before "in" are the parameter and println is the closure body
                geocoder.reverseGeocodeLocation(location, completionHandler: {placemarks, error in
                    println("*** Found placemarks: \(placemarks), error: \(error)")
                    self.lastGeocodingError = error
                    if error == nil && !placemarks.isEmpty {
                        self.placemark = placemarks.last as? CLPlacemark
                    } else {
                        self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
            }
            //real improvement code.improving code to run in real device
        } else if distance  < 1.0 {
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            if timeInterval > 10 {
                println("*** Force done!")
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
    }//end of protocol method
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled",message: "Please enable location services for this app in Settings.", preferredStyle:.Alert)
        let okAction = UIAlertAction(title:"OK", style:.Default, handler: nil)
        
        alert.addAction(okAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format:"%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format:"%.8f", location.coordinate.longitude)
            tagButton.hidden = false
            messageLabel.text = " "
            
            if let placemark = placemark {
                addressLabel.text = stringFromPlacemark(placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
        } else {
            latitudeLabel.text = " "
            latitudeLabel.textColor = UIColor.redColor()
            longitudeLabel.text = " "
            longitudeLabel.textColor = UIColor.redColor()
            addressLabel.text = " "
            tagButton.hidden = true
            
            var statusMessage: String
            if let error = lastLocationError {
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
                
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
        }
    }
    
    func stopLocationManager() {
        if updatingLocation {
            //cancelling timer when the location manager is stopped before time-out fires
            if let timer = timer {
                timer.invalidate()
            }
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            //set up timer object which sends out "didTimeOut" msg to self after 60 secs
            //selector describes the name of the method
            timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("didTimeOut"), userInfo: nil, repeats: false)
        }
    }
    
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", forState: .Normal)
            
        } else {
            getButton.setTitle("Get My Location", forState: .Normal)
        }
    }
    
    func stringFromPlacemark(placemark : CLPlacemark) -> String {
        //1.
        var line1 = ""
        line1.addText(placemark.subThoroughfare)
        line1.addText(placemark.thoroughfare)
        
        var line2 = ""
        line2.addText(placemark.locality)
        line2.addText(placemark.administrativeArea)
        line2.addText(placemark.postalCode)
        
        //aligning text at the top
        if line1.isEmpty {
            return line2 + "\n "
        } else {
            return line1 + "\n" + line2
        }
    }
        
    
    // called after 1 min whether valid location or not
    func didTimeOut() {
        println("*** TIme out")
        //if no valid location, stop the location manager
        if location == nil {
            stopLocationManager()
            //error domain is not kCLErrorDomain because this error comes from within the app
            lastLocationError = NSError(domain:"MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
            configureGetButton()
        }
    }
    
    //passes coordinate and address from CurrentLocationViewController to LocationDetailsViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TagLocation" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
        }
    }
    
    func addText(text: String?, toLine line: String, withSeparator separator: String) -> String {
        var result = line
        if let text = text {
            if !line.isEmpty {
                result += separator
            }
            result += text
        }
        return result
    }
}//end of CurrentLocationViewController class

