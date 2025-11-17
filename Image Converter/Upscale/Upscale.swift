//
//  Utility.swift
//  Image Converter
//
//  Created by TapUniverse Dev9 on 14/11/25.
//

import UIKit
import Photos

class Upscale: UIViewController {
    @IBOutlet weak var width: NSLayoutConstraint!
    @IBOutlet weak var height: NSLayoutConstraint!
    
    @IBOutlet weak var box: UIView!
    @IBOutlet weak var empty: UpscaleEmpty!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var sizeBefore: UILabel!
    @IBOutlet weak var sizeAfter: UILabel!
    
    @IBOutlet weak var upscaleB: UIView!
    @IBOutlet weak var saveB: UIView!
    
    private var didLoad = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveB.alpha = 0
        upscaleB.alpha = 0.5
        upscaleB.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if didLoad { return }
        didLoad = true
        
        openPhoto(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        update()
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func upscale(_ sender: Any) {
        
    }
    
    @IBAction func save(_ sender: Any) {
        
    }
    
    @IBAction func openPhoto(_ sender: Any) {
        PhotosVC.present(vc: self, delegate: self)
    }
}

extension Upscale {
    private func noti() {
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: CUpscale.update, object: nil)
    }
    
    @objc private func update() {
        do {
            let size = try cUpscale.getInputImage().size.aspectFit(to: box.bounds.insetBy(dx: 48, dy: 48).size)
            
            width.constant = size.width
            height.constant = size.height
            
            view.layoutIfNeeded()
            
            empty.alpha = 0
            upscaleB.alpha = 1
            upscaleB.isUserInteractionEnabled = true
        } catch {
            print(error)
        }
    }
}

extension Upscale: PhotosDelegate {
    func didSelectPHAssets(controller: PhotosVC, assets: [PHAsset]) {
        cHome.setTab(CHomeTab.edit)
    }
    
    func didSelectPHAsset(controller: PhotosVC, asset: PHAsset) {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { [self] data, _, _, _ in
            guard let data = data,
                  let date = asset.creationDate
            else { return }
            
            try? cUpscale.selectItem(data: data, date: date)
    
            controller.dismiss(animated: true)
        }
    }
}
