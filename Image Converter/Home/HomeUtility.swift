//
//  HomeUtility.swift
//  Image Converter
//
//  Created by Azuby on 10/24/25.
//

import UIKit

class HomeUtility: UIStackView {
    private var didLoad = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        setup()
        noti()
    }
}

extension HomeUtility {
    private func setup() {
        tabUpdate()
    }
}

extension HomeUtility {
    private func noti() {
        NotificationCenter.default.addObserver(self, selector: #selector(tabUpdate), name: CHome.tabUpdate, object: nil)
    }
    
    @objc private func tabUpdate() {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut, .allowUserInteraction]) { [self] in
            alpha = cHome.getTab() == .utility ? 1 : 0
        }
    }
}
