//
//  HomeConverter.swift
//  Image Converter
//
//  Created by Azuby on 10/24/25.
//

import UIKit

class HomeConverter: UIStackView {
    private var didLoad = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        setup()
        noti()
    }
}

extension HomeConverter {
    private func setup() {
        tabUpdate()
    }
}

extension HomeConverter {
    private func noti() {
        NotificationCenter.default.addObserver(self, selector: #selector(tabUpdate), name: CHome.tabUpdate, object: nil)
    }
    
    @objc private func tabUpdate() {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut, .allowUserInteraction]) { [self] in
            alpha = cHome.getTab() == .convert ? 1 : 0
        }
    }
}
