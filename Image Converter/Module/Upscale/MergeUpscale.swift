//
//  MergeUpscale.swift
//  ModuleTest
//
//  Created by TapUniverse Dev9 on 24/10/24.
//

import UIKit
import Vision
import CoreImage.CIFilterBuiltins

/**
 - Important: Call **loadModel()** on app delegate. Check **canUpscale()** before **inference()**
 */
class MergeUpscale {
    static let shared = MergeUpscale()
    
    private let TILE_SIZE: CGFloat = 512
    private let OVERLAP_SIZE: CGFloat = 50
    private let UPSCALE_FAC: CGFloat = 4
    
    private let MAXIMUM_UPSCALE: CGFloat = 100000000
    
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
     - Check if image size can upscale. Too big can cause crash due to memory exceed
     */
    func canUpscale(from size: CGSize) -> Bool {
        return size.width * size.height * UPSCALE_FAC * UPSCALE_FAC <= MAXIMUM_UPSCALE
    }
    
    /**
     - Inference image
     - Check if image size can upscale first before inference. Too big can cause crash due to memory exceed
     */
    func inference(image: UIImage?) -> UIImage? {
        if let image = image,
           !canUpscale(from: image.size) {
            print("Exceed maximum size")
            return nil
        }
        
        guard let image = image,
              let ciImage = CIImage(image: image) ?? image.ciImage,
              let ciOutput = processCIImageTile(image: ciImage),
              let cgOutput = context.createCGImage(ciOutput, from: ciOutput.extent)
        else {
            return nil
        }
        
        return UIImage(cgImage: cgOutput)
    }
    
    /**
     - Inference image
     - Check if image size can upscale first before inference. Too big can cause crash due to memory exceed
     */
    func inference(image: CGImage?) -> CGImage? {
        if let image = image,
           !canUpscale(from: CGSize(width: image.width, height: image.height)) {
            print("Exceed maximum size")
            return nil
        }
        
        guard let image = image,
              let ciOutput = processCIImageTile(image: CIImage(cgImage: image)),
              let cgOutput = context.createCGImage(ciOutput, from: ciOutput.extent)
        else {
            return nil
        }

        return cgOutput
    }
    
    /**
     - Inference image
     - Check if image size can upscale first before inference. Too big can cause crash due to memory exceed
     */
    func inference(image: CIImage?) -> CIImage? {
        if let image = image,
           !canUpscale(from: image.extent.size) {
            print("Exceed maximum size")
            return nil
        }
        
        return processCIImageTile(image: image)
    }
}

extension MergeUpscale {
    private func processCIImageTile(image: CIImage?) -> CIImage? {
        guard TILE_SIZE - OVERLAP_SIZE * 2 > 0,
              let ciImage = image,
              let request = request
        else {
            return nil
        }
        
        let tileNumX = ceil((ciImage.extent.width - OVERLAP_SIZE) / (TILE_SIZE - OVERLAP_SIZE))
        let tileNumY = ceil((ciImage.extent.height - OVERLAP_SIZE) / (TILE_SIZE - OVERLAP_SIZE))
        
        guard tileNumX >= 1, tileNumY >= 1 else {
            return nil
        }
        
        let tileWidth = tileNumX * TILE_SIZE - (tileNumX - 1) * OVERLAP_SIZE
        let tileHeight = tileNumY * TILE_SIZE - (tileNumY - 1) * OVERLAP_SIZE
        
        let ciInput = ciImage.transformed(by: .init(scaleX: tileWidth / ciImage.extent.width, y: tileHeight / ciImage.extent.height))
        var ciOutput = CIImage(color: .clear).cropped(to: CGRect(x: 0, y: 0, width: tileWidth * UPSCALE_FAC, height: tileHeight * UPSCALE_FAC))
        
        for x in 0..<Int(tileNumX) {
            for y in 0..<Int(tileNumY) {
                let ciPart = ciInput
                    .cropped(to: CGRect(x: CGFloat(x) * (TILE_SIZE - OVERLAP_SIZE),
                                        y: CGFloat(y) * (TILE_SIZE - OVERLAP_SIZE),
                                        width: TILE_SIZE, height: TILE_SIZE))
                    .transformed(by: .init(translationX: -CGFloat(x) * (TILE_SIZE - OVERLAP_SIZE),
                                           y: -CGFloat(y) * (TILE_SIZE - OVERLAP_SIZE)))
                
                let handler = VNImageRequestHandler(ciImage: ciPart)
                
                try? handler.perform([request])
                
                if let pixelBuffer = request.results?.first as? VNPixelBufferObservation {
                    var ciPartOut = CIImage(cvImageBuffer: pixelBuffer.pixelBuffer)
                    
                    ciPartOut = ciPartOut
                        .transformed(by: .init(scaleX: TILE_SIZE * UPSCALE_FAC / ciPartOut.extent.width,
                                               y: TILE_SIZE * UPSCALE_FAC / ciPartOut.extent.height))
                        .transformed(by: .init(translationX: CGFloat(x) * UPSCALE_FAC * (TILE_SIZE - OVERLAP_SIZE),
                                               y: CGFloat(y) * UPSCALE_FAC * (TILE_SIZE - OVERLAP_SIZE)))
                    
                    ciOutput = processCIImageOverlap(image: ciPartOut, indexX: x, indexY: y).composited(over: ciOutput)
                }
            }
        }
        
        return ciOutput.transformed(by: .init(scaleX: ciImage.extent.width * UPSCALE_FAC / ciOutput.extent.width,
                                              y: ciImage.extent.height * UPSCALE_FAC / ciOutput.extent.height))
    }
    
    private func processCIImageOverlap(image: CIImage, indexX: Int, indexY: Int) -> CIImage {
        var mask = CIImage(color: .white).cropped(to: image.extent)
        
        if indexX != 0,
           let gradient = createCIImageGradient(on: image.extent, direc: .hoz) {
            mask = mask.applyingFilter("CISourceInCompositing", parameters: [
                kCIInputBackgroundImageKey: gradient
            ])
        }
        
        if indexY != 0,
           let gradient = createCIImageGradient(on: image.extent, direc: .vel) {
            mask = mask.applyingFilter("CISourceInCompositing", parameters: [
                kCIInputBackgroundImageKey: gradient
            ])
        }
        
        return image.applyingFilter("CISourceInCompositing", parameters: [
            kCIInputBackgroundImageKey: mask
        ])
    }
    
    private func createCIImageGradient(on extent: CGRect, direc: GradientDirection) -> CIImage? {
        let generator = CIFilter.linearGradient()
        
        generator.color0 = .clear
        generator.color1 = .white
        generator.point0 = CGPoint(x: extent.minX, y: extent.minY)
        generator.point1 = CGPoint(x: extent.minX + (direc == .hoz ? OVERLAP_SIZE * UPSCALE_FAC : 0),
                                   y: extent.minY + (direc == .vel ? OVERLAP_SIZE * UPSCALE_FAC : 0))
        
        return generator.outputImage?.cropped(to: extent)
    }
}
