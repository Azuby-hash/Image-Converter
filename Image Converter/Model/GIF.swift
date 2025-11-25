//
//  GIF.swift
//  Image GIFer
//
//  Created by Azuby on 10/27/25.
//

import UIKit
import Photos
import ImageIO

extension Model {
    static let gif = GIF()
}

class GIF {
    private var selecteds: [GIFItem] = []
    private var compression: CGFloat = DEFAULT_COMPRESSION
    
    func resetToDefaults() {
        selecteds = []
        compression = DEFAULT_COMPRESSION
    }

    func getCompression() -> CGFloat {
        return compression
    }
    
    func getSelecteds() -> [GIFItem] {
        return selecteds
    }
    
    func setCompression(_ compression: CGFloat) {
        let oldCompression = self.compression
        self.compression = compression
    }
    
    func setSelecteds(_ selecteds: [GIFItem]) {
        let oldSelecteds = self.selecteds
        self.selecteds = selecteds
    }
}

class GIFItem: Equatable, Hashable {
    private let id = UUID().uuidString
    
    private var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func getPreview(completion: @escaping (UIImage) -> Void) throws {
        if let source = CGImageSourceCreateWithData(data as CFData, nil),
           let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceThumbnailMaxPixelSize: 300 as NSNumber
           ] as CFDictionary) {
            DispatchQueue.main.async {
                completion(UIImage(cgImage: cgImage))
            }
            return
        }
        
        throw GIFError.data("No preview")
    }
    
    func getData() -> Data? {
        return data
    }
    
    static func == (lhs: GIFItem, rhs: GIFItem) -> Bool {
        return lhs.id == rhs.id
    }
}

enum GIFError: Error {
    case data(String)
}
