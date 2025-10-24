
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
     - Return object rect with rectangular shape
     - Revision 1
     - Parameters:
        - minimumAspectRatio:
            - 0->1 (0.5)
        - maximumAspectRatio:
            - 0->1 (0.5)
        - quadratureTolerance:
            - 0->45 (30)
        - minimumSize:
            - 0->1 (0.2)
        - minimumConfidence:
            - 0->1
        - maximumObservations:
            - 0 or n. 0 = ∞, n is Int (1)
     */
    @available(iOS 11, *)
    func detectRectangles(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:], revision: Int = 1,
                          minimumAspectRatio: VNAspectRatio = 0.5, maximumAspectRatio: VNAspectRatio = 0.5,
                          quadratureTolerance: VNDegrees = 30, minimumSize: Float = 0.2,
                          minimumConfidence: VNConfidence, maximumObservations: Int = 1,
                          for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNDetectRectanglesRequest {
        let request = VNDetectRectanglesRequest()
        request.minimumAspectRatio = minimumAspectRatio
        request.maximumAspectRatio = maximumAspectRatio
        request.quadratureTolerance = quadratureTolerance
        request.minimumSize = minimumSize
        request.minimumConfidence = minimumConfidence
        request.maximumObservations = maximumObservations
        request.revision = 1
        
        if let sequenceHandler = sequenceHandler {
            image.performRequests(requests: [request], for: sequenceHandler, orientation: orientation)
        } else {
            let handler = image.createImageHandler(orientation: orientation, options: options)
            try? handler.perform([request])
        }
        
        return request
    }
}
