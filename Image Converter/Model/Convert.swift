//
//  Convert.swift
//  Image Converter
//
//  Created by Azuby on 10/27/25.
//

import UIKit
import Photos
import ImageIO

extension Model {
    static let convert = Convert()
}

enum ConvertMime: String, CaseIterable {
    case jpg = "jpg"
    case png = "png"
    case heic = "heic"
    case pdf = "pdf"
    case gif = "gif"
    case ico = "ico"
    case tiff = "tiff"
    case bmp = "bmp"
    
    func getUTType() -> UTType {
        switch self {
            case .jpg: return .jpeg
            case .png: return .png
            case .heic: return .heic
            case .pdf: return .pdf
            case .gif: return .gif
            case .ico: return .ico
            case .tiff: return .tiff
            case .bmp: return .bmp
        }
    }
    
    static func supportCompression() -> [ConvertMime] {
        return [.jpg, .heic, .tiff]
    }
}

class Convert {
    private var selecteds: [ConvertItem] = []
    private var mimeType: ConvertMime = .jpg
    
    fileprivate init() { }
    
    func getMimeType() -> ConvertMime {
        return mimeType
    }
    
    func getSelecteds() -> [ConvertItem] {
        return selecteds
    }
    
    func setMimeType(_ mimeType: ConvertMime) {
        self.mimeType = mimeType
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
