//
//  Functions.swift
//  MyLocations
//
//  Created by Rachana Acharya on 8/6/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import Foundation
import Dispatch // imports Grand Central Dispatch

// free function, not a method inside an object so can be used from anywhere in your code

//afterDelay simply passes this closure object along to dispatch_after() 
func afterDelay(seconds: Double, closure: () -> ()) {
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    dispatch_after(when, dispatch_get_main_queue(), closure)
}
