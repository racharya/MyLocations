//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Rachana Acharya on 8/5/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import Foundation
import UIKit
class CategoryPickerViewController: UITableViewController {
    var selectedCategoryName = " "
    let categories = [ "No Category", "Apple Store", "Bar", "Bookstore", "Club",
    "Grocery Store", "Historic Building", "House",
    "Icecream Vendor", "Landmark", "Park"]
    
    var selectedIndexPath = NSIndexPath()
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        let categoryName = categories[indexPath.row]
        cell.textLabel!.text = categoryName
        
        if categoryName == selectedCategoryName {
        cell.accessoryType = .Checkmark
        selectedIndexPath = indexPath
        
    } else {
        cell.accessoryType = .None
        }
        return cell
    }
    
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != selectedIndexPath.row {
        if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
        newCell.accessoryType = .Checkmark }
        if let oldCell = tableView.cellForRowAtIndexPath( selectedIndexPath) {
        oldCell.accessoryType = .None }
        selectedIndexPath = indexPath }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPathForCell(cell) {
            selectedCategoryName = categories[indexPath.row]
            }
        }
    }// end of delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .White
    }
   
    override func tableView(tableView: UITableView , willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
            cell.backgroundColor = UIColor.blackColor()
            if let textLabel = cell.textLabel {
                textLabel.textColor = UIColor.whiteColor()
                textLabel.highlightedTextColor = textLabel.textColor
            }
            
            let selectionView = UIView(frame: CGRect.zeroRect)
            selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
            cell.selectedBackgroundView = selectionView
            
    }
}

