//
//  Config.swift
//  Image Converter
//
//  Created by Azuby on 10/23/25.
//

import UIKit

var IOS26: Bool {
    get {
        if #available(iOS 26, *) {
            return true
        }
        
        return false
    }
}
