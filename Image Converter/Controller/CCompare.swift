//
//  CCompare.swift
//  Image Converter
//
//  Created by Azuby on 11/15/25.
//

import UIKit
import Photos

enum CCompareError: Error {
    case ext(String)
    case get(String)
    case create(String)
    case upscale(String)
    case save(String)
}

extension UIView {
    var cCompare: CCompare {
        get { Controller.shared.cCompare }
    }
}

extension UIViewController {
    var cCompare: CCompare {
        get { Controller.shared.cCompare }
    }
}

extension CCompare {
    static let update = Notification.Name(UUID().uuidString)
}

class CCompare {
    private var first: CCompareItem?
    private var second: CCompareItem?
    
    func resetToDefaults() {
        first = nil
        second = nil
    }
    
    func getFirst() throws -> CCompareItem {
        guard let first = first else {
            throw CCompareError.get("No selected")
        }
        
        return first
    }
    
    func getSecond() throws -> CCompareItem {
        guard let second = second else {
            throw CCompareError.get("No selected")
        }
        
        return second
    }
    
    func selectItems(first: CCompareItem, second: CCompareItem) throws {
        self.first = first
        self.second = second
        
        NotificationCenter.default.post(name: CCompare.update, object: nil)
    }
}

class CCompareItem {
    let data: Data
    let date: Date
    let image: UIImage
    let name: String
    
    init(data: Data, date: Date, name: String) throws {
        guard let image = UIImage(data: data) else {
            throw CCompareError.create("Can't create item")
        }
        
        self.data = data
        self.date = date
        self.image = image
        self.name = name
    }
}
