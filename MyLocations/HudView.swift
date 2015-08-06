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
        
        return hudView
    }

    override func drawRect(rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        let boxRect = CGRect(x: round((bounds.size.width - boxWidth)/2), y: round((bounds.size.height - boxHeight)/2), width: boxWidth, height: boxHeight)
        
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
    }
}
