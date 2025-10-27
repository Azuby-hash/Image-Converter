//
//  HomeEditor.swift
//  Image Converter
//
//  Created by Azuby on 10/24/25.
//

import UIKit

class HomeEditor: UIView {
    @IBOutlet weak var clear: UIButton!
    
    private var didLoad = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        setup()
        noti()
    }
    
    @IBAction func clear(_ sender: Any) {
        cHome.clearSelectedAssets()
        cHome.setTab(CHomeTab.convert.rawValue)
    }
}

extension HomeEditor {
    private func setup() {
        UIView.performWithoutAnimation {
            tabUpdate()
        }
    }
}

extension HomeEditor {
    private func noti() {
        NotificationCenter.default.addObserver(self, selector: #selector(tabUpdate), name: CHome.tabUpdate, object: nil)
    }
    
    @objc private func tabUpdate() {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut, .allowUserInteraction]) { [self] in
            alpha = cHome.getTab() == .edit ? 1 : 0
            clear.alpha = cHome.getTab() == .edit ? 1 : 0
        }
    }
}
