//
//  GIFSettings.swift
//  Image Converter
//
//  Created by Azuby on 11/4/25.
//

import UIKit

class GIFCombineSettings: GrayShadow {
    @IBOutlet weak var compressionSlider: Slider!
    @IBOutlet weak var compressionValue: UIButton!
    
    private var didLoad = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        setup()
        noti()
    }
}

extension GIFCombineSettings: SliderDelegate {
    func onEnd(_ slider: Slider) {
        cGIF.setCompression(slider.value)
    }
}

extension GIFCombineSettings {
    private func setup() {
        compressionSlider.delegate = self
    }
}

extension GIFCombineSettings {
    private func noti() {
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: CGIF.settingsUpdate, object: nil)
    }
    
    @objc private func update() {
        
    }
}
