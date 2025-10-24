
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
     A request that recognizes animals in an image.
     
     Use the knownAnimalIdentifiersForRevision:error: method to determine which animals the request supports.
     
     - Revision 1 or 2
     */
    @available(iOS 13, *)
    func recognizeAnimals(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                          revision: Int = 2, for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNRecognizeAnimalsRequest {
        let request = VNRecognizeAnimalsRequest()
        
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
