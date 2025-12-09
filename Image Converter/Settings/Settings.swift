//
//  HomeSettings.swift
//  Photo Stitch
//
//  Created by Azuby on 6/21/25.
//

import UIKit

class Settings: UIViewController {
    @IBAction func settings(_ sender: Any) {
        if let settingURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingURL)
        }
    }
    
    @IBAction func feedback(_ sender: Any) {
        let email = "azuby.dev@gmail.com"
        if let url = URL(string: "mailto:\(email)?subject=Image Converter Feedback") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func share(_ sender: Any) {
        if let url = URL(string: "https://apps.apple.com/us/app/image-converter/id6756318437") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func term(_ sender: Any) {
        if let url = URL(string: "https://azuby-hash.github.io/AzubyTerms/") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func privacy(_ sender: Any) {
        if let url = URL(string: "https://azuby-hash.github.io/AzubyPrivacy/") {
            UIApplication.shared.open(url)
        }
    }
}
