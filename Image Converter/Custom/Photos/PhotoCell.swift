//
//  PhotoCell.swift
//  BlurPhoto
//
//  Created by Tap Dev5 on 31/12/2021.
//
import UIKit
import Photos

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var selector: UIView!
    
    weak var collection: UICollectionView?
    
    func loadImage(_ ind: Int, _ scale: CGFloat) {
        
        imgV.image = nil
        
        guard let asset = AssetLibrary.shared.getCurrentAlbum()?.getAsset(at: ind) else { return }
        
        AssetLibrary.shared.getUIImage(from: asset, size: bounds.size.applying(.init(scaleX: scale, y: scale)), quality: .opportunistic, resizeMode: .fast) { [self] image in
            if let index = collection?.indexPath(for: self)?.row,
               index == ind {
                UIView.transition(with: imgV, duration: 0.25, options: .transitionCrossDissolve) { [self] in
                    imgV.image = image
                }
            }
        }
    }
    
    func select(_ bool: Bool) {
        selector.alpha = bool ? 1 : 0
    }
}
