//
//  ImageConverter.swift
//  Image Converter
//
//  Created by TapUniverse Dev9 on 4/11/25.
//

import UIKit
import Photos

enum ConverterDate {
    case date(Date)
    case now
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
    static func convert(to utType: UTType, image: UIImage?, from sourceData: Data, creationDate: ConverterDate, output: inout URL, compression: CGFloat) throws {

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
        
        var resourceValues = URLResourceValues()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        
        let dateTimeString: String
        
        if case .date(let date) = creationDate {
            dateTimeString = dateFormatter.string(from: date)

            resourceValues.creationDate = date
            resourceValues.contentModificationDate = date
        } else {
            dateTimeString = dateFormatter.string(from: Date.now)

            resourceValues.creationDate = Date.now
            resourceValues.contentModificationDate = Date.now
        }
        
        if var tiffProperties = options[kCGImagePropertyTIFFDictionary] as? [CFString: Any] {
            tiffProperties[kCGImagePropertyTIFFDateTime] = dateTimeString as CFString
            options[kCGImagePropertyTIFFDictionary] = tiffProperties as CFDictionary
        }
        
        if var exifProperties = options[kCGImagePropertyExifDictionary] as? [CFString: Any] {
            exifProperties[kCGImagePropertyExifDateTimeOriginal] = dateTimeString as CFString
            exifProperties[kCGImagePropertyExifDateTimeDigitized] = dateTimeString as CFString
            options[kCGImagePropertyExifDictionary] = exifProperties as CFDictionary
        }
        
        guard let destination = CGImageDestinationCreateWithURL(output as CFURL, utType.identifier as CFString, 1, nil) else {
            throw ConversionError.failedToCreateImageDestination
        }

        options[kCGImageDestinationLossyCompressionQuality] = compression
        
        if utType == .pdf {
            try performPDFConversion(image: image, from: sourceData, to: destination, output: output, compression: compression, options: options)
            try output.setResourceValues(resourceValues)
            
            return
        }
        
        try performImageIOConversion(image: image, from: source, to: destination, as: utType, options: options)
        try output.setResourceValues(resourceValues)
        
        return
    }

    /// The core conversion function that takes a CGImageSource and writes to a destination using ImageIO.
    /// This approach is highly efficient as it avoids fully decoding and re-encoding image data into memory (e.g., a CGImage).
    /// It also preserves metadata and handles multi-frame images (like animated GIFs) correctly.
    private static func performImageIOConversion(image: UIImage?, from source: CGImageSource, to destination: CGImageDestination, as utType: UTType, options: [CFString: Any]) throws {
        // Set properties for the destination, such as compression quality.
        CGImageDestinationSetProperties(destination, options as CFDictionary)

        if let image = image?.cgImage {
            CGImageDestinationAddImage(destination, image, options as CFDictionary)
        } else {
            let frameCount = CGImageSourceGetCount(source)
            guard frameCount > 0 else {
                throw ConversionError.sourceImageNotFound
            }
            
            // Iterate through all frames in the source image and add them to the destination.
            for i in 0..<frameCount {
                // Passing nil for the properties dictionary copies the frame's original properties.
                CGImageDestinationAddImageFromSource(destination, source, i, options as CFDictionary)
            }
        }

        if !CGImageDestinationFinalize(destination) {
            throw ConversionError.failedToFinalizeImage
        }
    }

    /// The core PDF conversion function using CoreGraphics.
    private static func performPDFConversion(image: UIImage?, from source: Data, to destination: CGImageDestination, output: URL, compression: CGFloat, options: [CFString: Any]) throws {
        guard var image = image ?? UIImage(data: source) else {
            throw ConversionError.sourceImageNotFound
        }
        
        guard let data = image.jpegData(compressionQuality: compression) else {
            throw ConversionError.sourceImageNotFound
        }
        
        image = UIImage(data: data) ?? image

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: image.size))
        let pdf = renderer.pdfData { (context) in
            context.beginPage()
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
        
        try pdf.write(to: output)
    }
}
