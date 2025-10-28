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

class ConvertItem {
    private var preview: Data?
    private var image: Data?
    private var asset: PHAsset?
    
    init(asset: PHAsset) {
        AssetLibrary.shared.getUIImage(from: asset, size: PREVIEW_SIZE, quality: .opportunistic, resizeMode: .fast) { image in
            DispatchQueue.global(qos: .default).async { [self] in
                preview = image.pngData()
            }
        }
        
        AssetLibrary.shared.getUIImage(from: asset, quality: .highQualityFormat, resizeMode: .exact) { image in
            DispatchQueue.global(qos: .default).async { [self] in
                self.image = image.pngData()
            }
        }
        
        self.asset = asset
    }
    
    func getImage() throws -> UIImage {
        guard let data = image else {
            throw ConvertError.data("No image data")
        }
        
        guard let image = UIImage(data: data) else {
            throw ConvertError.data("Cant decode image")
        }
        
        return image
    }
    
    func getPreview() throws -> UIImage {
        guard let data = preview else {
            throw ConvertError.data("No preview data")
        }
        
        guard let preview = UIImage(data: data) else {
            throw ConvertError.data("Cant decode preview")
        }
        
        return preview
    }
    
    func getAsset() -> PHAsset? {
        return asset
    }
}

enum ConvertError: Error {
    case data(String)
}
