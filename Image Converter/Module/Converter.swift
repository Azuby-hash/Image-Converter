//
//  ImageConverter.swift
//  Image Converter
//
//  Created by TapUniverse Dev9 on 4/11/25.
//

import UIKit
import Photos

/// An enumeration to specify the source of metadata to be applied to a converted image.
enum ConvertSource {
    /// Use metadata from a PHAsset instance from the Photo library.
    case asset(PHAsset)
    /// Use metadata from a PHAsset data instance from the Photo library or URL data.
    case data(Data)
    /// Do not apply any additional metadata.
    case none
    
    func source() async -> CGImageSource? {
        switch self {
        case .data(let data):
            guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
                  CGImageSourceGetCount(imageSource) > 0 else {
                return nil
            }
            return imageSource
            
        case .asset(let asset):
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.version = .current
            
            // Use withCheckedContinuation to bridge the callback-based Photos API to async/await.
            return await withCheckedContinuation { continuation in
                PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                    guard let data = data,
                          let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
                          CGImageSourceGetCount(imageSource) > 0 else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    continuation.resume(returning: imageSource)
                }
            }
            
        case .none:
            return nil
        }
    }
    
    func extract() async -> [CFString: Any]? {
        switch self {
        case .data(let data):
            guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
                  CGImageSourceGetCount(imageSource) > 0 else {
                return nil
            }
            return CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any]
            
        case .asset(let asset):
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.version = .current
            
            // Use withCheckedContinuation to bridge the callback-based Photos API to async/await.
            return await withCheckedContinuation { continuation in
                PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                    guard let data = data,
                          let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
                          CGImageSourceGetCount(imageSource) > 0 else {
                        continuation.resume(returning: nil)
                        return
                    }
                    let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any]
                    continuation.resume(returning: properties)
                }
            }
            
        case .none:
            return nil
        }
    }
}


/// A utility for converting images from various sources to different formats using best practices.
/// This enum acts as a namespace for the static conversion methods and cannot be instantiated.
enum Converter {

    /// Describes errors that can occur during the image conversion process.
    enum ConversionError: Error, LocalizedError {
        case failedToAccessAssetData(Error?)
        case failedToCreateImageSource(String)
        case failedToCreateImageDestination
        case failedToFinalizeImage
        case pdfContextCreationFailed
        case sourceImageNotFound
        case unsupportedOutputFormat(String)

        var errorDescription: String? {
            switch self {
            case .failedToAccessAssetData(let underlyingError):
                return "Failed to access image data from the PHAsset. Underlying error: \(underlyingError?.localizedDescription ?? "Unknown error")."
            case .failedToCreateImageSource(let sourceDescription):
                return "Could not create an image source from the input: \(sourceDescription)."
            case .failedToCreateImageDestination:
                return "Could not create an image destination for the output file."
            case .failedToFinalizeImage:
                return "Failed to write the image data to the destination."
            case .pdfContextCreationFailed:
                return "Failed to create a PDF graphics context."
            case .sourceImageNotFound:
                return "The source contains no image data or failed to be read."
            case .unsupportedOutputFormat(let type):
                return "The output format '\(type)' is not supported by the current system."
            }
        }
    }

    // MARK: - JPEG Conversion

    /// Converts an image from a local file URL to JPEG format.
    /// - Parameters:
    ///   - sourceURL: The URL of the source image file.
    ///   - destinationURL: The URL where the converted JPEG file will be saved.
    ///   - compressionQuality: The quality of the resulting JPEG image, from 0.0 (lowest) to 1.0 (highest).
    static func convert(to utType: UTType, image: UIImage?, from sourceData: ConvertSource, compression: CGFloat) async throws -> Data {
        guard var options = await sourceData.extract(),
              let source = await sourceData.source() else {
            throw ConversionError.failedToCreateImageSource("PDF source invalid")
        }
        
        if utType == .pdf {
            return try performPDFConversion(image: image, from: source, options: options)
        }
        
        options[kCGImageDestinationLossyCompressionQuality] = compression
       
        return try performImageIOConversion(image: image, from: source, as: utType, options: options)
    }

    /// The core conversion function that takes a CGImageSource and writes to a destination using ImageIO.
    /// This approach is highly efficient as it avoids fully decoding and re-encoding image data into memory (e.g., a CGImage).
    /// It also preserves metadata and handles multi-frame images (like animated GIFs) correctly.
    private static func performImageIOConversion(image: UIImage?, from source: CGImageSource, as utType: UTType, options: [CFString: Any]) throws -> Data {
        let imageData = NSMutableData()
        
        guard let destination = CGImageDestinationCreateWithData(imageData, utType.identifier as CFString, 1, nil) else {
            // Error: Could not create the CGImageDestination.
            throw ConversionError.failedToCreateImageDestination
        }

        // Set properties for the destination, such as compression quality.
        CGImageDestinationSetProperties(destination, options as CFDictionary)

        if let image = image?.cgImage {
            CGImageDestinationAddImage(destination, image, nil)
        } else {
            let frameCount = CGImageSourceGetCount(source)
            guard frameCount > 0 else {
                throw ConversionError.sourceImageNotFound
            }
            
            // Iterate through all frames in the source image and add them to the destination.
            for i in 0..<frameCount {
                // Passing nil for the properties dictionary copies the frame's original properties.
                CGImageDestinationAddImageFromSource(destination, source, i, nil)
            }
        }

        if !CGImageDestinationFinalize(destination) {
            throw ConversionError.failedToFinalizeImage
        }
        
        return imageData as Data
    }

    /// The core PDF conversion function using CoreGraphics.
    private static func performPDFConversion(image: UIImage?, from source: CGImageSource, options: [CFString: Any]) throws -> Data {
        guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = imageProperties[kCGImagePropertyPixelWidth] as? CGFloat,
              let height = imageProperties[kCGImagePropertyPixelHeight] as? CGFloat else {
            throw ConversionError.sourceImageNotFound
        }

        let pdfRect = CGRect(x: 0, y: 0, width: width, height: height)
        var mediaBox = pdfRect
        
        let imageData = NSMutableData()
        
        guard let consumer = CGDataConsumer(data: imageData) else {
            throw ConversionError.failedToCreateImageDestination
        }
        
        guard let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            throw ConversionError.pdfContextCreationFailed
        }

        guard let image = image?.cgImage ?? CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw ConversionError.sourceImageNotFound
        }

        pdfContext.beginPDFPage(nil)
        pdfContext.draw(image, in: pdfRect)
        pdfContext.endPDFPage()
        pdfContext.closePDF()
        
        guard let destination = CGImageDestinationCreateWithData(imageData, UTType.pdf.identifier as CFString, 1, nil) else {
            // Error: Could not create the CGImageDestination.
            throw ConversionError.failedToCreateImageDestination
        }

        // Set properties for the destination, such as compression quality.
        CGImageDestinationSetProperties(destination, options as CFDictionary)
        
        return imageData as Data
    }

    // MARK: - Private Helpers

    /// Asynchronously requests the original, full-quality image data for a given `PHAsset`.
    private static func requestImageData(for asset: PHAsset) async throws -> Data {
        let options = PHImageRequestOptions()
        options.version = .original
        options.isNetworkAccessAllowed = true // Allow downloading from iCloud if necessary

        return try await withCheckedThrowingContinuation { continuation in
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, _, info in
                if let data = data {
                    continuation.resume(returning: data)
                } else {
                    let error = info?[PHImageErrorKey] as? Error
                    continuation.resume(throwing: ConversionError.failedToAccessAssetData(error))
                }
            }
        }
    }
}

/// A helper extension to check if a UTType is supported for writing by ImageIO.
fileprivate extension UTType {
    var isSupportedByImageIO: Bool {
        guard let supportedTypes = CGImageDestinationCopyTypeIdentifiers() as? [String] else {
            return false
        }
        return supportedTypes.contains(self.identifier)
    }
}
