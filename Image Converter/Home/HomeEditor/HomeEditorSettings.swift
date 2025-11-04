//
//  HomeEditorSettings.swift
//  Image Converter
//
//  Created by Azuby on 11/4/25.
//

import UIKit

class HomeEditorSettings: GrayShadow {
    @IBOutlet weak var compressionSlider: Slider!
    @IBOutlet weak var compressionValue: UIButton!
    
    private var didLoad = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        compressionSlider.delegate = self
    }
}

extension HomeEditorSettings: SliderDelegate {
    func onChanged(_ slider: Slider) {
        cHome.setCompression(slider.value)
    }
}
