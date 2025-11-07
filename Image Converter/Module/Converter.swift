//
//  ImageConverter.swift
//  Image Converter
//
//  Created by TapUniverse Dev9 on 4/11/25.
//

import UIKit
import Photos

/// A utility for converting images from various sources to different formats using best practices.
/// This enum acts as a namespace for the static conversion methods and cannot be instantiated.
enum Converter {

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
    static func convert(to utType: UTType, image: UIImage?, from sourceData: Data, compression: CGFloat) throws -> Data {

        guard let source = CGImageSourceCreateWithData(sourceData as CFData, nil),
              var options = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        else { throw ConversionError.failedToCreateImageSource("Image source invalid") }
        
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
}
