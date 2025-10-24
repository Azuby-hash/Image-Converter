
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
     - Product single rect through single VNSequenceRequestHandler return rects follow time
     - Revision 1
     - Parameters:
        - rectangleObservation:
            - input CGRect of first frame
        - qualityLevel:
            - accurate (Default)
            - fast
     */
    @available(iOS 11, *)
    func trackRectangle(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                        revision: Int = 1, rectangleObservation: VNRectangleObservation, trackingLevel: VNRequestTrackingLevel = .accurate,
                        for sequenceHandler: VNSequenceRequestHandler) -> VNTrackRectangleRequest {
        let request = VNTrackRectangleRequest(rectangleObservation: rectangleObservation)
        request.trackingLevel = trackingLevel
        request.revision = revision
        
        image.performRequests(requests: [request], for: sequenceHandler, orientation: orientation)
        
        return request
    }
    
    /**
     - Product multi rect through single VNSequenceRequestHandler return rects follow time
     - Revision 1
     - Parameters:
        - rectangleObservation:
            - input CGRect of first frame
        - qualityLevel:
            - accurate (Default)
            - fast
     */
    @available(iOS 11, *)
    func trackRectangles(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                        revision: Int = 1, rectangleObservations: [VNRectangleObservation], trackingLevel: VNRequestTrackingLevel = .accurate,
                        for sequenceHandler: VNSequenceRequestHandler) -> [VNTrackRectangleRequest] {
        let requests = rectangleObservations.enumerated().map { (index, rectangleObservation) in
            let request = VNTrackRectangleRequest(rectangleObservation: rectangleObservation)
            request.trackingLevel = trackingLevel
            request.revision = revision

            return request
        }
        
        image.performRequests(requests: requests, for: sequenceHandler, orientation: orientation)
        
        return requests
    }
    
    /**
     - Product single rect through single VNSequenceRequestHandler return object rects follow time
     - Revision 1 or 2
     - Parameters:
        - rectangleObservation:
            - input CGRect of first object frame
        - qualityLevel:
            - accurate (Default)
            - fast
     */
    @available(iOS 11, *)
    func trackObject(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:], revision: Int = 2,
                     detectedObjectObservation: VNDetectedObjectObservation, trackingLevel: VNRequestTrackingLevel = .accurate,
                     for sequenceHandler: VNSequenceRequestHandler) -> VNTrackObjectRequest {
        let request = VNTrackObjectRequest(detectedObjectObservation: detectedObjectObservation)
        request.trackingLevel = trackingLevel
        request.revision = revision
        
        image.performRequests(requests: [request], for: sequenceHandler, orientation: orientation)
        
        return request
    }
    
    /**
     - Product multi rect through single VNSequenceRequestHandler return object rects follow time
     - Revision 1 or 2
     - Parameters:
        - rectangleObservation:
            - input CGRect of first object frame
        - qualityLevel:
            - accurate (Default)
            - fast
     */
    @available(iOS 11, *)
    func trackObjects(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:], revision: Int = 2,
                     detectedObjectObservations: [VNDetectedObjectObservation], trackingLevel: VNRequestTrackingLevel = .accurate,
                     for sequenceHandler: VNSequenceRequestHandler) -> [VNTrackObjectRequest] {
        let requests = detectedObjectObservations.enumerated().map { (index, detectedObjectObservation) in
            let request = VNTrackObjectRequest(detectedObjectObservation: detectedObjectObservation)
            request.trackingLevel = trackingLevel
            request.revision = revision

            return request
        }

        image.performRequests(requests: requests, for: sequenceHandler, orientation: orientation)
        
        return requests
    }
}
