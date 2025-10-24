
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
     An image analysis request that determines the horizon angle in an image.
     
     Detect all straight line of direction in image
     
     - Revision 1
     */
    @available(iOS 11, *)
    func detectHorizon(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                       revision: Int = 1, for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNDetectHorizonRequest {
        let request = VNDetectHorizonRequest()
        
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
