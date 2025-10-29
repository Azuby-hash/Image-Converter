//
//  Convert.swift
//  Image Converter
//
//  Created by Azuby on 10/27/25.
//

import UIKit
import Photos

extension Model {
    static let convert = Convert()
}

class Convert {
    private var selecteds: [ConvertItem] = []
    
    fileprivate init() { }
    
    func getSelecteds() -> [ConvertItem] {
        return selecteds
    }
    
    func setSelecteds(_ selecteds: [ConvertItem]) {
        self.selecteds = selecteds
    }
}

class ConvertItem: Equatable {
    private let id = UUID().uuidString
    
    private var preview: Data?
    private var image: Data?
    private var asset: PHAsset?
    
    init(asset: PHAsset) {
        self.asset = asset
    }
    
    func getPreview(completion: @escaping (UIImage) -> Void) throws {
        if let asset = asset {
            AssetLibrary.shared.getUIImage(from: asset, size: PREVIEW_SIZE, quality: .opportunistic, resizeMode: .fast) { image in
                completion(image)
            }
            
            return
        }
        
        throw ConvertError.data("No preview")
    }
    
    func getAsset() -> PHAsset? {
        return asset
    }
    
    static func == (lhs: ConvertItem, rhs: ConvertItem) -> Bool {
        return lhs.id == rhs.id
    }
}

enum ConvertError: Error {
    case data(String)
}
