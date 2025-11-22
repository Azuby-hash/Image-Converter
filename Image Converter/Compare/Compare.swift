//
//  Utility.swift
//  Image Converter
//
//  Created by TapUniverse Dev9 on 14/11/25.
//

import UIKit
import Photos

class Compare: UIViewController, GDReceiverProtocol {
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBOutlet weak var width: NSLayoutConstraint!
    @IBOutlet weak var height: NSLayoutConstraint!

    @IBOutlet weak var compare: UIView!
    @IBOutlet weak var dragger: UIView!
    @IBOutlet weak var top: NSLayoutConstraint!
    
    @IBOutlet weak var box: UIView!
    @IBOutlet weak var empty: CompareEmpty!
    @IBOutlet weak var imageFirst: UIImageView!
    @IBOutlet weak var imageSecond: UIImageView!
    @IBOutlet weak var imageLead: NSLayoutConstraint!
    
    @IBOutlet weak var infoFirst: UIStackView!
    @IBOutlet weak var infoSecond: UIStackView!
    
    private var didLoad = false
    
    private let globalDelegate = GDReceiver<Compare>()
    
    private var pendingItems: [CCompareItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        compare.alpha = 0
        
        scroll.delegate = self
        globalDelegate.attach(destinition: self)
        
        compare.gestureRecognizers = [UIPanGestureRecognizer(target: self, action: #selector(pan))]
        
        noti()
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
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        cCompare.resetToDefaults()
        super.dismiss(animated: flag, completion: completion)
    }
    
    @objc private func pan(g: UIPanGestureRecognizer) {
        let position = g.location(in: imageFirst)
        
        top.constant = min(imageFirst.bounds.height - dragger.bounds.midY - 5,
                           max(dragger.bounds.midY + 5, position.y))
        imageLead.constant = min(imageFirst.bounds.width, max(0, imageFirst.bounds.width - position.x))
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func openPhoto(_ sender: Any) {
        PhotosVC.present(vc: self, delegate: self, config: .init(doneTitle: nil))
    }
    
}

extension Compare {
    private func noti() {
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: CCompare.update, object: nil)
    }
    
    @objc private func update() {
        do {
            let first = try cCompare.getFirst()
            let second = try cCompare.getSecond()
            let size = first.image.size.aspectFit(to: box.bounds.insetBy(dx: 48, dy: 48).size)
            
            width.constant = size.width
            height.constant = size.height
            imageLead.constant = size.width / 2
            
            view.layoutIfNeeded()
            
            empty.alpha = 0
            empty.isUserInteractionEnabled = false
            
            UIView.transition(with: box, duration: 0.25, options: [.transitionCrossDissolve, .curveEaseInOut]) { [self] in
                imageFirst.image = first.image
                imageSecond.image = second.image
                
                (infoFirst.arrangedSubviews[0] as? UILabel)?.text = Double(first.data.count).toSizeString()
                (infoFirst.arrangedSubviews[1] as? UILabel)?.text = "\(Int(first.image.size.width))x\(Int(first.image.size.width))"
                (infoFirst.arrangedSubviews[2] as? UILabel)?.text = first.name
                
                (infoSecond.arrangedSubviews[0] as? UILabel)?.text = Double(second.data.count).toSizeString()
                (infoSecond.arrangedSubviews[1] as? UILabel)?.text = "\(Int(second.image.size.width))x\(Int(second.image.size.width))"
                (infoSecond.arrangedSubviews[2] as? UILabel)?.text = second.name
                
                compare.alpha = 1
                
                view.layoutIfNeeded()
            }
        } catch {
            print(error)
        }
    }
}

extension Compare: PhotosDelegate {
    func didSelectPHAssets(controller: PhotosVC, assets: [PHAsset]) {
        
    }
    
    func didSelectPHAsset(controller: PhotosVC, asset: PHAsset) {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { [self] data, _, _, _ in
            guard let data = data,
                  let date = asset.creationDate,
                  let name = PHAssetResource.assetResources(for: asset).first?.originalFilename
            else { return }
            
            do {
                pendingItems.append(try CCompareItem(data: data, date: date, name: name))
            } catch {
                print(error)
            }
            
            if pendingItems.count == 2 {
                try? cCompare.selectItems(first: pendingItems[0], second: pendingItems[1])
                
                pendingItems = []
                
                controller.dismiss(animated: true)
            }
        }
    }
}

extension Compare: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
}
