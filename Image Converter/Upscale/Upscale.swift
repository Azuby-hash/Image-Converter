//
//  Utility.swift
//  Image Converter
//
//  Created by TapUniverse Dev9 on 14/11/25.
//

import UIKit
import Photos

class Upscale: UIViewController, GDReceiverProtocol {
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBOutlet weak var width: NSLayoutConstraint!
    @IBOutlet weak var height: NSLayoutConstraint!

    @IBOutlet weak var compare: UIView!
    @IBOutlet weak var dragger: UIView!
    @IBOutlet weak var top: NSLayoutConstraint!
    
    @IBOutlet weak var box: UIView!
    @IBOutlet weak var empty: UpscaleEmpty!
    @IBOutlet weak var imageBefore: UIImageView!
    @IBOutlet weak var imageAfter: UIImageView!
    @IBOutlet weak var imageLead: NSLayoutConstraint!
    
    @IBOutlet weak var upscaleB: UIView!
    @IBOutlet weak var saveB: UIView!
    
    private var didLoad = false
    
    private let globalDelegate = GDReceiver<Upscale>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveB.alpha = 0
        upscaleB.alpha = 0.5
        upscaleB.isUserInteractionEnabled = false
        
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
        cUpscale.resetToDefaults()
        super.dismiss(animated: flag, completion: completion)
    }
    
    @objc private func pan(g: UIPanGestureRecognizer) {
        let position = g.location(in: imageBefore)
        
        top.constant = min(imageBefore.bounds.height - dragger.bounds.midY - 5,
                           max(dragger.bounds.midY + 5, position.y))
        imageLead.constant = min(imageBefore.bounds.width, max(0, imageBefore.bounds.width - position.x))
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func upscale(_ sender: Any) {
        procLoading(srcV: view)
        
        DispatchQueue.global(qos: .default).async { [self] in
            do {
                try cUpscale.upscale()
            } catch {
                print(error)
            }
            
            DispatchQueue.main.async { [self] in
                endLoading(on: view)
            }
        }
    }
    
    @IBAction func save(_ button: UIButton) {
        try? cUpscale.save(view: button, toPhotos: {
            DispatchQueue.main.async {
                self.showActivity()
            }
        })
    }
    
    @IBAction func openPhoto(_ sender: Any) {
        PhotosVC.present(vc: self, delegate: self, config: .init(doneTitle: nil))
    }
    
}

extension Upscale: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        DispatchQueue.main.async {
            self.showActivity()
        }
    }
    
    private func showActivity() {
        GDSender.request(with: GDObjectSystemAlert<Upscale>(source: view, title: "Saved", message: "Image is saved to your destination", actions: [
            .init(title: "OK", style: .cancel),
            .init(title: "Share", style: .default, handler: { [self] _ in
                var urls: [URL] = []
                
                guard let url = try? cUpscale.getOutput() else {
                    return
                }
                
                urls.append(url)
                
                let ac = UIActivityViewController(activityItems: urls, applicationActivities: nil)
                ac.popoverPresentationController?.sourceView = saveB
                ac.popoverPresentationController?.sourceRect = saveB.bounds
                
                present(ac, animated: true)
            }),
        ]))
    }
}

extension Upscale {
    private func noti() {
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: CUpscale.update, object: nil)
    }
    
    @objc private func update() {
        do {
            let image = try cUpscale.getInputImage()
            let size = image.size.aspectFit(to: box.bounds.insetBy(dx: 48, dy: 48).size)
            
            width.constant = size.width
            height.constant = size.height
            imageLead.constant = size.width / 2
            
            view.layoutIfNeeded()
            
            empty.alpha = 0
            empty.isUserInteractionEnabled = false
            upscaleB.alpha = 1
            upscaleB.isUserInteractionEnabled = true
            
            do {
                let output = try cUpscale.getOutputImage()
    
                UIView.transition(with: imageAfter, duration: 0.25, options: [.transitionCrossDissolve, .curveEaseInOut]) { [self] in
                    upscaleB.alpha = 0
                    upscaleB.isUserInteractionEnabled = false
                    
                    saveB.alpha = 1
                    saveB.isUserInteractionEnabled = true
                    
                    imageBefore.image = image
                    imageAfter.image = output
                    
                    compare.alpha = 1
                    
                    view.layoutIfNeeded()
                }
            } catch {
                UIView.transition(with: imageAfter, duration: 0.25, options: [.transitionCrossDissolve, .curveEaseInOut]) { [self] in
                    imageBefore.image = image
                }
            }
        } catch {
            print(error)
        }
    }
}

extension Upscale: PhotosDelegate {
    func didSelectPHAssets(controller: PhotosVC, assets: [PHAsset]) {
        
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

extension Upscale: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
}
