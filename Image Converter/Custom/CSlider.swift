//
//  CSlider.swift
//  Image Converter
//
//  Created by Azuby on 10/30/25.
//

import UIKit

class CSlider: Slider {
    @IBInspectable var defaultValue: CGFloat = 1
    @IBInspectable var midPoint: CGFloat = 0
    @IBInspectable var snapCount: Int = 0
    @IBInspectable var isStep: Bool = false
    
    private var didLoad = false
    
    private let inner = UIView()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad {
            return
        }
        didLoad = true

        setColors([._primary, ._primary]) // at least 2 colors
        setGradient(of: .trackActive)
        
        setColors([._sort, ._sort]) // at least 2 colors
        setGradient(of: .thumb)
        
        if let thumb = getElement(.thumb).first {
            inner.translatesAutoresizingMaskIntoConstraints = false
            inner.layer.cornerRadius = 4
            inner.layer.cornerCurve = .continuous
            inner.backgroundColor = ._primary
            
            thumb.addSubview(inner)
            
            NSLayoutConstraint.activate([
                inner.centerXAnchor.constraint(equalTo: thumb.centerXAnchor),
                inner.centerYAnchor.constraint(equalTo: thumb.centerYAnchor),
                inner.widthAnchor.constraint(equalToConstant: 8),
                inner.heightAnchor.constraint(equalToConstant: 8),
            ])
        }
        
        setColors([._light10, ._light10]) // at least 2 colors
        setGradient(of: .trackUnactive)
        
        setRadius(of: .thumb, value: 26)
        setHeight(of: .trackUnactive, value: 4)
        
        layoutIfNeeded()
        
        setCurrentPoint(at: defaultValue)
        setMidPoint(at: midPoint)
        setSnapPoints(at: [], delta: 0)
        setSnapPoints(count: snapCount, delta: 0.02)
        configSnap(isStep ? .step : .normal)
        
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], target: self, action: #selector(traitCollectionDidChange))
        }
    }
    
    @objc override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        inner.backgroundColor = ._primary
        
        setColors([._primary, ._primary]) // at least 2 colors
        setGradient(of: .trackActive)
        
        setColors([._sort, ._sort]) // at least 2 colors
        setGradient(of: .thumb)
        
        setColors([._light10, ._light10]) // at least 2 colors
        setGradient(of: .trackUnactive)
    }
}
