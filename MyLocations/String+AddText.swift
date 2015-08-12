//
//  String+AddText.swift
//  MyLocations
//
//  Created by Rachana Acharya on 8/12/15.
//  Copyright (c) 2015 Rachana Acharya. All rights reserved.
//

import Foundation

extension String {
    
    mutating func addText(text: String?,withSeparator separator: String = " ") {
        
        if let text = text {
        if !isEmpty {
            self += separator
        }
        self += text
        }
    }
}