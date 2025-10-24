//
//  VisionModel.swift
//  ModuleTest
//
//  Created by Azuby on 25/03/2024.
//

import UIKit
import Vision

fileprivate let context = CIContext()

class VisionHandler {
    static let model = VisionModel.shared
    static let coreml = VisionCoreML.shared
    
    private init() { }
}

class VisionModel {
    static let shared = VisionModel()
    
    fileprivate init() { }
}

class VisionCoreML {
    static let shared = VisionCoreML()
    
    fileprivate init() { }
}

protocol VisionImage {
    func createRequest<T: VNTargetedImageRequest>(orientation: CGImagePropertyOrientation?, options: [VNImageOption: Any], completionHandler: VNRequestCompletionHandler?) -> T
    func createImageHandler(orientation: CGImagePropertyOrientation?, options: [VNImageOption: Any]) -> VNImageRequestHandler
    func createFeatureValue(orientation: CGImagePropertyOrientation?, constraint: MLImageConstraint, options: [VNImageOption: Any]) -> MLFeatureValue?
    func performRequests(requests: [VNRequest], for sequenceHandler: VNSequenceRequestHandler, orientation: CGImagePropertyOrientation?)
}

extension CGImage: VisionImage {
    func createRequest<T: VNTargetedImageRequest>(orientation: CGImagePropertyOrientation?, options: [VNImageOption : Any], completionHandler: VNRequestCompletionHandler?) -> T  {
        if let orientation = orientation {
            return T(targetedCGImage: self, orientation: orientation, options: options, completionHandler: completionHandler)
        }
        return T(targetedCGImage: self, completionHandler: completionHandler)
    }
    
    func createImageHandler(orientation: CGImagePropertyOrientation?, options: [VNImageOption: Any]) -> VNImageRequestHandler {
        if let orientation = orientation {
            return VNImageRequestHandler(cgImage: self, orientation: orientation, options: options)
        }
        return VNImageRequestHandler(cgImage: self)
    }
    
    func createFeatureValue(orientation: CGImagePropertyOrientation?, constraint: MLImageConstraint, options: [VNImageOption: Any]) -> MLFeatureValue? {
        if let orientation = orientation {
            return try? .init(cgImage: self, orientation: orientation, constraint: constraint)
        }
        
        return try? .init(cgImage: self, constraint: constraint)
    }
    
    func performRequests(requests: [VNRequest], for sequenceHandler: VNSequenceRequestHandler, orientation: CGImagePropertyOrientation?) {
        if let orientation = orientation {
            try? sequenceHandler.perform(requests, on: self, orientation: orientation)
        }
        try? sequenceHandler.perform(requests, on: self)
    }
}

extension CIImage: VisionImage {
    func createRequest<T: VNTargetedImageRequest>(orientation: CGImagePropertyOrientation?, options: [VNImageOption : Any], completionHandler: VNRequestCompletionHandler?) -> T {
        if let orientation = orientation {
            return T(targetedCIImage: self, orientation: orientation, options: options, completionHandler: completionHandler)
        }
        return T(targetedCIImage: self, completionHandler: completionHandler)
    }
    
    func createImageHandler(orientation: CGImagePropertyOrientation?, options: [VNImageOption: Any]) -> VNImageRequestHandler {
        if let orientation = orientation {
            return VNImageRequestHandler(ciImage: self, orientation: orientation, options: options)
        }
        return VNImageRequestHandler(ciImage: self)
    }
    
    func createFeatureValue(orientation: CGImagePropertyOrientation?, constraint: MLImageConstraint, options: [VNImageOption: Any]) -> MLFeatureValue? {
        guard let cgImage = context.createCGImage(self, from: extent) else {
            print("Cant convert to CGImage")
            return nil
        }

        if let orientation = orientation {
            return try? .init(cgImage: cgImage, orientation: orientation, constraint: constraint)
        }
        
        return try? .init(cgImage: cgImage, constraint: constraint)
    }
    
    func performRequests(requests: [VNRequest], for sequenceHandler: VNSequenceRequestHandler, orientation: CGImagePropertyOrientation?) {
        if let orientation = orientation {
            try? sequenceHandler.perform(requests, on: self, orientation: orientation)
        }
        try? sequenceHandler.perform(requests, on: self)
    }
}

extension Data: VisionImage {
    func createRequest<T: VNTargetedImageRequest>(orientation: CGImagePropertyOrientation?, options: [VNImageOption : Any], completionHandler: VNRequestCompletionHandler?) -> T {
        if let orientation = orientation {
            return T(targetedImageData: self, orientation: orientation, options: options, completionHandler: completionHandler)
        }
        return T(targetedImageData: self, completionHandler: completionHandler)
    }
    
    func createImageHandler(orientation: CGImagePropertyOrientation?, options: [VNImageOption: Any]) -> VNImageRequestHandler {
        if let orientation = orientation {
            return VNImageRequestHandler(data: self, orientation: orientation, options: options)
        }
        return VNImageRequestHandler(data: self)
    }
    
    func createFeatureValue(orientation: CGImagePropertyOrientation?, constraint: MLImageConstraint, options: [VNImageOption: Any]) -> MLFeatureValue? {
        guard let cgImage = UIImage(data: self)?.cgImage else {
            print("Cant convert to CGImage")
            return nil
        }

        if let orientation = orientation {
            return try? .init(cgImage: cgImage, orientation: orientation, constraint: constraint)
        }
        
        return try? .init(cgImage: cgImage, constraint: constraint)
    }
    
    func performRequests(requests: [VNRequest], for sequenceHandler: VNSequenceRequestHandler, orientation: CGImagePropertyOrientation?) {
        if let orientation = orientation {
            try? sequenceHandler.perform(requests, onImageData: self, orientation: orientation)
        }
        try? sequenceHandler.perform(requests, onImageData: self)
    }
}

extension URL: VisionImage {
    func createRequest<T: VNTargetedImageRequest>(orientation: CGImagePropertyOrientation?, options: [VNImageOption : Any], completionHandler: VNRequestCompletionHandler?) -> T {
        if let orientation = orientation {
            return T(targetedImageURL: self, orientation: orientation, options: options, completionHandler: completionHandler)
        }
        return T(targetedImageURL: self, completionHandler: completionHandler)
    }
    
    func createImageHandler(orientation: CGImagePropertyOrientation?, options: [VNImageOption: Any]) -> VNImageRequestHandler {
        if let orientation = orientation {
            return VNImageRequestHandler(url: self, orientation: orientation, options: options)
        }
        return VNImageRequestHandler(url: self)
    }
    
    func createFeatureValue(orientation: CGImagePropertyOrientation?, constraint: MLImageConstraint, options: [VNImageOption: Any]) -> MLFeatureValue? {
        guard let data = try? Data(contentsOf: self),
              let cgImage = UIImage(data: data)?.cgImage else {
            print("Cant convert to CGImage")
            return nil
        }

        if let orientation = orientation {
            return try? .init(cgImage: cgImage, orientation: orientation, constraint: constraint)
        }
        
        return try? .init(cgImage: cgImage, constraint: constraint)
    }
    
    func performRequests(requests: [VNRequest], for sequenceHandler: VNSequenceRequestHandler, orientation: CGImagePropertyOrientation?) {
        if let orientation = orientation {
            try? sequenceHandler.perform(requests, onImageURL: self, orientation: orientation)
        }
        try? sequenceHandler.perform(requests, onImageURL: self)
    }
}

extension CVPixelBuffer: VisionImage {
    func createRequest<T: VNTargetedImageRequest>(orientation: CGImagePropertyOrientation?, options: [VNImageOption : Any], completionHandler: VNRequestCompletionHandler?) -> T {
        if let orientation = orientation {
            return T(targetedCVPixelBuffer: self, orientation: orientation, options: options, completionHandler: completionHandler)
        }
        return T(targetedCVPixelBuffer: self, completionHandler: completionHandler)
    }
    
    func createImageHandler(orientation: CGImagePropertyOrientation?, options: [VNImageOption: Any]) -> VNImageRequestHandler {
        if let orientation = orientation {
            return VNImageRequestHandler(cvPixelBuffer: self, orientation: orientation, options: options)
        }
        return VNImageRequestHandler(cvPixelBuffer: self)
    }
    
    func createFeatureValue(orientation: CGImagePropertyOrientation?, constraint: MLImageConstraint, options: [VNImageOption: Any]) -> MLFeatureValue? {
        guard let constraint = MLImageConstraint(coder: NSCoder()) else {
            print("Cant create ml constraint")
            return nil
        }
        
        return MLFeatureValue(pixelBuffer: self)
    }
    
    func performRequests(requests: [VNRequest], for sequenceHandler: VNSequenceRequestHandler, orientation: CGImagePropertyOrientation?) {
        if let orientation = orientation {
            try? sequenceHandler.perform(requests, on: self, orientation: orientation)
        }
        try? sequenceHandler.perform(requests, on: self)
    }
}

extension CMSampleBuffer: VisionImage {
    func createRequest<T: VNTargetedImageRequest>(orientation: CGImagePropertyOrientation?, options: [VNImageOption : Any], completionHandler: VNRequestCompletionHandler?) -> T {
        if let orientation = orientation {
            return T(targetedCMSampleBuffer: self, orientation: orientation, options: options, completionHandler: completionHandler)
        }
        return T(targetedCMSampleBuffer: self, completionHandler: completionHandler)
    }
    
    func createImageHandler(orientation: CGImagePropertyOrientation?, options: [VNImageOption: Any]) -> VNImageRequestHandler {
        if let orientation = orientation {
            return VNImageRequestHandler(cmSampleBuffer: self, orientation: orientation, options: options)
        }
        return VNImageRequestHandler(cmSampleBuffer: self)
    }
    
    func createFeatureValue(orientation: CGImagePropertyOrientation?, constraint: MLImageConstraint, options: [VNImageOption: Any]) -> MLFeatureValue? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(self) else {
            print("Cant create pixelBuffer")
            return nil
        }
        
        return MLFeatureValue(pixelBuffer: pixelBuffer)
    }
    
    func performRequests(requests: [VNRequest], for sequenceHandler: VNSequenceRequestHandler, orientation: CGImagePropertyOrientation?) {
        if let orientation = orientation {
            try? sequenceHandler.perform(requests, on: self, orientation: orientation)
        }
        try? sequenceHandler.perform(requests, on: self)
    }
}

enum VisionRequest {
    // Still image
    @available(iOS 13, *)
    case classifyImage
    @available(iOS 13, *)
    case generateImageFeaturePrint
    
    // Image sequence Analysis
    @available(iOS 15, *)
    case generatePersonSegmentation
    @available(iOS 17, *)
    case generatePersonInstanceMask
    @available(iOS 15, *)
    case detectDocumentSegmentation
    
    // Saliency
    @available(iOS 13, *)
    case generateAttentionBasedSaliencyImage
    @available(iOS 13, *)
    case generateObjectnessBasedSaliencyImage
    
    // Object tracking
    @available(iOS 11, *)
    case tracking
    @available(iOS 11, *)
    case trackRectangle
    @available(iOS 11, *)
    case trackObject
    
    // Rectangle detection
    @available(iOS 11, *)
    case detectRectangles
    
    // Face and body detection
    @available(iOS 13, *)
    case detectFaceCaptureQuality
    @available(iOS 11, *)
    case detectFaceLandmarks
    @available(iOS 11, *)
    case detectFaceRectangles
    @available(iOS 13, *)
    case detectHumanRectangles
    
    // Body and hand pose detection
    @available(iOS 14, *)
    case detectHumanBodyPose
    @available(iOS 14, *)
    case detectHumanHandPose
    
    // 3D Body pose detection
    @available(iOS 17, *)
    case detectHumanBodyPose3D
    
    // Animal detection
    @available(iOS 13, *)
    case recognizeAnimals
    
    // Animal body pose detection
    @available(iOS 17, *)
    case detectAnimalBodyPose
    
    // Trajectory detection
    @available(iOS 14, *)
    case detectTrajectories
    
    // Contour detection
    @available(iOS 14, *)
    case detectContours
    
    // Optical flow
    @available(iOS 14, *)
    case generateOpticalFlow
    @available(iOS 17, *)
    case trackOpticalFlow
    
    // Barcode detection
    @available(iOS 11, *)
    case detectBarcodes
    
    // Text detection
    @available(iOS 11, *)
    case detectTextRectangles
    
    // Text recognition
    @available(iOS 13, *)
    case recognizeText
    
    // Horizon detection
    @available(iOS 11, *)
    case detectHorizon
    
    // Image alignment
    @available(iOS 11, *)
    case targetedImageRequest
    @available(iOS 11, *)
    case imageRegistrationRequest
    @available(iOS 11, *)
    case translationalImageRegistrationRequest
    @available(iOS 17, *)
    case trackTranslationalImageRegistrationRequest
    @available(iOS 11, *)
    case homographicImageRegistrationRequest
    @available(iOS 17, *)
    case trackHomographicImageRegistrationRequest
    
    // Image background removal
    @available(iOS 17, *)
    case generateForegroundInstanceMaskRequest
}
