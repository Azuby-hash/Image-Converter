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
        
        setup()
        noti()
    }
}

extension HomeEditorSettings: SliderDelegate {
    func onEnd(_ slider: Slider) {
        cHome.setCompression(slider.value)
    }
}

extension HomeEditorSettings {
    private func setup() {
        compressionSlider.delegate = self
    }
}

extension HomeEditorSettings {
    private func noti() {
        NotificationCenter.default.addObserver(self, selector: #selector(reset), name: CHome.convertResetSettings, object: nil)
    }
    
    @objc private func reset() {
        compressionSlider.setCurrentPoint(at: cHome.getCompression())
    }
}
