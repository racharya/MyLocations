//
//  MyImagePickerController.swift
//  MyLocations
//
//  Created by Rachana Acharya on 8/12/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import Foundation
import UIKit

//use this class to pick a photo
class MyImagePickerController: UIImagePickerController {
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
    }
}
