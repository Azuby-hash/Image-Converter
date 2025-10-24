//
//  VisionRequest.swift
//  ModuleTest
//
//  Created by Azuby on 25/04/2024.
//

import UIKit
import Vision

class VisionClassificationRequest: VNCoreMLRequest {
    var observations: [VNClassificationObservation]? {
        get {
            return results as? [VNClassificationObservation]
        }
    }
}

class VisionRectangleRequest: VNCoreMLRequest {
    var observations: [VNDetectedObjectObservation]? {
        get {
            return results as? [VNDetectedObjectObservation]
        }
    }
}

class VisionPixelBufferRequest: VNCoreMLRequest {
    var observations: [VNPixelBufferObservation]? {
        get {
            return results as? [VNPixelBufferObservation]
        }
    }
}

class VisionFeatureRequest: VNCoreMLRequest {
    var observations: [VNCoreMLFeatureValueObservation]? {
        get {
            return results as? [VNCoreMLFeatureValueObservation]
        }
    }
}

