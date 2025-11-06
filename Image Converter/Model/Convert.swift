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
    case tiff = "tiff"
    case bmp = "bmp"
    
    func getUTType() -> UTType {
        switch self {
            case .jpg: return .jpeg
            case .png: return .png
            case .heic: return .heic
            case .pdf: return .pdf
            case .gif: return .gif
            case .tiff: return .tiff
            case .bmp: return .bmp
        }
    }
    
    static func supportCompression() -> [ConvertMime] {
        return [.jpg, .heic, .tiff]
    }
}

class ConvertQueue {
    fileprivate let completion: () async -> Void
    fileprivate let item: ConvertItem
    
    init(completion: @escaping () async -> Void, item: ConvertItem) {
        self.completion = completion
        self.item = item
    }
}

class Convert {
    private var selecteds: [ConvertItem] = []
    private var mimeType: ConvertMime = .jpg
    private var compression: CGFloat = 1.0
    
    private var queues: [ConvertQueue] = []
    
    fileprivate init() {
        var isBusy = false
        
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [self] timer in
            if isBusy { return }
            isBusy = true
            
            DispatchQueue.global(qos: .default).async { [self] in
                if !queues.isEmpty {
                    print("Process \(selecteds.firstIndex(of: queues[0].item)!)")
                    
                    Task {
                        await queues[0].completion()
                        
                        await MainActor.run {
                            queues.removeFirst()
                            
                            isBusy = false
                        }
                    }
                } else {
                    isBusy = false
                }
            }
        }
    }
    
    func getMimeType() -> ConvertMime {
        return mimeType
    }
    
    func getCompression() -> CGFloat {
        return compression
    }
    
    func getSelecteds() -> [ConvertItem] {
        return selecteds
    }
    
    func setMimeType(_ mimeType: ConvertMime) {
        let oldMimeType = self.mimeType
        self.mimeType = mimeType

        if oldMimeType != mimeType {
            queues.removeAll()
            queues.append(contentsOf: selecteds.map({ selected in
                return .init(completion: { [self] in
                    await selected.convert(to: mimeType, compression: compression)
                }, item: selected)
            }))
        }
    }
    
    func setCompression(_ compression: CGFloat) {
        let oldCompression = self.compression
        self.compression = compression
        
        if oldCompression != compression {
            queues.removeAll()
            queues.append(contentsOf: selecteds.map({ selected in
                return .init(completion: { [self] in
                    await selected.convert(to: mimeType, compression: compression)
                }, item: selected)
            }))
        }
    }
    
    func setSelecteds(_ selecteds: [ConvertItem]) {
        let oldSelecteds = self.selecteds
        self.selecteds = selecteds
        
        queues.removeAll(where: { !selecteds.contains($0.item) })
        queues.append(contentsOf: selecteds.filter({ !oldSelecteds.contains($0) }).map({ selected in
            return .init(completion: { [self] in
                await selected.convert(to: mimeType, compression: compression)
            }, item: selected)
        }))
    }
}

class ConvertItem: Equatable {
    private let id = UUID().uuidString
    
    private var image: Data?
    private var asset: PHAsset?
    private var url: URL?
    
    init(asset: PHAsset) {
        self.asset = asset
    }
    
    init(url: URL) {
        self.url = url
    }
    
    func getPreview(completion: @escaping (UIImage) -> Void) throws {
        if let asset = asset {
            AssetLibrary.shared.getUIImage(from: asset, size: PREVIEW_SIZE, quality: .opportunistic, resizeMode: .fast) { image in
                completion(image)
            }
            
            return
        }
        
        if let url = url,
           let source = CGImageSourceCreateWithURL(url as CFURL, nil),
           let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, nil) {
            completion(UIImage(cgImage: cgImage))
        }
        
        throw ConvertError.data("No preview")
    }
    
    func getAsset() -> PHAsset? {
        return asset
    }
    
    func getURL() -> URL? {
        return url
    }
    
    func convert(to mime: ConvertMime, compression: CGFloat) async {
        guard let fileExtension = mime.getUTType().preferredFilenameExtension else {
            return
        }

        let newUrl = FileManager.url(name: "\(id).\(fileExtension)")
        
        if let asset = asset {
            try? await Converter.convert(to: mime.getUTType(), from: asset, to: newUrl, compression: compression)
        }
        
        if let url = url {
            try? Converter.convert(to: mime.getUTType(), from: url, to: newUrl, compression: compression)
        }
    }
    
    static func == (lhs: ConvertItem, rhs: ConvertItem) -> Bool {
        return lhs.id == rhs.id
    }
}

enum ConvertError: Error {
    case data(String)
}
