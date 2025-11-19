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

let PREVIEW_WIDTH: CGFloat = 512
let PREVIEW_SIZE: CGSize = CGSize(width: 512, height: 512)
let DEFAULT_MIME: ConvertMime = .jpg
let DEFAULT_COMPRESSION: CGFloat = 1
