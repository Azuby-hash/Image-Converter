
//
//  VisionClassifyImage.swift
//  ModuleTest
//
//  Created by Azuby on 26/03/2024.
//

import UIKit
import Vision

extension VisionModel {
    /**
     This request produces or updates a VNFaceObservation object’s property faceCaptureQuality with a floating-point value. The value ranges from 0 to 1. Faces with quality closer to 1 are better lit, sharper, and more centrally positioned than faces with quality closer to 0.

     If you don’t execute the request, or the request fails, the property faceCaptureQuality is nil.
     
     - Revision 1 or 2
     */
    @available(iOS 13, *)
    func detectFaceCaptureQuality(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                                  revision: Int = 2, for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNDetectFaceCaptureQualityRequest {
        let request = VNDetectFaceCaptureQualityRequest()
        
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
     An image analysis request that finds facial features like eyes and mouth in an image.
     
     By default, a face landmarks request first locates all faces in the input image, then analyzes each to detect facial features.

     If you’ve already located all the faces in an image, or want to detect landmarks in only a subset of the faces in the image, set the inputFaceObservations property to an array of VNFaceObservation objects representing the faces you want to analyze. You can either use face observations output by a VNDetectFaceRectanglesRequest or manually create VNFaceObservation instances with the bounding boxes of the faces you want to analyze.
     
     - Revision 2 or 3
     
     - Parameters:
        - constellation:
            - constellationNotDefined (default)
            - constellation65Points
            - constellation76Points
     */
    @available(iOS 11, *)
    func detectFaceLandmarks(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                             revision: Int = 2, constellation: VNRequestFaceLandmarksConstellation = .constellationNotDefined,
                             inputFaceObservations: [VNFaceObservation]? = nil,
                             for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNDetectFaceLandmarksRequest {
        let request = VNDetectFaceLandmarksRequest()
        request.constellation = constellation
        request.revision = revision
        request.inputFaceObservations = inputFaceObservations

        if let sequenceHandler = sequenceHandler {
            image.performRequests(requests: [request], for: sequenceHandler, orientation: orientation)
        } else {
            let handler = image.createImageHandler(orientation: orientation, options: options)
            try? handler.perform([request])
        }
        
        return request
    }
    
    /**
     Returns faces as rectangular bounding boxes with origin and size.
     - Revision 2 or 3
     */
    @available(iOS 11, *)
    func detectFaceRectangles(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                              revision: Int = 2, for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNDetectFaceRectanglesRequest {
        let request = VNDetectFaceRectanglesRequest()
        
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
     Returns faces as rectangular bounding boxes with origin and size.
     - Revision 1 or 2
     - Parameters:
        - upperBodyOnly: full body or upper body only (true)
     */
    @available(iOS 13, *)
    func detectHumanRectangles(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                               revision: Int = 2, upperBodyOnly: Bool = true,
                               for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNDetectHumanRectanglesRequest {
        let request = VNDetectHumanRectanglesRequest()
        
        if #available(iOS 15.0, *) {
            request.upperBodyOnly = upperBodyOnly
        }
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

extension VNFaceLandmarks2D {
    func correctToImageCoordinate(points: [CGPoint], boundingBox: CGRect) -> [CGPoint] {
        let originX = boundingBox.origin.x
        let originY = (1 - boundingBox.origin.y - boundingBox.height)
        let width = boundingBox.width
        let height = boundingBox.height
        
        return points.map({
            let x = originX + $0.x * width
            let y = originY + (1 - $0.y) * height
            return CGPoint(x: x, y: y)
        })
    }
}
