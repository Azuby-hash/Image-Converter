
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
     A request that detects barcodes in an image.
     
     QR code
     
     - Revision 2 or 3
     */
    @available(iOS 11, *)
    func detectBarcodes(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                        revision: Int = 3, symbologies: [VNBarcodeSymbology]? = nil, coalesceCompositeSymbologies: Bool,
                        detectsDarkOnLight: Bool = true, maximumImageDimension: Int = 512,
                        for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNDetectBarcodesRequest {
        let request = VNDetectBarcodesRequest()
        if let symbologies = symbologies {
            request.symbologies = symbologies
        }
        
        if #available(iOS 17.0, *) {
            request.coalesceCompositeSymbologies = true
        }
        
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
