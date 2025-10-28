//
//  HomeConverter.swift
//  Image Converter
//
//  Created by Azuby on 10/24/25.
//

import UIKit
import Photos

class HomeConverter: UIStackView {
    private var didLoad = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        setup()
        noti()
    }
    
    @IBAction func openFiles(_ sender: Any) {
        
    }
    
    @IBAction func openPhotos(_ sender: Any) {
        guard let vc = findViewController() as? Home else { return }
        
        PhotosVC.present(vc: vc)
    }
}

extension Home: PhotosDelegate {
    func didSelectPHAssets(controller: PhotosVC, assets: [PHAsset]) {
        cHome.setTab(CHomeTab.edit.rawValue)
    }
    
    func didSelectPHAsset(controller: PhotosVC, asset: PHAsset) {
        cHome.appendSelected(asset)
    }
    
    func didDeselectPHAsset(controller: PhotosVC, asset: PHAsset) {
        cHome.removeSelected(asset)
    }
}

extension HomeConverter {
    private func setup() {
        UIView.performWithoutAnimation {
            tabUpdate()
        }
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
