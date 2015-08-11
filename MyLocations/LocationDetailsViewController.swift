//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Rachana Acharya on 8/4/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

//This is a private global constant that is only visible to this class but lives outside of this class
// closure implemented to create object and set its properties in one go
private let dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .MediumStyle
    formatter.timeStyle = .ShortStyle
    return formatter
    }()// if () is left out then dateFormatter will contain block of code and not an actual NSDateFormatter object
//with () in place, the code inside {} are run

class LocationDetailsViewController: UITableViewController {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude:0, longitude:0)// CLLocationCoordinate2D is a struct
    var placemark: CLPlacemark?
    
    var descriptionText = ""
    
    var categoryName = "No Category" //temporarily stores the chosen category
    
    var managedObjectContext: NSManagedObjectContext!
    
    var date = NSDate() // to store current date in the new Location Object
    
    var locationToEdit: Location? {
        //didSet is called before viewDidLoad()
        didSet { // taking the opportunity to fill in the view controller's instance variable with the Location object's values
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.lattitude, location.longitude)
                placemark = location.placemark
            }
        }
    }
    
    
    @IBAction func done() {
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        
        var location: Location
        if let temp = locationToEdit {
            hudView.text = "Updated"
            location = temp
        } else {// asking Core Data for a new Location of don't already have one
            hudView.text = "Tagged"
            //1. create a new location object. Different because its a Core Data managed object
            // ask NSEntitySescription class to insert a new object for your entity into the managed object context
            location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: managedObjectContext) as! Location
        }
         
        //2. Once Location object is created, set its properties to what user entered in the screen
        location.locationDescription = descriptionText
        location.category = categoryName
        location.lattitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        //3. saving the context
        var error: NSError?
        if !managedObjectContext.save(&error) {//&error is output parameter: returns value to the caller
//            println("Error: \(error)")
//            abort() // immediatedly kill the app and return to user springboard
            fatalCoreDataError(error)
            return
        }
        
        //trailing closure syntax: can put a closure behind the function call if it's the last parameter
        afterDelay(0.6) { self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // checks whether locationToEdit is set,if not nil we are editing an existing Location Obj
        if let location = locationToEdit {
            title = "Edit Location" //title of the screen becomes "Edit Location"
        }
        
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format:"%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = stringFromPlacemark(placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        dateLabel.text = formatDate(date)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        return
            "\(placemark.subThoroughfare) \(placemark.thoroughfare), " +
            "\(placemark.locality), " +
            "\(placemark.administrativeArea) \(placemark.postalCode)," +
        "\(placemark.country)"
    }
    
    func formatDate(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
    
    
    // MARK: - UITableViewDelegate
    //called by table view when it loads its cells
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
        return 88
    } else if indexPath.section == 2 && indexPath.row == 2 {
        //1. changes width of label to 155 points less then width of the screen and height is set at 10000
        addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
        //2. resizing to fit after word wrap, removes extra spaces
        addressLabel.sizeToFit()
        
        //3. placing label against  the right edge of the screen  with a 15 point margin between them
        addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width-15
        
        //4. adding 10 points margin at top and bottom each and then calculating full height of the cell
        return addressLabel.frame.size.height + 20
    } else {
        return 44
        }
    }
    
    //limits taps to just the cells from the first two sections
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    //handles the actual taps on the rows
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
    } // End of UITableViewDelegate
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
   // unwind action method for segue
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
        let controller = segue.sourceViewController as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }
    
    //fixing textview frame size to work on any device
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        descriptionTextView.frame.size.width = view.frame.size.width - 30 // 15 points margin on left and right side
    }
}//end of LocationDetailsViewController class

extension LocationDetailsViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    descriptionText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
    return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        descriptionText = textView.text
    }
}

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //create a UIImagePickerController instance, set its properties to configure the picker, set its delegate, and then present it
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    //delegate methods
    //currently delegate methods simply remove the image picker from the screen
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[NSObject: AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }//end of delegate methods
}// end of extension