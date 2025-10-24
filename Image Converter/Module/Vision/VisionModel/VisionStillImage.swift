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
     - Describe input image/video by text
     - Revision 1
     */
    @available(iOS 13, *)
    func classifyImage(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:], revision: Int = 1,
                       for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNClassifyImageRequest {
        let request = VNClassifyImageRequest()
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
     - Signature Verification — Useful in determining if the signature of a person matches the signatures, thereby making your apps smarter when     detecting forgery in real-time on the device.

     - Duplicate Image Finder — Sifting through tons of images, whether in your dataset or a Photos library. With this new Vision request, it gets easier to filter out the duplicate images by creating an automated task.

     - Grouping or Finding Similar Images — Just like text similarity uses the semantic meanings for labeling, image similarity is handy when it comes to grouping or finding images that present similar contexts such as sceneries, places, people, shapes, etc.

     - Face Verification — Image similarity is extremely important in cases such as visual identification.
     
     - Revision 1, 2
     */
    @available(iOS 13, *)
    func generateImageFeaturePrint(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                                   revision: Int = 1, for sequenceHandler: VNSequenceRequestHandler? = nil,
                                   imageCropAndScaleOption: VNImageCropAndScaleOption = .scaleFill) -> VNGenerateImageFeaturePrintRequest {
        let request = VNGenerateImageFeaturePrintRequest()
        request.imageCropAndScaleOption = imageCropAndScaleOption
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
