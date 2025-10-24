
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
     An object that generates directional change vectors for each pixel in the targeted image.
     
     Frameinterporation
     
     This request operates at a pixel level, so both images need to have the same dimensions to successfully perform the analysis. Setting a region of interest limits the region in which the analysis occurs. However, the system reports the resulting observation at full resolution.

     Optical flow requests are resource-intensive, so create only one request at a time, and release it immediately after generating optical flows.
     
     - Revision 1 or 2
     */
    @available(iOS 14, *)
    func generateOpticalFlow(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:], revision: Int = 2,
                             targetImage: VisionImage, targetOrientation: CGImagePropertyOrientation? = nil, targetOptions: [VNImageOption: Any] = [:],
                             computationAccuracy: VNGenerateOpticalFlowRequest.ComputationAccuracy,
                             outputPixelFormat: OSType, keepNetworkOutput: Bool = false,
                             for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNGenerateOpticalFlowRequest {
        let request: VNGenerateOpticalFlowRequest = targetImage.createRequest(orientation: targetOrientation, options: targetOptions, completionHandler: nil)
        request.computationAccuracy = computationAccuracy
        request.outputPixelFormat = outputPixelFormat
        
        request.revision = revision
        
        if #available(iOS 16.0, *) {
            request.keepNetworkOutput = keepNetworkOutput
        }
        
        if let sequenceHandler = sequenceHandler {
            image.performRequests(requests: [request], for: sequenceHandler, orientation: orientation)
        } else {
            let handler = image.createImageHandler(orientation: orientation, options: options)
            try? handler.perform([request])
        }
        
        return request
    }
    
    /**
     An object that determines the direction change of vectors for each pixel from a previous to current image.
     
     This request works at the pixel level, so both images must have the same dimensions to successfully perform the request.

     Setting a region of interest isolates where to perform the change determination.
     
     - Important: Optical flow requests are very resource intensive, so perform only one request at a time. Release memory immediately after generating an optical flow.
     
     - Revision 1
     */
    @available(iOS 17, *)
    func trackOpticalFlow(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                          revision: Int = 1, computationAccuracy: VNTrackOpticalFlowRequest.ComputationAccuracy,
                          outputPixelFormat: OSType, keepNetworkOutput: Bool = false,
                          for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNTrackOpticalFlowRequest {
        let request = VNTrackOpticalFlowRequest()
        request.computationAccuracy = computationAccuracy
        request.outputPixelFormat = outputPixelFormat
        request.keepNetworkOutput = keepNetworkOutput
        
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
