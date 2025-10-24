//
//  MetalOutput.swift
//  ModuleTest
//
//  Created by Azuby on 10/12/24.
//

import UIKit
import Metal
import MetalKit

class MetalOutput {
    private let texture: MTLTexture
    
    init(texture: MTLTexture) {
        self.texture = texture
    }
    
    func getTexture() -> MTLTexture {
        return texture
    }
    
    func makeImage() -> UIImage? {
        let colorSpace = getColorSpace()
        // 5. Create CIContext with HDR-appropriate options
        let options: [CIContextOption: Any] = [
            .workingColorSpace: colorSpace,
            .outputColorSpace: colorSpace
        ]
        
        // 1. Wrap the MTLTexture in a CIImage
        guard var ciImage = CIImage(mtlTexture: texture, options: [ .colorSpace: colorSpace ]) else {
            return nil
        }
        
        ciImage = ciImage
            .transformed(by: .init(scaleX: 1, y: -1))
            .transformed(by: .init(translationX: 0, y: ciImage.extent.height))

        // 2. Create a CIContext (can reuse one instead of making new each time)
        let ciContext = CIContext(mtlDevice: texture.device, options: options)

        // 3. Render CIImage → CGImage
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }

        // 4. Wrap in UIImage
        return UIImage(cgImage: cgImage)
    }
    
    func makeImage() -> CIImage? {
        let colorSpace = getColorSpace()
        
        return CIImage(mtlTexture: texture, options: [ .colorSpace: colorSpace ])
    }
    
    private func getColorSpace() -> CGColorSpace {
        // Check if texture format suggests HDR content
        switch texture.pixelFormat {
        case .rgba16Float, .rgb10a2Unorm, .bgr10a2Unorm:
            return CGColorSpace(name: CGColorSpace.extendedSRGB) ??
                   CGColorSpace(name: CGColorSpace.sRGB)!
        default:
            return CGColorSpace(name: CGColorSpace.sRGB)!
        }
    }
}
