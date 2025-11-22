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

extension UTType {
    func getMime() -> ConvertMime? {
        switch self {
            case .jpeg: return .jpg
            case .png: return .png
            case .heic: return .heic
            case .pdf: return .pdf
            case .gif: return .gif
            case .tiff: return .tiff
            case .bmp: return .bmp
            default: return nil
        }
    }
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
    
    func canCompression() -> Bool {
        return ConvertMime.supportCompression().contains(self)
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
    private var mimeType: ConvertMime = DEFAULT_MIME
    private var compression: CGFloat = DEFAULT_COMPRESSION
    
    private var keepInfo: Bool {
        get { UserDefaults.standard.object(forKey: "2b4dfb67-088e-461b-a36d-304d5586ebea") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "2b4dfb67-088e-461b-a36d-304d5586ebea") }
    }
    
    private var keepDate: Bool {
        get { UserDefaults.standard.object(forKey: "65cc9ab8-0b34-4a38-9ea1-7e72730111c5") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "65cc9ab8-0b34-4a38-9ea1-7e72730111c5") }
    }
    
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
                    if selecteds.contains(where: { $0.getOutput() == nil }) {
                        queues.append(contentsOf: selecteds.filter({ $0.getOutput() == nil }).map({ selected in
                            return .init(completion: { [self] in
                                await selected.convert(to: mimeType, compression: compression,
                                                       keepInfo: keepInfo, keepDate: keepDate)
                            }, item: selected)
                        }))
                    }
                    
                    isBusy = false
                }
            }
        }
    }
    
    func reset() {
        mimeType = DEFAULT_MIME
        compression = DEFAULT_COMPRESSION
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
    
    func isKeepInfo() -> Bool {
        return keepInfo
    }
    
    func isKeepDate() -> Bool {
        return keepDate
    }
    
    func setMimeType(_ mimeType: ConvertMime) {
        let oldMimeType = self.mimeType
        self.mimeType = mimeType

        if oldMimeType != mimeType {
            queues.removeAll()
            queues.append(contentsOf: selecteds.map({ selected in
                selected.reset()
                
                return .init(completion: { [self] in
                    await selected.convert(to: mimeType, compression: compression,
                                           keepInfo: keepInfo, keepDate: keepDate)
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
                selected.reset()
                
                return .init(completion: { [self] in
                    await selected.convert(to: mimeType, compression: compression,
                                           keepInfo: keepInfo, keepDate: keepDate)
                }, item: selected)
            }))
        }
    }
    
    func setSelecteds(_ selecteds: [ConvertItem]) {
        let oldSelecteds = self.selecteds
        self.selecteds = selecteds
        
        queues.removeAll(where: { !selecteds.contains($0.item) })
        queues.append(contentsOf: selecteds.filter({ !oldSelecteds.contains($0) }).map({ selected in
            selected.reset()
            
            return .init(completion: { [self] in
                await selected.convert(to: mimeType, compression: compression,
                                       keepInfo: keepInfo, keepDate: keepDate)
            }, item: selected)
        }))
    }
    
    func setKeepInfo(_ keep: Bool) {
        let oldKeepInfo = self.keepInfo
        self.keepInfo = keep
        
        if oldKeepInfo != keep {
            queues.removeAll()
            queues.append(contentsOf: selecteds.map({ selected in
                selected.reset()
                
                return .init(completion: { [self] in
                    await selected.convert(to: mimeType, compression: compression,
                                           keepInfo: keepInfo, keepDate: keepDate)
                }, item: selected)
            }))
        }
    }
    
    func setKeepDate(_ keep: Bool) {
        let oldKeepDate = self.keepDate
        self.keepDate = keep
        
        if oldKeepDate != keep {
            queues.removeAll()
            queues.append(contentsOf: selecteds.map({ selected in
                selected.reset()
                
                return .init(completion: { [self] in
                    await selected.convert(to: mimeType, compression: compression,
                                           keepInfo: keepInfo, keepDate: keepDate)
                }, item: selected)
            }))
        }
    }
}

class ConvertItem: Equatable, Hashable {
    private let id = UUID().uuidString
    
    private var data: Data
    private var output: URL?
    
    private let date: Date
    
    init(data: Data, date: Date) {
        self.data = data
        self.date = date
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func getPreview(completion: @escaping (UIImage) -> Void) throws {
        if let source = CGImageSourceCreateWithData(data as CFData, nil),
           let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, [kCGImageSourceCreateThumbnailWithTransform: true] as CFDictionary) {
            DispatchQueue.main.async {
                completion(UIImage(cgImage: cgImage))
            }
            return
        }
        
        throw ConvertError.data("No preview")
    }
    
    func getType(completion: @escaping (ConvertMime?) -> Void) throws {
        if let source = CGImageSourceCreateWithData(data as CFData, nil),
           let string = CGImageSourceGetType(source) as? String,
           let type = UTType(string) {
            DispatchQueue.main.async {
                completion(type.getMime())
            }
            return
        }
        
        throw ConvertError.data("No preview")
    }
    
    func getType() throws -> ConvertMime? {
        if let source = CGImageSourceCreateWithData(data as CFData, nil),
           let string = CGImageSourceGetType(source) as? String,
           let type = UTType(string) {
            return type.getMime()
        }
        
        throw ConvertError.data("No preview")
    }
    
    func getData() -> Data? {
        return data
    }
    
    func getOutput() -> URL? {
        return output
    }
    
    func reset() {
        output = nil
    }
    
    func convert(to mime: ConvertMime, compression: CGFloat, keepInfo: Bool, keepDate: Bool) async {
        do {
            for type in ConvertMime.allCases {
                if let fileExtension = type.getUTType().preferredFilenameExtension {
                    FileManager.remove(forKey: "\(id).\(fileExtension)")
                }
            }
            
            guard let fileExtension = mime.getUTType().preferredFilenameExtension else {
                throw ConvertError.data("No file extension")
            }
            
            var url = FileManager.url(name: "\(id).\(fileExtension)")
            
            try Converter.convert(to: mime.getUTType(), image: nil, from: data, creationDate: keepDate ? .date(date) : .now, output: &url, info: keepInfo, compression: compression, orientation: true)
            
            output = url
        } catch {
            print(error)
        }
    }
    
    static func == (lhs: ConvertItem, rhs: ConvertItem) -> Bool {
        return lhs.id == rhs.id
    }
}

enum ConvertError: Error {
    case data(String)
}
