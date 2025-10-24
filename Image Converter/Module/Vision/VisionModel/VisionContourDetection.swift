
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
     A request that detects the contours of the edges of an image.
     
     - Revision 1
     */
    @available(iOS 14, *)
    func detectContours(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                        revision: Int = 1, contrastAdjustment: Float = 2, contrastPivot: NSNumber? = 0.5,
                        detectsDarkOnLight: Bool = true, maximumImageDimension: Int = 512,
                        for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNDetectContoursRequest {
        let request = VNDetectContoursRequest()
        request.contrastAdjustment = contrastAdjustment
        if #available(iOS 15.0, *) {
            request.contrastPivot = contrastPivot
        }
        request.detectsDarkOnLight = detectsDarkOnLight
        request.maximumImageDimension = maximumImageDimension
        
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
