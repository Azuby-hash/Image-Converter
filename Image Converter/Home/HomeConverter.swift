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
    
    @IBAction func openFiles(_ button: UIButton) {
        GDSender.request(with: GDObjectOpenFiles<Home>(source: button, delegate: HomeConverterStatic.shared,
                                                       files: nil, selectMultiple: true))
    }
    
    @IBAction func openPhotos(_ sender: Any) {
        guard let vc = findViewController() as? Home else { return }
        
        PhotosVC.present(vc: vc, delegate: HomeConverterStatic.shared)
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

class HomeConverterStatic: UIView {
    static let shared = HomeConverterStatic()
}

extension HomeConverterStatic: PhotosDelegate {
    func didSelectPHAssets(controller: PhotosVC, assets: [PHAsset]) {
        cHome.setTab(CHomeTab.edit.rawValue)
    }
    
    func didSelectPHAsset(controller: PhotosVC, asset: PHAsset) {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { [self] data, _, _, _ in
            guard let data = data else {
                return
            }
            
            cHome.appendSelected(data)
        }
    }
    
    func didDeselectPHAsset(controller: PhotosVC, asset: PHAsset) {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { [self] data, _, _, _ in
            guard let data = data else {
                return
            }
            
            cHome.removeSelected(data)
        }
    }
}

extension HomeConverterStatic: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        var datas = [Data]()
        
        urls.forEach { url in
            do {
                let data = try Data(contentsOf: url)
                datas.append(data)
            } catch {
                print(error)
            }
        }
        
        cHome.appendSelecteds(datas)
        cHome.setTab(CHomeTab.edit.rawValue)
    }
}
