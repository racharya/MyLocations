//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Rachana Acharya on 8/2/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import UIKit
import CoreData

//defining global function for handling fatal Core Data errors
let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"
func fatalCoreDataError(error: NSError?) {
    if let error = error {
        println("*** Fatal error: \(error), \(error.userInfo)")
    }
    NSNotificationCenter.defaultCenter().postNotificationName(MyManagedObjectContextSaveDidFailNotification, object: error)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // code to load the data model and to connect to an SQLite data store
    lazy var managedObjectContext: NSManagedObjectContext = {
        
        //To create an NSManagedObjectContext, need to do several things:
        //1. NSURL object points to the folder name DataModel.momd == where CoreData model is stored
        if let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd") {
            
            //2. Create an NSManagedObjectModel from the URL. This obj reps the data model during runtime
            if let model = NSManagedObjectModel(contentsOfURL: modelURL) {
                
                //3. Create an NSPersistentStoreCoordinator object == is in charge of the SQLite database
                let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
                
                //4. The app data is stored in SQLite database inside the app's Documents folder, here we create
                // an NSURL object pointing at that DataStore.sqlite file.
                let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
                
                let documentsDirectory = urls[0] as! NSURL
                let storeURL = documentsDirectory.URLByAppendingPathComponent("DataStore.sqlite")
                println(storeURL)
                
                //5. Add the SQLite database to the store coordinator
                var error: NSError?
                if let store = coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) {
                    
                    //6. finally create the NSManagedObjectContext obj and return it
                    let context = NSManagedObjectContext()
                    context.persistentStoreCoordinator = coordinator
                    return context
                    
                    //7.if something went wrong, then print an error message and abort the app
                } else {
                    println("Error adding persistent store at \(storeURL): \(error!)")
                }
            } else {
                println("Error initializing model from: \(modelURL)")
            }
        } else {
            println("Could not find data model in app bundle")
        }
        abort()
        }() //end of code to load the data model
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // in order to get a reference to the CurrentLocationViewController you first have to find the 
        // UITabBarController and then look at its viewControllers array
        let tabBarController = window!.rootViewController as! UITabBarController
        if let tabBarViewControllers = tabBarController.viewControllers {
            let navigationController = tabBarViewControllers[1] as! UINavigationController
            let locationsViewController = navigationController.viewControllers[0] as! LocationsViewController
            locationsViewController.managedObjectContext = managedObjectContext
            
            let currentLocationViewController = tabBarViewControllers[0] as! CurrentLocationViewController
            //one we have reference to the CurrentLoationViewController object, we give it the managedObjectContext
            currentLocationViewController.managedObjectContext = managedObjectContext
        }
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
   
    func listenForFatalCoreDataNotifications() {
        //1.  Tell NSNotificationCenter that you want to be notified whenever a MyManaged...FailNotification is posted.
        // Actual code permored is in the closure
        NSNotificationCenter.defaultCenter().addObserverForName(MyManagedObjectContextSaveDidFailNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { notification in
            
            //2. Create a UIAlertController to show the error message
            let alert = UIAlertController(title: "Internal Error", message: "There was a fatal error in the app and it cannot continue.\n\n" + "Press OK to terminate the app. Sorry for the inconvenience.", preferredStyle: .Alert)
            
            //3. Add action for the alert's OK button. Code for handling button press is again a closure
            let action = UIAlertAction(title: "OK", style: .Default) { _ in
                let exception = NSException(name: NSInternalInconsistencyException, reason: "Fatal Core Data error", userInfo: nil)
                exception.raise()
            }
            alert.addAction(action)
            
            //4. Present the alert
            self.viewControllerForShowingAlert().presentViewController(alert, animated: true, completion:nil)
        })
    }
    
    //5. To show the alert , need a view controller that is currently visible
    func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController = self.window!.rootViewController!
        if let presentedViewController = rootViewController.presentedViewController {
            return presentedViewController
        } else {
            return rootViewController
        }
    }
}

