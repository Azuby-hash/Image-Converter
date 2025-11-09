//
//  ImageConverter.swift
//  Image Converter
//
//  Created by TapUniverse Dev9 on 4/11/25.
//

import UIKit
import Photos

protocol Output { }
extension NSMutableData: Output { }
extension URL: Output { }

enum ConverterDate {
    case date(Date)
    case pass
    case current
}

/// A utility for converting images from various sources to different formats using best practices.
/// This enum acts as a namespace for the static conversion methods and cannot be instantiated.
class Converter {

    /// Describes errors that can occur during the image conversion process.
    enum ConversionError: Error, LocalizedError {
        case failedToCreateImageSource(String)
        case failedToCreateImageDestination
        case failedToFinalizeImage
        case pdfContextCreationFailed
        case sourceImageNotFound
    }

    // MARK: - JPEG Conversion

    /// Converts an image from a local file URL to JPEG format.
    /// - Parameters:
    ///   - sourceURL: The URL of the source image file.
    ///   - destinationURL: The URL where the converted JPEG file will be saved.
    ///   - compressionQuality: The quality of the resulting JPEG image, from 0.0 (lowest) to 1.0 (highest).
    static func convert<T: Output>(to utType: UTType, image: UIImage?, from sourceData: Data, creationDate: ConverterDate, output: T, compression: CGFloat) throws {

        guard let source = CGImageSourceCreateWithData(sourceData as CFData, nil) else {
            throw ConversionError.failedToCreateImageSource("Image source invalid")
        }
        
        var options = [CFString: Any]()
        var i = 0
        
        while let props = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [CFString: Any] {
            props.keys.forEach { key in
                options[key] = props[key]
            }
            
            i += 1
        }
        
//        if var tiff = options["{TIFF}" as CFString] as? [CFString: Any] {
//            tiff.removeValue(forKey: "Orientation" as CFString)
//            options["{TIFF}" as CFString] = tiff
//        }
//        
//        options.removeValue(forKey: kCGImagePropertyOrientation)
//        options.removeValue(forKey: kCGImageDestinationOrientation)
//        options.removeValue(forKey: kCGImagePropertyTIFFOrientation)
        
        if case .date(let date) = creationDate {
            options[kCGImageDestinationDateTime] = date
            options[kCGImagePropertyTIFFDateTime] = date
            options[kCGImagePropertyExifDateTimeOriginal] = date
            options[kCGImagePropertyExifDateTimeDigitized] = date
        } else if case .current = creationDate {
            options[kCGImageDestinationDateTime] = Date.now
            options[kCGImagePropertyTIFFDateTime] = Date.now
            options[kCGImagePropertyExifDateTimeOriginal] = Date.now
            options[kCGImagePropertyExifDateTimeDigitized] = Date.now
        }
        
        let destination: CGImageDestination
        
        if let output = output as? NSMutableData {
            if let dest = CGImageDestinationCreateWithData(output, utType.identifier as CFString, 1, nil) {
                destination = dest
            } else {
                throw ConversionError.failedToCreateImageDestination
            }
        } else if let output = output as? URL {
            if let dest = CGImageDestinationCreateWithURL(output as CFURL, utType.identifier as CFString, 1, nil) {
                destination = dest
            } else {
                throw ConversionError.failedToCreateImageDestination
            }
        } else {
            throw ConversionError.failedToCreateImageDestination
        }

        if utType == .pdf {
            try performPDFConversion(image: image, from: source, to: destination, output: output, options: options)
            
            return
        }
        
        options[kCGImageDestinationLossyCompressionQuality] = compression
       
        try performImageIOConversion(image: image, from: source, to: destination, as: utType, options: options)
        
        return
    }

    /// The core conversion function that takes a CGImageSource and writes to a destination using ImageIO.
    /// This approach is highly efficient as it avoids fully decoding and re-encoding image data into memory (e.g., a CGImage).
    /// It also preserves metadata and handles multi-frame images (like animated GIFs) correctly.
    private static func performImageIOConversion(image: UIImage?, from source: CGImageSource, to destination: CGImageDestination, as utType: UTType, options: [CFString: Any]) throws {
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
    }

    /// The core PDF conversion function using CoreGraphics.
    private static func performPDFConversion<T: Output>(image: UIImage?, from source: CGImageSource, to destination: CGImageDestination, output: T, options: [CFString: Any]) throws {
        guard let image = image?.cgImage ?? CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw ConversionError.sourceImageNotFound
        }

        let pdfRect = CGRect(x: 0, y: 0, width: image.width, height: image.height)
        var mediaBox = pdfRect

        let consumer: CGDataConsumer
        
        if let output = output as? NSMutableData {
            if let con = CGDataConsumer(data: output) {
                consumer = con
            } else {
                throw ConversionError.pdfContextCreationFailed
            }
        } else if let output = output as? URL {
            if let con = CGDataConsumer(url: output as CFURL) {
                consumer = con
            } else {
                throw ConversionError.pdfContextCreationFailed
            }
        } else {
            throw ConversionError.pdfContextCreationFailed
        }
        
        guard let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            throw ConversionError.pdfContextCreationFailed
        }
        
        pdfContext.beginPDFPage(nil)
        pdfContext.draw(image, in: pdfRect)
        pdfContext.endPDFPage()
        pdfContext.closePDF()
        
        // Set properties for the destination, such as compression quality.
        CGImageDestinationSetProperties(destination, options as CFDictionary)
        CGImageDestinationAddImage(destination, image, nil)
        
        if !CGImageDestinationFinalize(destination) {
            throw ConversionError.failedToFinalizeImage
        }
    }
}
