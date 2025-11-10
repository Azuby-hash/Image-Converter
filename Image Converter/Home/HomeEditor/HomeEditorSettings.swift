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
    @IBOutlet weak var infoSwitch: UISwitch!
    @IBOutlet weak var dateSwitch: UISwitch!
    
    private var didLoad = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        setup()
        noti()
    }
    
    @IBAction func info(_ sender: Any) {
        cHome.setKeepInfo(infoSwitch.isOn)
    }
    
    @IBAction func date(_ sender: Any) {
        cHome.setKeepDate(dateSwitch.isOn)
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
        
        infoSwitch.setOn(cHome.isKeepInfo(), animated: false)
        infoSwitch.isOn = cHome.isKeepInfo()
        
        dateSwitch.setOn(cHome.isKeepDate(), animated: false)
        dateSwitch.isOn = cHome.isKeepDate()
    }
}

extension HomeEditorSettings {
    private func noti() {
        NotificationCenter.default.addObserver(self, selector: #selector(reset), name: CHome.convertResetSettings, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: CHome.convertSettingsUpdate, object: nil)
    }
    
    @objc private func reset() {
        compressionSlider.setCurrentPoint(at: cHome.getCompression())
    }
    
    @objc private func update() {
        compressionSlider.isUserInteractionEnabled = cHome.getMime().canCompression()
        
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.allowUserInteraction, .curveEaseInOut]) { [self] in
            
            compressionSlider.alpha = cHome.getMime().canCompression() ? 1 : 0.5
            compressionValue.alpha = cHome.getMime().canCompression() ? 1 : 0.5
            
            infoSwitch.isEnabled = cHome.getMime() != .pdf
        }
    }
}
