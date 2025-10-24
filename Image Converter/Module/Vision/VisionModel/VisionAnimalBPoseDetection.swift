
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
     - Revision 1
     */
    @available(iOS 17, *)
    func detectAnimalBodyPose(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                              revision: Int = 1, for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNDetectAnimalBodyPoseRequest {

        let request = VNDetectAnimalBodyPoseRequest()
        
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
