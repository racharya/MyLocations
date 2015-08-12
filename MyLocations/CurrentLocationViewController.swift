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
import QuartzCore
import AudioToolbox

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
    
    @IBOutlet weak var latitudeTextLabel: UILabel!
    @IBOutlet weak var longitudeTextLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    var logoVisible = false
    
    var soundID: SystemSoundID = 0
    
    lazy var logoButton: UIButton = {
        let button = UIButton.buttonWithType(.Custom) as! UIButton
        button.setBackgroundImage(UIImage(named: "Logo"), forState: .Normal)
        button.sizeToFit()
        button.addTarget(self, action: Selector("getLocation"),forControlEvents: .TouchUpInside)
        button.center.x = CGRectGetMidX(self.view.bounds)
        button.center.y = 220
        return button }()
    
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
        //removes logo before starting location manager
        if logoVisible {
            hideLogoView()
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
        loadSoundEffect("Sound.caf")
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

                    if self.placemark == nil {
                    self.playSoundEffect()
                    }
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
            latitudeTextLabel.hidden = false
            longitudeTextLabel.hidden = false
            
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
                statusMessage = ""
                showLogoView()
            }
            messageLabel.text = statusMessage
            latitudeTextLabel.hidden = true
            longitudeTextLabel.hidden = true
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
    
    //adding spinner to show an activity
    func configureGetButton() {
        let spinnerTag = 1000
                
        if updatingLocation {
            getButton.setTitle("Stop", forState: .Normal)
            
        if view.viewWithTag(spinnerTag) == nil {
            let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
            spinner.center = messageLabel.center
            spinner.center.y += spinner.bounds.size.height/2 + 15
            spinner.startAnimating()
            spinner.tag = spinnerTag
            containerView.addSubview(spinner)
                }
            } else {
                getButton.setTitle("Get My Location", forState: .Normal)
            
            if let spinner = view.viewWithTag(spinnerTag) {
                spinner.removeFromSuperview()
            }
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
    //MARK: - Logo View
    //hides the container view so the labels disappear and puts logoButton obj on the screen
    func showLogoView() {
        if !logoVisible {
        logoVisible = true
        containerView.hidden = true
        view.addSubview(logoButton)
        }
    }
    
    // counterpart of showLogoView
    //creates 3 animations 
    //1) containerView is placed outside the screen and moved to the conter
    //2) the logo image view slides out of the screen
    //3) while sliding, rotates around its center
    func hideLogoView() {
            if !logoVisible { return }
            
            logoVisible = false
            containerView.hidden = false
            
            containerView.center.x = view.bounds.size.width * 2
            containerView.center.y = 40 + containerView.bounds.size.height / 2
            
            let centerX = CGRectGetMidX(view.bounds)
            
            let panelMover = CABasicAnimation(keyPath: "position")
            panelMover.removedOnCompletion = false
            panelMover.fillMode = kCAFillModeForwards
            panelMover.duration = 0.6
            panelMover.fromValue = NSValue(CGPoint: containerView.center)
            panelMover.toValue = NSValue(CGPoint: CGPoint(x: centerX, y: containerView.center.y))
            panelMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            
            panelMover.delegate = self
            containerView.layer.addAnimation(panelMover, forKey: "panelMover")
            
            let logoMover = CABasicAnimation(keyPath: "position")
            logoMover.removedOnCompletion = false
            logoMover.fillMode = kCAFillModeForwards
            logoMover.duration = 0.5
            logoMover.fromValue = NSValue(CGPoint: logoButton.center)
            logoMover.toValue = NSValue(CGPoint: CGPoint(x: -centerX, y: logoButton.center.y))
            logoMover.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            logoButton.layer.addAnimation(logoMover, forKey: "logoMover")
            
            let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
            logoRotator.removedOnCompletion = false
            logoRotator.fillMode = kCAFillModeForwards
            logoRotator.duration = 0.5
            logoRotator.fromValue = 0.0
            logoRotator.toValue = -2 * M_PI
            logoRotator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            logoButton.layer.addAnimation(logoRotator, forKey: "logoRotator")
    }
    
    //cleans up after the animations and removes the logo button
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
            containerView.layer.removeAllAnimations()
            containerView.center.x = view.bounds.size.width / 2
            containerView.center.y = 40 + containerView.bounds.size.height / 2
            
            logoButton.layer.removeAllAnimations()
            logoButton.removeFromSuperview()
    }
    
    // MARK: - Sound Effect
    //loads sound file and put it into a new sound object
    func loadSoundEffect(name: String) {
        if let path = NSBundle.mainBundle().pathForResource(name, ofType: nil) {
            let fileURL = NSURL.fileURLWithPath(path, isDirectory: false)
        if fileURL == nil {
            println("NSURL is nil for path: \(path)")
            return
        }
        let error = AudioServicesCreateSystemSoundID(fileURL, &soundID)
        if Int(error) != kAudioServicesNoError {
            println("Error code \(error) loading sound at path: \(path)")
            return
        }
      }
    }
    func unloadSoundEffect() {
        AudioServicesDisposeSystemSoundID(soundID)
        soundID = 0
    }
    func playSoundEffect() {
        AudioServicesPlaySystemSound(soundID)
    }
    
}//end of CurrentLocationViewController class

