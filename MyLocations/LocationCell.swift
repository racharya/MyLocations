//
//  LocationCell.swift
//  MyLocations
//
//  Created by Rachana Acharya on 8/9/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    func configureForLocation(location: Location) {
        if location.locationDescription.isEmpty {
            descriptionLabel.text = "(No Description)"
        } else {
            descriptionLabel.text = location.locationDescription
        }
        
        if let placemark = location.placemark {
            var text = ""
            text.addText(placemark.subThoroughfare)
            text.addText(placemark.thoroughfare, withSeparator: " ")
            text.addText(placemark.locality, withSeparator: ", ")
            addressLabel.text = text
        } else {
            addressLabel.text = String(format: "Lat: %.8f", location.lattitude, location.longitude)
        }
        photoImageView.image = imageForLocation(location)
    }
    
    //returns either image from the Location or an empty placeholder image
    func imageForLocation(location: Location) -> UIImage {
        if location.hasPhoto {
            if let image = location.photoImage {
                return image.resizedImageWithBounds(CGSize(width: 52, height: 52))
            }
        }
        return UIImage(named: "No Photo")! // does not return an empty UIImage now
    }
    
    //invoked when UIKit loads the object from the storyboard. Ideal place to customize looks.
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.blackColor()
        descriptionLabel.textColor = UIColor.whiteColor()
        descriptionLabel.highlightedTextColor = descriptionLabel.textColor
        addressLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        addressLabel.highlightedTextColor = addressLabel.textColor
        
        //get rid of cell (in Locations tab) lighting up in bright color when tapped
        let selectionView = UIView(frame: CGRect.zeroRect)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        selectedBackgroundView = selectionView
        
        //gives the image view rouded corners to the image tumbnails
        photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2
        photoImageView.clipsToBounds = true
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
    }
}
