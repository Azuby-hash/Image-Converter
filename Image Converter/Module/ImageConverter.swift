//
//  ImageConverter.swift
//  Image Converter
//
//  Created by TapUniverse Dev9 on 4/11/25.
//

import Foundation
import ImageIO
import Photos
import UniformTypeIdentifiers
import CoreGraphics

/// A utility for converting images from various sources to different formats using best practices.
/// This enum acts as a namespace for the static conversion methods and cannot be instantiated.
enum ImageConverter {

    /// Describes errors that can occur during the image conversion process.
    enum ConversionError: Error, LocalizedError {
        case invalidInputURL(URL)
        case failedToAccessAssetData(Error?)
        case failedToCreateImageSource(String)
        case failedToCreateImageDestination
        case failedToFinalizeImage
        case pdfContextCreationFailed
        case sourceImageNotFound
        case unsupportedOutputFormat(String)

        var errorDescription: String? {
            switch self {
            case .invalidInputURL(let url):
                return "The provided input URL is invalid or the file does not exist: \(url.path)."
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
    static func convert(to utType: UTType, from sourceURL: URL, to destinationURL: URL, compressionQuality: CGFloat = 0.8) throws {
        if utType == .pdf {
            guard let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil) else {
                throw ConversionError.failedToCreateImageSource(sourceURL.path)
            }
            try performPDFConversion(from: source, to: destinationURL)
            
            return
        }
        
        let options = [kCGImageDestinationLossyCompressionQuality: compressionQuality] as [CFString: Any]
        try performImageIOConversion(from: sourceURL, to: destinationURL, as: utType, options: options)
    }

    /// Converts an image from a PHAsset to JPEG format.
    /// - Parameters:
    ///   - asset: The `PHAsset` representing the source image.
    ///   - destinationURL: The URL where the converted JPEG file will be saved.
    ///   - compressionQuality: The quality of the resulting JPEG image, from 0.0 (lowest) to 1.0 (highest).
    static func convert(to utType: UTType, from asset: PHAsset, to destinationURL: URL, compressionQuality: CGFloat = 0.8) async throws {
        if utType == .pdf {
            let imageData = try await requestImageData(for: asset)
            guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
                throw ConversionError.failedToCreateImageSource("PHAsset Data")
            }
            try performPDFConversion(from: source, to: destinationURL)
            
            return
        }
        
        let options = [kCGImageDestinationLossyCompressionQuality: compressionQuality] as [CFString: Any]
        try await performImageIOConversion(from: asset, to: destinationURL, as: utType, options: options)
    }

    // MARK: - Private Core Logic

    private static func performImageIOConversion(from sourceURL: URL, to destinationURL: URL, as utType: UTType, options: [CFString: Any]? = nil) throws {
        guard let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil) else {
            throw ConversionError.failedToCreateImageSource(sourceURL.path)
        }
        try performImageIOConversion(from: source, to: destinationURL, as: utType, options: options)
    }

    private static func performImageIOConversion(from asset: PHAsset, to destinationURL: URL, as utType: UTType, options: [CFString: Any]? = nil) async throws {
        let imageData = try await requestImageData(for: asset)
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            throw ConversionError.failedToCreateImageSource("PHAsset Data")
        }
        try performImageIOConversion(from: source, to: destinationURL, as: utType, options: options)
    }

    /// The core conversion function that takes a CGImageSource and writes to a destination using ImageIO.
    /// This approach is highly efficient as it avoids fully decoding and re-encoding image data into memory (e.g., a CGImage).
    /// It also preserves metadata and handles multi-frame images (like animated GIFs) correctly.
    private static func performImageIOConversion(from source: CGImageSource, to destinationURL: URL, as utType: UTType, options: [CFString: Any]? = nil) throws {
        let frameCount = CGImageSourceGetCount(source)
        guard frameCount > 0 else {
            throw ConversionError.sourceImageNotFound
        }

        guard let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, utType.identifier as CFString, frameCount, nil) else {
            throw ConversionError.failedToCreateImageDestination
        }

        // Set properties for the destination, such as compression quality.
        if let options = options {
            CGImageDestinationSetProperties(destination, options as CFDictionary)
        }

        // Iterate through all frames in the source image and add them to the destination.
        for i in 0..<frameCount {
            // Passing nil for the properties dictionary copies the frame's original properties.
            CGImageDestinationAddImageFromSource(destination, source, i, nil)
        }

        if !CGImageDestinationFinalize(destination) {
            throw ConversionError.failedToFinalizeImage
        }
    }

    /// The core PDF conversion function using CoreGraphics.
    private static func performPDFConversion(from source: CGImageSource, to destinationURL: URL) throws {
        guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = imageProperties[kCGImagePropertyPixelWidth] as? CGFloat,
              let height = imageProperties[kCGImagePropertyPixelHeight] as? CGFloat else {
            throw ConversionError.sourceImageNotFound
        }

        let pdfRect = CGRect(x: 0, y: 0, width: width, height: height)
        var mediaBox = pdfRect
        
        guard let pdfContext = CGContext(destinationURL as CFURL, mediaBox: &mediaBox, nil) else {
            throw ConversionError.pdfContextCreationFailed
        }

        guard let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw ConversionError.sourceImageNotFound
        }

        pdfContext.beginPDFPage(nil)
        pdfContext.draw(image, in: pdfRect)
        pdfContext.endPDFPage()
        pdfContext.closePDF()
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
