
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
     A request that detects the trajectories of shapes moving along a parabolic path.
     
     After the request detects a trajectory, it produces an observation that contains the shape’s detected points and an equation describing the parabola.
     
     Still video with moving object for max effect
     
     - Revision 1
     */
    @available(iOS 14, *)
    func detectTrajectories(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                            revision: Int = 1, frameAnalysisSpacing: CMTime, trajectoryLength: Int,
                            targetFrameTime: CMTime = .indefinite, objectMinimumNormalizedRadius: Float,
                            objectMaximumNormalizedRadius: Float,
                            for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNDetectTrajectoriesRequest {
        let request = VNDetectTrajectoriesRequest(frameAnalysisSpacing: frameAnalysisSpacing, trajectoryLength: trajectoryLength)
        if #available(iOS 15.0, *) {
            request.targetFrameTime = targetFrameTime
        }
        
        request.objectMinimumNormalizedRadius = objectMinimumNormalizedRadius
        request.objectMaximumNormalizedRadius = objectMaximumNormalizedRadius
        
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
