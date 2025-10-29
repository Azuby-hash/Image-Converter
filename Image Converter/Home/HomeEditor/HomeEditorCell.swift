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
    @IBOutlet weak var imageExtension: UIButtonPro!
    
    @IBOutlet weak var upperLabel: UILabel!
    @IBOutlet weak var lowerLabel: UILabel!
    
    @IBOutlet weak var addPhoto: UIButtonPro!
    @IBOutlet weak var stack: UIStackView!
    
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
            stack.alpha = 0
            return
        }
        
        addPhoto.setContentColor(._white)
        addPhoto.removeTarget(self, action: #selector(addMorePhoto), for: .touchUpInside)
        addPhoto.isUserInteractionEnabled = false
        stack.alpha = 1
        
        try? item.getPreview { [weak self] image in
            guard let self = self else { return }
            
            if delegate?.indexPath(for: self)?.row == cHome.getSelecteds().firstIndex(of: item) {
                UIView.transition(with: imageView, duration: 0.25, options: .transitionCrossDissolve) {
                    self.imageView.image = image
                }
            }
        }
    }
    
    @objc private func addMorePhoto() {
        guard let vc = findViewController() as? Home else { return }
        
        PhotosVC.present(vc: vc)
    }
}

extension HomeEditorCell {
    private func noti() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateInfo), name: Controller.globalTimer01, object: nil)
    }
    
    @objc private func updateInfo() {
        guard let item = item else { return }
        
//        upperLabel.text = "\(item.input.count) files"
//        lowerLabel.text = "\(item.output.count) files"
    }
}

extension HomeEditorCell: PhotosDelegate {
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
