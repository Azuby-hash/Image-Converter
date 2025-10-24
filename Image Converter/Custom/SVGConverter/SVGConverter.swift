//
//  SVGConverter.swift
//  ModuleTest
//
//  Created by TapUniverse Dev9 on 20/10/25.
//

import UIKit
import Vision

class SVGConverter {
    static let shared = SVGConverter()
    
    private let metal = MetalWrapper(funcName: "SVGFilter", pixelFormat: .rgba8Unorm)
    
    func convert(from image: CIImage) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: image.extent.size, format: format)
        let input = MetalInput(ciImage: image.applyingFilter("CIColorPosterize", parameters: [ "inputLevels": 10 ]))
        
        let count: CGFloat = 10

        return renderer.image { context in
            for i in 0..<Int(count) {
                let start = CGFloat(i) / count
                let end = CGFloat(i + 1) / count
                
                metal.compute(inputs: [
                    .init(float: start),
                    .init(float: end),
                    input,
                ], reputs: [], inputSize: image.extent.size, outputSize: image.extent.size)
                
                let output: CIImage = metal.getOutput()!.makeImage()!
                
                let result = VisionModel.shared.detectContours(image: output).results!.first!
                
                var transform = CGAffineTransform(scaleX: image.extent.width, y: image.extent.height)
                let path = result.normalizedPath.copy(using: &transform)!
                let color = UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1).cgColor
                
                context.cgContext.setFillColor(color)
                context.cgContext.addPath(path)
                context.cgContext.fillPath()
            }
        }
    }
}
