//
//  HomeTab.swift
//  Image Converter
//
//  Created by Azuby on 10/23/25.
//

import UIKit

class HomeTab: UIView {
    @IBOutlet weak var tabOldIOS: UIView!
    @IBOutlet weak var tabOldStack: UIStackView!
    @IBOutlet weak var tabOldIOSLeading: NSLayoutConstraint!
    @IBOutlet weak var tabIOS26: UITabBar!
    
    private var didLoad = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        if didLoad { return }
        didLoad = true
        
        setup()
        noti()
    }
    
    @objc private func oldTap(g: UITapGestureRecognizer) {
        let count = tabOldStack.arrangedSubviews.count
        let index = min(Int(floor(g.location(in: tabOldIOS).x / (tabOldIOS.bounds.width / CGFloat(count)))), count - 1)
        
        tabOldIOSLeading.constant = CGFloat(index) * (tabOldStack.bounds.width / CGFloat(count))
        
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut, .allowUserInteraction]) { [self] in
            layoutIfNeeded()
        }
        
        cHome.setTab(index)
    }
}

extension HomeTab: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabIOS26.items?.firstIndex(of: item) else {
            return
        }
        
        cHome.setTab(index)
    }
}

extension HomeTab {
    private func setup() {
        let count = CGFloat(tabOldStack.arrangedSubviews.count)
        let index = CGFloat(cHome.getTab().rawValue)
        
        tabOldIOS.alpha = IOS26 ? 0 : 1
        tabOldIOSLeading.constant = index * (tabOldStack.bounds.width) / count
        tabOldIOS.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(oldTap))]
        
        tabIOS26.alpha = IOS26 ? 1 : 0
        tabIOS26.selectedItem = tabIOS26.items?[cHome.getTab().rawValue]
        tabIOS26.delegate = self
        
        tabUpdate()
    }
}

extension HomeTab {
    private func noti() {
        NotificationCenter.default.addObserver(self, selector: #selector(tabUpdate), name: CHome.tabUpdate, object: nil)
    }
    
    @objc private func tabUpdate() {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut, .allowUserInteraction]) { [self] in
            alpha = cHome.getTab() == .convert || cHome.getTab() == .upscale || cHome.getTab() == .compare || cHome.getTab() == .settings ? 1 : 0
        }
    }
}
