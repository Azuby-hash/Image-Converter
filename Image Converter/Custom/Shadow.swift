//
//  CustomShadow.swift
//  Image Converter
//
//  Created by Azuby on 10/23/25.
//

import UIKit

class GrayShadow: UIViewShadow {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        shadowRadius = 10
        shadowColor = ._gray60
        shadowOpacity = 0.05
        shadowOffset = .init(width: -2, height: 4)
    }
}
