//
//  GIFCombineCell.swift
//  Image GIFer
//
//  Created by Azuby on 10/27/25.
//

import UIKit
import Photos

protocol GIFCombineCellDelegate: AnyObject {
    func indexPath(for cell: GIFCombineCell) -> IndexPath?
}

class GIFCombineCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhoto: UIButtonPro!
    @IBOutlet weak var remove: UIButtonPro!
    
    weak var delegate: GIFCombineCellDelegate?
    
    private(set) weak var item: GIFItem?
    
    func initCell(_ item: GIFItem?) {
        self.item = item
        
        guard let item = item else {
            addPhoto.setContentColor(._black)
            addPhoto.addTarget(self, action: #selector(addMorePhoto), for: .touchUpInside)
            addPhoto.isUserInteractionEnabled = true
            remove.removeTarget(self, action: #selector(removePhoto), for: .touchUpInside)
            remove.alpha = 0
            imageView.alpha = 0
            return
        }
        
        addPhoto.setContentColor(._white)
        addPhoto.removeTarget(self, action: #selector(addMorePhoto), for: .touchUpInside)
        addPhoto.isUserInteractionEnabled = false
        remove.addTarget(self, action: #selector(removePhoto), for: .touchUpInside)
        remove.alpha = 1
        imageView.alpha = 1
        
        try? item.getPreview { [weak self] image in
            guard let self = self else { return }
            
            if delegate?.indexPath(for: self)?.row == cGIF.getSelecteds().firstIndex(of: item) {
                UIView.transition(with: imageView, duration: 0.25, options: .transitionCrossDissolve) {
                    self.imageView.image = image
                }
            }
        }
    }
    
    func setSelect(_ select: Bool) {
        imageView.layer.borderWidth = select ? 3 : 0
        imageView.layer.borderColor = select ? UIColor._primary.cgColor : UIColor.clear.cgColor
    }
    
    @objc private func addMorePhoto() {
        guard let vc = findViewController() else { return }
        
        PhotosVC.present(vc: vc, delegate: GIFCombineStatic.shared, config: .init(doneTitle: "Add Photos"))
    }
    
    @objc private func removePhoto() {
        if let item = item {
            cGIF.removeSelected(item)
        }
    }
}
