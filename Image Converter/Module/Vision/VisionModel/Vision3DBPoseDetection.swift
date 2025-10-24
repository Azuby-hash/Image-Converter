
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
     A request that detects points on human bodies in three-dimensional space, relative to the camera.
     
     This request generates a collection of VNHumanBodyPose3DObservation objects that describe the position of each body the request detects. If the system allows it, the request uses AVDepthData information to improve the accuracy.
     
     - Revision 1
     */
    @available(iOS 17, *)
    func detectHumanBodyPose3D(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                               revision: Int = 1, for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNDetectHumanBodyPose3DRequest {
        let request = VNDetectHumanBodyPose3DRequest()
        
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
