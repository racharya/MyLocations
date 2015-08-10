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
    
    //code in the closure does same thing that viewDidLoad() did
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 20 //how many objects are fetched at a time
        
        //once fetch request is set up, create the star of the show
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,managedObjectContext:self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "Locations")
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    //MARK: - UITableViewDataSource
    //Simply ask fetched results controller for the number of rows and return it
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell") as! LocationCell
        
        //ask fetchedResultsController for the obj at the requested index-path.NSFetched...troller knows how to deal
        //with index-paths
        let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
        cell.configureForLocation(location)
       
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performFetch()//still perform initial fetch here
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
                controller.locationToEdit = location
            }
        }
    }
    
    func performFetch() {
        var error: NSError?
        if !fetchedResultsController.performFetch(&error) {
            fatalCoreDataError(error)
        }
    }
    //explicitly setting delegate to nil when NSFetchedResultsController isn't needed
    // deinit is invoked when this view controller is destroyed
    deinit {
        fetchedResultsController.delegate = nil
    }
}// end of LocationsViewController class

//Implementing delegate methods for NSFetchedResultsController
extension LocationsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        println("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anyObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            println("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        case .Delete:
            println("*** NSFetchedResultsChangeDelegate (object)")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .Update:
            println("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? LocationCell {
                let location = controller.objectAtIndexPath(indexPath!) as! Location
                cell.configureForLocation(location)
            }
        case .Move:
            println("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
       
        switch type {
        case .Insert:
            println("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        case .Delete:
            println("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(NSIndexSet(index: sectionIndex),withRowAnimation: .Fade)
            
        case .Update:
            println("*** NSFetchedResultsChangeUpdate (section)")
        case .Move:
            println("*** NSFetchedResultsChangeMove (section)")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
                println("*** controllerDidChangeContent")
                tableView.endUpdates()
        
    }
    
    
} // end of NSFetchedResultsController delegate methods
