//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Rachana Acharya on 8/12/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import Foundation
import UIKit

class MyTabBarController: UITabBarController {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent }
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
    return nil
    }
gs
}
