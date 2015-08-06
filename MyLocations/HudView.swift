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
        
        hudView.showAnimated(animated)
        return hudView
    }

    override func drawRect(rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        let boxRect = CGRect(x: round((bounds.size.width - boxWidth)/2), y: round((bounds.size.height - boxHeight)/2), width: boxWidth, height: boxHeight)
        
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        //loading the checkmark image into a UIImage object then calculating position to draw the image there
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(x: center.x - round(image.size.width / 2), y: center.y - round(image.size.height / 2) - boxHeight / 8)
            image.drawAtPoint(imagePoint)
        }
        // Creating own text drawing
        // step 1) find out how big the text is so you can figure out where to position it
        // step 2) create UIFont object and foreground color into a dictionary named attribs
        // step 3) use attribs to calculate how wide and tall the text will be
        // step 4) calculate and draw it
        let attribs = [NSFontAttributeName: UIFont.systemFontOfSize(16.0), NSForegroundColorAttributeName: UIColor.whiteColor()]
        let textSize = text.sizeWithAttributes(attribs)
        
        let textPoint = CGPoint(x: center.x - round(textSize.width / 2), y: center.y - round(textSize.height / 2) + boxHeight / 4)
        text.drawAtPoint(textPoint, withAttributes: attribs)
    }
   // animation for HUD
    func showAnimated(animated: Bool) {
        if animated {
            //1. set up initial state of the view before animation starts
            alpha = 0 // fully transparent
            transform = CGAffineTransformMakeScale(1.3, 1.3)// view initially stretched out
            //2. sets up an animation, closure describes animation
            UIView.animateWithDuration(0.3, animations: {
                //3. set up new state of the view that it should have after the animation completes
                self.alpha = 1 // fully opaque
                self.transform = CGAffineTransformIdentity//restores scale back to normal, use self due to part of closure
            })
        }
    }
}
