
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
     An image analysis request that determines the affine transform necessary to align the content of two images.
     
     Create and perform a translational image registration request to align content in two images through translation.

     Stablize video
     
     - Revision 1
     */
    @available(iOS 11, *)
    func translationalImageRegistrationRequest(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, 
                                               revision: Int = 1, options: [VNImageOption: Any] = [:],
                                               targetImage: VisionImage, targetOrientation: CGImagePropertyOrientation? = nil,
                                               targetOptions: [VNImageOption: Any] = [:],
                                               for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNTranslationalImageRegistrationRequest {
        let request: VNTranslationalImageRegistrationRequest = targetImage.createRequest(orientation: targetOrientation, options: targetOptions, completionHandler: nil)
        
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
     An image analysis request, as a stateful request you track over time, that determines the affine transform necessary to align the content of two images.
     
     This request is similar to VNTranslationalImageRegistrationRequest. However, as a VNStatefulRequest, it automatically computes the registration against the previous frame.
     
     Create and perform a translational image registration request to align content in two images through translation.
     
     Stablize video
     
     - Revision 1
     */
    @available(iOS 17, *)
    func trackTranslationalImageRegistrationRequest(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, 
                                                    revision: Int = 1, options: [VNImageOption: Any] = [:],
                                                    for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNTrackTranslationalImageRegistrationRequest {
        let request = VNTrackTranslationalImageRegistrationRequest()
        
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
     An image analysis request that determines the perspective warp matrix necessary to align the content of two images.
     
     Create and perform a homographic image registration request to align content in two images through a homography. A homography is an isomorphism of projected spaces, a bijection that maps lines to lines.
     
     Stablize video
     
     - Revision 1
     */
    @available(iOS 11, *)
    func homographicImageRegistrationRequest(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                                             revision: Int = 1, targetImage: VisionImage, targetOrientation: CGImagePropertyOrientation? = nil,
                                             targetOptions: [VNImageOption: Any] = [:],
                                             for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNHomographicImageRegistrationRequest {
        let request: VNHomographicImageRegistrationRequest = targetImage.createRequest(orientation: targetOrientation, options: targetOptions, completionHandler: nil)
        
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
     An image analysis request, as a stateful request you track over time, that determines the perspective warp matrix necessary to align the content of two images.
     
     This request is similar to VNHomographicImageRegistrationRequest. However, as a VNStatefulRequest, it automatically computes the registration against the previous frame.
     
     Create and perform a homographic image registration request to align content in two images through a homography. A homography is an isomorphism of projected spaces, a bijection that maps lines to lines.
     
     Stablize video
     
     - Revision 1
     */
    @available(iOS 17, *)
    func trackHomographicImageRegistrationRequest(image: VisionImage, orientation: CGImagePropertyOrientation? = nil,
                                                  revision: Int = 1, options: [VNImageOption: Any] = [:],
                                                  for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNTrackHomographicImageRegistrationRequest {
        let request = VNTrackHomographicImageRegistrationRequest()
        
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
