//
//  HomeEditorCell.swift
//  Image Converter
//
//  Created by Azuby on 10/27/25.
//

import UIKit
import Photos

protocol HomeEditorCellDelegate: AnyObject {
    func indexPath(for cell: HomeEditorCell) -> IndexPath?
}

class HomeEditorCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageExtension: UILabel!
    
    @IBOutlet weak var upperLabel: UILabel!
    @IBOutlet weak var lowerLabel: UILabel!
    
    @IBOutlet weak var addPhoto: UIButtonPro!
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var remove: UIButtonPro!
    
    weak var delegate: HomeEditorCellDelegate?
    
    private var didLoad = false
    
    private weak var item: ConvertItem?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        noti()
    }
    
    func initCell(_ item: ConvertItem?) {
        self.item = item
        
        guard let item = item else {
            addPhoto.setContentColor(._black)
            addPhoto.addTarget(self, action: #selector(addMorePhoto), for: .touchUpInside)
            addPhoto.isUserInteractionEnabled = true
            remove.removeTarget(self, action: #selector(removePhoto), for: .touchUpInside)
            stack.alpha = 0
            remove.alpha = 0
            return
        }
        
        addPhoto.setContentColor(._white)
        addPhoto.removeTarget(self, action: #selector(addMorePhoto), for: .touchUpInside)
        addPhoto.isUserInteractionEnabled = false
        remove.addTarget(self, action: #selector(removePhoto), for: .touchUpInside)
        stack.alpha = 1
        remove.alpha = 1
        
        try? item.getPreview { [weak self] image in
            guard let self = self else { return }
            
            if delegate?.indexPath(for: self)?.row == cHome.getSelecteds().firstIndex(of: item) {
                UIView.transition(with: imageView, duration: 0.25, options: .transitionCrossDissolve) {
                    self.imageView.image = image
                }
            }
        }
        
        updateInfo()
    }
    
    @objc private func addMorePhoto() {
        GDSender.request(with: GDObjectSystemAlert<Home>(source: addPhoto, title: "Add Photos From", message: nil, style: .actionSheet, actions: [
            .init(title: "Library", style: .default, handler: { [self] _ in
                guard let vc = findViewController() as? Home else { return }
                
                PhotosVC.present(vc: vc, delegate: HomeConverterStatic.shared,
                                 config: .init(doneTitle: "Add Photos"))
            }),
            .init(title: "Files", style: .default, handler: { [self] _ in
                GDSender.request(with: GDObjectOpenFiles<Home>(source: addPhoto,
                                                               delegate: HomeConverterStatic.shared,
                                                               files: nil, selectMultiple: true))
            }),
        ]))
    }
    
    @objc private func removePhoto() {
        if let item = item {
            cHome.removeSelected(item)
        }
    }
}

extension HomeEditorCell {
    private func noti() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateInfo), name: Controller.globalTimer01, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateInfo), name: CHome.convertSettingsUpdate, object: nil)
    }
    
    @objc private func updateInfo() {
        guard let item = item else { return }
        
        if let output = item.getOutput(),
           let fileAttrs = try? FileManager.default.attributesOfItem(atPath: output.path),
           let count = fileAttrs[.size] as? Int {
            upperLabel.text = "Estimate: \(count.toSizeString())"
        } else {
            upperLabel.text = "Calculating..."
        }
        
        if let data = item.getData() {
            lowerLabel.text = "Original: \(data.count.toSizeString())"
        } else {
            lowerLabel.text = "Loading..."
        }
        
        imageExtension.text = "JPG"
    }
}
