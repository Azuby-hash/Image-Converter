
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
     Product image with white attention and black background
     - Revision 1
     */
    @available(iOS 13, *)
    func generateAttentionBasedSaliencyImage(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                                             revision: Int = 1, for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNGenerateAttentionBasedSaliencyImageRequest {
        let request = VNGenerateAttentionBasedSaliencyImageRequest()
        
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
     Product image with white main object and black background
     - Revision 1
     */
    @available(iOS 13, *)
    func generateObjectnessBasedSaliencyImage(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                                              revision: Int = 1, for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNGenerateObjectnessBasedSaliencyImageRequest {
        let request = VNGenerateObjectnessBasedSaliencyImageRequest()
        
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
