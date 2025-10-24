//
//  VisionUsage.swift
//  BlurVideo2.0
//
//  Created by TapUniverse Dev9 on 19/9/24.
//

import UIKit

class VisionUsage {
    static func getOrientation(from affineTransform: CGAffineTransform) -> CGImagePropertyOrientation? {
        let angleInDegrees = atan2(affineTransform.b, affineTransform.a) * CGFloat(180) / CGFloat.pi
        
        var orientation: UInt32 = 1
        switch angleInDegrees {
        case 0:
            orientation = 1 // Recording button is on the right
        case 180:
            orientation = 3 // abs(180) degree rotation recording button is on the right
        case -180:
            orientation = 3 // abs(180) degree rotation recording button is on the right
        case 90:
            orientation = 8 // 90 degree CW rotation recording button is on the top
        case -90:
            orientation = 6 // 90 degree CCW rotation recording button is on the bottom
        default:
            orientation = 1
        }
        
        return CGImagePropertyOrientation(rawValue: orientation)
    }

    /**
     frame: 0011
     */
    static func specCrop(image: UIImage, rect: CGRect, spec: CGFloat, specMode: UIImageView.ContentMode, scale: CGFloat = 1, fill: UIColor? = nil) -> (originSize: CGSize, croppedImage: UIImage) {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        
        var rect = rect
        rect.origin = rect.origin.applying(.init(scaleX: image.size.width, y: image.size.height))
        rect.size = rect.size.applying(.init(scaleX: image.size.width, y: image.size.height))
        
        let percent = (specMode == .scaleAspectFill ? max : min)(spec / rect.size.width, spec / rect.size.height)
        rect.origin = rect.origin.applying(.init(scaleX: percent, y: percent))
        rect.size = rect.size.applying(.init(scaleX: percent, y: percent))
        
        let originSize = image.size.applying(.init(scaleX: percent, y: percent))
        let renderer = UIGraphicsImageRenderer(size: rect.size, format: format)
        
        return (originSize, renderer.image { ctx in
            if let fill = fill {
                ctx.cgContext.setFillColor(fill.cgColor)
                ctx.cgContext.fill([CGRect(origin: .zero, size: rect.size)])
            }
            image.draw(in: CGRect(origin: rect.origin.applying(.init(scaleX: -1, y: -1)), size: originSize))
        })
    }
}
