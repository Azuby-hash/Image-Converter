
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
     This request returns detected text characters as rectangular bounding boxes with origin and size.
     
     - Revision 1
     */
    @available(iOS 11, *)
    func detectTextRectangles(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                              revision: Int = 1, reportCharacterBoxes: Bool = false,
                              for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNDetectTextRectanglesRequest {
        let request = VNDetectTextRectanglesRequest()
        request.reportCharacterBoxes = reportCharacterBoxes
        
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
