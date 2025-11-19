//
//  MergeUpscale.swift
//  ModuleTest
//
//  Created by TapUniverse Dev9 on 24/10/24.
//

import UIKit
import Vision

/**
 - Important: Call **loadModel()** on app delegate. Check **canUpscale()** before **inference()**
 */
class ModelUpscale {
    static let shared = ModelUpscale()
    
    private let context = CIContext()
    private var request: VNCoreMLRequest?
    
    enum GradientDirection {
        case hoz
        case vel
    }

    /**
     - Load can take time. Check loaded by **isModelLoaded()**
     */
    func loadModel() {
        let config = MLModelConfiguration()
        config.computeUnits = .all
        
        guard let mlModel = try? RealESRGan512(configuration: config).model,
              let model = try? VNCoreMLModel(for: mlModel)
        else { return }

        request = VNCoreMLRequest(model: model)
        request?.imageCropAndScaleOption = .scaleFill
    }
    
    /**
     - Check if model is loaded
     */
    func isModelLoaded() -> Bool {
        return request != nil
    }

    /**
     - Inference image
     - Check if image size can upscale first before inference. Too big can cause crash due to memory exceed
     */
    func inference(image: UIImage) throws -> UIImage {
        guard let ciImage = CIImage(image: image.resizeStretch(size: CGSize(width: 512, height: 512))) else {
            throw NSError(domain: "Can't get CIImage", code: 404)
        }
        
        guard let request = request else {
            throw NSError(domain: "Model not load", code: 404)
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        try handler.perform([request])
        
        guard let pixelBuffer = request.results?.first as? VNPixelBufferObservation else {
            throw NSError(domain: "Upscale failed", code: 404)
        }
        
        let ciOutput = CIImage(cvPixelBuffer: pixelBuffer.pixelBuffer)
        
        guard let cgOutput = context.createCGImage(ciOutput, from: ciOutput.extent) else {
            throw NSError(domain: "Upscale failed", code: 404)
        }
        
        return UIImage(cgImage: cgOutput).resizeStretch(size: image.size)
    }
}
