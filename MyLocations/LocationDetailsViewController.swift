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
    
    
    @IBAction func done() {
        println("Description '\(descriptionText)' ")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format:"%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = stringFromPlacemark(placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        dateLabel.text = formatDate(NSDate())
        
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