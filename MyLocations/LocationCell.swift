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
            addressLabel.text = "\(placemark.subThoroughfare) \(placemark.thoroughfare)," +
            "\(placemark.locality)"
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
        return UIImage()
    }

}
