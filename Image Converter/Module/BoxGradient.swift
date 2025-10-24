//
//  GradientView.swift
//  AIArtGenerator
//
//  Created by Tap Dev5 on 20/09/2022.
//

import UIKit


// Simple version of gradient view
class GradientView: UIView {
    @IBInspectable var firstColor: UIColor = .clear
    @IBInspectable var secondColor: UIColor = .clear
    
    override final class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    override var layer: CAGradientLayer {
        return super.layer as! CAGradientLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.colors = [firstColor.cgColor, secondColor.cgColor]
        layer.frame = bounds
    }
}



class BoxGradient: UIView {
    override final class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    override var layer: CAGradientLayer {
        return super.layer as! CAGradientLayer
    }

    @IBInspectable var firstColor: UIColor = UIColor.white {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var secondColor: UIColor = UIColor.white {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var thirdColor: UIColor? = nil {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var startPoint: CGPoint = CGPoint(x: 25, y: 0) {
        didSet {
            layer.startPoint = startPoint.applying(.init(scaleX: 0.01, y: 0.01))
        }
    }
    
    @IBInspectable var endPoint: CGPoint = CGPoint(x: 75, y: 100) {
        didSet {
            layer.endPoint = endPoint.applying(.init(scaleX: 0.01, y: 0.01))
        }
    }
    
    @IBInspectable var isStroke: Bool = false {
        didSet {
            if isStroke {
                crop.borderWidth = strokeW
                crop.borderColor = UIColor.white.cgColor
                crop.cornerRadius = cornerR
                crop.cornerCurve = .continuous
                crop.opacity = 1
            } else {
                layer.mask = nil
                crop.opacity = 0
            }
        }
    }
    
    @IBInspectable var cornerR: CGFloat = 12 {
        didSet {
            crop.cornerRadius = cornerR
        }
    }
    
    @IBInspectable var strokeW: CGFloat = 2 {
        didSet {
            crop.borderWidth = strokeW
        }
    }
    
    @IBInspectable var type: Int = 0 {
        didSet {
            switch(type) {
            case 0:
                layer.type = .axial
            case 1:
                layer.type = .conic
            case 2:
                layer.type = .radial
            default:
                layer.type = .axial
            }
        }
    }
    
    private var didLoad = false
    
    private let crop = CAShapeLayer()
    private let path = UIBezierPath()

    override func layoutSubviews() {
        crop.frame = layer.bounds
        layer.mask = isStroke ? crop : nil
        
        updateGradient()

        layoutIfNeeded()
    }
    override func layoutSublayers(of layer: CALayer) {
        crop.frame = bounds
        layer.mask = isStroke ? crop : nil
        
        updateGradient()

        layoutIfNeeded()
    }
    
    override func draw(_ rect: CGRect) {
        if didLoad { return }
        didLoad = true
        
        layer.cornerCurve = .continuous
        layer.insertSublayer(crop, at: 0)
        
        updateGradient()
        
        layer.startPoint = startPoint.applying(.init(scaleX: 0.01, y: 0.01))
        layer.endPoint = endPoint.applying(.init(scaleX: 0.01, y: 0.01))
        
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], target: self, action: #selector(traitCollectionDidChange))
        }
    }

    @objc override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Check if the user interface style has changed
        updateGradient()
    }
    
    private func updateGradient() {
        if let thirdColor = thirdColor {
            layer.colors = [firstColor.cgColor, secondColor.cgColor, thirdColor.cgColor]
        } else {
            layer.colors = [firstColor.cgColor, secondColor.cgColor]
        }
        layer.locations = thirdColor == nil ? [0, 1] : [0, 0.5, 1]
    }
}
