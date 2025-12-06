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
            return
        }
        
        addPhoto.setContentColor(._white)
        addPhoto.removeTarget(self, action: #selector(addMorePhoto), for: .touchUpInside)
        addPhoto.isUserInteractionEnabled = false
        remove.addTarget(self, action: #selector(removePhoto), for: .touchUpInside)
        stack.alpha = 1
        
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
            .init(title: "Library", style: .default, handler: { _ in
                PhotosVC.present(vc: Home.self, sourceView: self, delegate: HomeConverterStatic.shared,
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
        NotificationCenter.default.addObserver(self, selector: #selector(updateInfo), name: CHome.tabUpdate, object: nil)
    }
    
    @objc private func updateInfo() {
        alpha = item == nil && (cHome.getTab() == .process || cHome.getTab() == .summary) ? 0 : 1
        remove.alpha = item == nil || cHome.getTab() == .process || cHome.getTab() == .summary ? 0 : 1
        
        guard let item = item else { return }
        
        if let output = item.getOutput(),
           let fileAttrs = try? FileManager.default.attributesOfItem(atPath: output.path),
           let count = fileAttrs[.size] as? Int {
            upperLabel.text = "Estimate: \(Double(count).toSizeString())"
        } else {
            upperLabel.text = "Calculating..."
        }
        
        guard let data = item.getData() else {
            lowerLabel.text = "Loading..."
            lowerLabel.textColor = ._gray60
            
            return
        }
        
        lowerLabel.text = "Original: \(Double(data.count).toSizeString())"
        lowerLabel.textColor = ._gray60
        
        if cHome.getTab() == .process {
            lowerLabel.text = "Processing..."
        }
        
        if cHome.getTab() == .summary {
            lowerLabel.textColor = ._green
            lowerLabel.text = "Completed!"
        }
        
        try? item.getType { [weak self] type in
            guard let self = self else { return }
            
            if delegate?.indexPath(for: self)?.row == cHome.getSelecteds().firstIndex(of: item) {
                UIView.transition(with: imageExtension, duration: 0.25, options: .transitionCrossDissolve) {
                    self.imageExtension.text = self.cHome.getTab() == .summary ? self.cHome.getMime().rawValue.uppercased() : "\(type?.rawValue.uppercased() ?? "") → \(self.cHome.getMime().rawValue.uppercased())"
                }
            }
        }
    }
}
