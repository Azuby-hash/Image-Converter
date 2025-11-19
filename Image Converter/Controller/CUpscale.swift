//
//  CUpscale.swift
//  Image Converter
//
//  Created by Azuby on 11/15/25.
//

import UIKit
import Photos

enum CUpscaleError: Error {
    case ext(String)
    case get(String)
    case create(String)
    case upscale(String)
    case save(String)
}

extension UIView {
    var cUpscale: CUpscale {
        get { Controller.shared.cUpscale }
    }
}

extension UIViewController {
    var cUpscale: CUpscale {
        get { Controller.shared.cUpscale }
    }
}

extension CUpscale {
    static let update = Notification.Name(UUID().uuidString)
}

class CUpscale {
    private var selected: CUpscaleItem?
    
    private let id = UUID().uuidString
    
    func resetToDefaults() {
        selected = nil
    }
    
    func getInputImage() throws -> UIImage {
        guard let selected = selected else {
            throw CUpscaleError.get("No selected")
        }
        
        return selected.image
    }
    
    func getOutputImage() throws -> UIImage {
        guard let fileExtension = try selected?.getType().preferredFilenameExtension else {
            throw CUpscaleError.ext("No file extension")
        }
        
        guard let data = FileManager.object(forKey: "\(id).\(fileExtension)") as? Data else {
            throw CUpscaleError.get("No data")
        }
        
        guard let image = UIImage(data: data) else {
            throw CUpscaleError.get("Image data is invalid.")
        }
        
        return image
    }
    
    func getOutput() throws -> URL {
        guard let fileExtension = try selected?.getType().preferredFilenameExtension else {
            throw CUpscaleError.ext("No file extension")
        }
        
        let url = FileManager.url(name: "\(id).\(fileExtension)")
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw CUpscaleError.ext("File not exist")
        }
        
        return url
    }
    
    func selectItem(data: Data, date: Date) throws {
        self.selected = try CUpscaleItem(data: data, date: date)
        NotificationCenter.default.post(name: CUpscale.update, object: nil)
    }
    
    func upscale() throws {
        guard let selected = selected else {
            throw CUpscaleError.upscale("No selected.")
        }
        
        let upscale = try ModelUpscale.shared.inference(image: selected.image)
        
        guard let fileExtension = try selected.getType().preferredFilenameExtension else {
            throw CUpscaleError.ext("No file extension")
        }
        
        var url = FileManager.url(name: "\(id).\(fileExtension)")
        
        try Converter.convert(to: try selected.getType(), image: upscale, from: selected.data, creationDate: .now, output: &url, info: true, compression: 1, orientation: true)
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: CUpscale.update, object: nil)
        }
    }
    
    func save(view: UIView, toPhotos: @escaping () -> Void) throws {
        guard let fileExtension = try selected?.getType().preferredFilenameExtension else {
            throw CUpscaleError.ext("No file extension")
        }
        
        let url = FileManager.url(name: "\(id).\(fileExtension)")
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw CUpscaleError.save("Upscale failed.")
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
        }) { success, error in
            if !success {
                print(error!)
            }
            
            toPhotos()
        }
    }
}

class CUpscaleItem {
    let data: Data
    let date: Date
    let image: UIImage
    
    init(data: Data, date: Date) throws {
        guard let image = UIImage(data: data) else {
            throw CUpscaleError.create("Can't create item")
        }
        
        self.data = data
        self.date = date
        self.image = image
    }
    
    func getType() throws -> UTType {
        if let source = CGImageSourceCreateWithData(data as CFData, nil),
           let string = CGImageSourceGetType(source) as? String,
           let type = UTType(string) {

            return type
        }
        
        throw ConvertError.data("No preview")
    }
}
