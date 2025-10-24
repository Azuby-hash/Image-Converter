//
//  VisionImageSequenceAnalysis.swift
//  ModuleTest
//
//  Created by Azuby on 29/03/2024.
//

import UIKit
import Vision

extension VisionModel {
    /**
     - Product gray image with white people and black background
     - Revision 1
     - Parameters:
        - qualityLevel:
            - accurate
            - balanced (Default)
            - fast
        - outputPixelFormat:
            - kCVPixelFormatType_OneComponent8 (Default)
            - kCVPixelFormatType_OneComponent16Half
            - kCVPixelFormatType_OneComponent32Float
     */
    @available(iOS 15, *)
    func generatePersonSegmentation(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                                    revision: Int = 1, outputPixelFormat: OSType = kCVPixelFormatType_OneComponent8,
                                    qualityLevel: VNGeneratePersonSegmentationRequest.QualityLevel = .balanced,
                                    for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNGeneratePersonSegmentationRequest {
        let request = VNGeneratePersonSegmentationRequest()
        request.outputPixelFormat = outputPixelFormat
        request.qualityLevel = qualityLevel
        request.revision = revision
        
        if let sequenceHandler = sequenceHandler {
            image.performRequests(requests: [request], for: sequenceHandler, orientation: orientation)
        } else {
            let handler = image.createImageHandler(orientation: orientation, options: options)
            try? handler.perform([request])
        }
        
        return request
    }
    
    /**
     - Product numbers of gray image per person with white person and black background
     - Revision 1
     */
    @available(iOS 17, *)
    func generatePersonInstanceMask(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                                    revision: Int = 1, for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNGeneratePersonInstanceMaskRequest {
        let request = VNGeneratePersonInstanceMaskRequest()
        
        request.revision = revision
        
        if let sequenceHandler = sequenceHandler {
            image.performRequests(requests: [request], for: sequenceHandler, orientation: orientation)
        } else {
            let handler = image.createImageHandler(orientation: orientation, options: options)
            try? handler.perform([request])
        }
        
        return request
    }
    
    /**
     Return rects have text in image
     - Revision 1
     */
    @available(iOS 15, *)
    func detectDocumentSegmentation(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                                    revision: Int = 1, for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNDetectDocumentSegmentationRequest {
        let request = VNDetectDocumentSegmentationRequest()
        
        request.revision = revision
        
        if let sequenceHandler = sequenceHandler {
            image.performRequests(requests: [request], for: sequenceHandler, orientation: orientation)
        } else {
            let handler = image.createImageHandler(orientation: orientation, options: options)
            try? handler.perform([request])
        }
        
        return request
    }
}
