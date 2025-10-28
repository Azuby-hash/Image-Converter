//
//  HomeEditorCell.swift
//  Image Converter
//
//  Created by Azuby on 10/27/25.
//

import UIKit

class HomeEditorCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageExtension: UIButtonPro!
    
    @IBOutlet weak var upperLabel: UILabel!
    @IBOutlet weak var lowerLabel: UILabel!
    
    private var didLoad = false
    
    private weak var item: ConvertItem?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        noti()
    }
    
    func initCell(_ item: ConvertItem) {
        self.item = item
    }
}

extension HomeEditorCell {
    private func noti() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateInfo), name: Controller.globalTimer01, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateImage), name: Controller.globalTimer25, object: nil)
    }
    
    @objc private func updateInfo() {
        guard let item = item else { return }
        
//        upperLabel.text = "\(item.input.count) files"
//        lowerLabel.text = "\(item.output.count) files"
    }
    
    @objc private func updateImage() {
        guard let item = item else { return }
        
        UIView.transition(with: imageView, duration: 0.25, options: .transitionCrossDissolve) { [self] in
            imageView.image = try? item.getPreview()
        }
    }
}
