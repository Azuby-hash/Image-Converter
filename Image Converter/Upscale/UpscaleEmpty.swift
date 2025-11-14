//
//  UpscaleEmpty.swift
//  Image Converter
//
//  Created by TapUniverse Dev9 on 14/11/25.
//

import UIKit

class UpscaleEmpty: UIView {
    override final class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    override var layer: CAShapeLayer {
        return super.layer as! CAShapeLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 32).cgPath.copy(dashingWithPhase: 10, lengths: [10, 10])
        layer.strokeColor = ._gray60
        layer.lineWidth = 2
        layer.fillColor = UIColor.clear.cgColor
    }
}
