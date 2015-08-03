//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Rachana Acharya on 8/2/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import UIKit
import CoreLocation //adds Core Location Framework to the project

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    let locationManager = CLLocationManager() // CLLocationManager is the object that gives us the GPS coordinates
    var location: CLLocation? //stores user's current location
    
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
        locationManager.delegate = self//view controller is the delegate
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
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
    }
    
    func locationManager(manager:CLLocationManager!, didUpdateLocations locations:[AnyObject]!) {
        let newLocation = locations.last as! CLLocation
        println("didUpdateLocations \(newLocation)")
        location = newLocation
        updateLabels()
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
        } else {
            latitudeLabel.text = " "
            latitudeLabel.textColor = UIColor.redColor()
            longitudeLabel.text = " "
            longitudeLabel.textColor = UIColor.redColor()
            addressLabel.text = " "
            tagButton.hidden = true
            messageLabel.text = "Tap 'Get Location' to Start"
        }
    }
}//end of CurrentLocationViewController class

