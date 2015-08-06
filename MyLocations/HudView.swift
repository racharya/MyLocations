//
//  HudView.swift
//  MyLocations
//
//  Created by Rachana Acharya on 8/6/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import UIKit

class HudView: UIView {
    var text = ""
    
    //this is convenience constructor
    class func hudInView(view: UIView, animated: Bool) -> HudView {
        //creates instance by calling init method inherited from UIView
        let hudView = HudView(frame:view.bounds)
        hudView.opaque = false
        
        view.addSubview(hudView)
        view.userInteractionEnabled = false
        
        hudView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        
        return hudView
    }

}
