//
//  Photos.swift
//  Image Converter
//
//  Created by Azuby on 10/25/25.
//

import UIKit
import Photos
import PhotosUI
import AVFoundation

protocol PhotosDelegate: AnyObject {
    func didSelectPHAssets(controller: PhotosVC, assets: [PHAsset])
    func didSelectPHAsset(controller: PhotosVC, asset: PHAsset)
    func didDeselectPHAsset(controller: PhotosVC, asset: PHAsset)
}

extension PhotosDelegate {
    func didSelectPHAssets(controller: PhotosVC, assets: [PHAsset]) { }
    func didSelectPHAsset(controller: PhotosVC, asset: PHAsset) { }
    func didDeselectPHAsset(controller: PhotosVC, asset: PHAsset) { }
}

class PhotosConfig {
    let doneTitle: String
    
    init(doneTitle: String = "Convert Now") {
        self.doneTitle = doneTitle
    }
}

class PhotosVC: UIViewController {
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var limitAdd: UIButton!
    @IBOutlet weak var convertNow: UIButton!
    @IBOutlet weak var albumSelect: UIButton!
    @IBOutlet weak var botBlur: BoxGradient!
    @IBOutlet weak var botConstant: NSLayoutConstraint!
    
    private let library = AssetLibrary.shared
    private var didLoad = false
    
    private var selectedAsset: [PHAsset] = []
    
    weak var delegate: PhotosDelegate?
    weak var config: PhotosConfig?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.delegate = self
        collection.dataSource = self
        collection.allowsSelection = true
        
        if let config = config {
            convertNow.setTitle(config.doneTitle, for: .normal)
        }
        
        UIView.performWithoutAnimation {
            updateButtonAppear()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if didLoad { return }
        didLoad = true
        
        albumSelect(self)
    }
    
    ///```
    ///Reload data when back from other screen
    ///```
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        AssetLibrary.shared.request() { [self] _ in
            reload()
        }
    }
    
    private func reload() {
        albumSelect.setTitle(library.getCurrentAlbum()?.getName() ?? "Recents", for: .normal)
        
        DispatchQueue.main.async { [self] in
            let indexSet = IndexSet(integersIn: 0...0)
            
            collection.reloadSections(indexSet)
        }
    }

    @IBAction func albumSelect(_ sender: Any) {
        albumSelect.showsMenuAsPrimaryAction = true
        albumSelect.menu = UIMenu(title: "Select Album", children: library.getAllAlbum(true).enumerated().map({ (index, album) in
            return UIAction(title: album.getName()) { _ in
                DispatchQueue.main.async { [self] in
                    library.selectAlbum(index)
                    reload()
                }
            }
        }))
    }
    
    @IBAction func limitAdd(_ sender: Any) {
        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
    }
    
    @IBAction func convertNow(_ sender: Any) {
        delegate?.didSelectPHAssets(controller: self, assets: selectedAsset)
        dismiss(animated: true)
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    static func present(vc: UIViewController & PhotosDelegate, config: PhotosConfig = .init()) {
        AssetLibrary.shared.request { status in
            if status == .authorized || status == .limited {
                let nextVC = PhotosVC.create()
                (nextVC as? PhotosVC)?.delegate = vc
                (nextVC as? PhotosVC)?.config = config
                vc.present(nextVC, animated: true)
                return
            }
            
            let alert = UIAlertController(title: "Access Required", message: "Please allow this app to import from your selected photos for editing.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
                AssetLibrary.shared.request(forceSettings: true)
            }))
        }
    }
}

// COLLECTION FUNTION
extension PhotosVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset = library.getCurrentAlbum()?.getAsset(at: indexPath.row) else { return }
        
        if selectedAsset.contains(asset) {
            selectedAsset = selectedAsset.filter { $0 != asset }
            delegate?.didDeselectPHAsset(controller: self, asset: asset)
        } else {
            selectedAsset.append(asset)
            delegate?.didSelectPHAsset(controller: self, asset: asset)
        }
        
        collection.indexPathsForVisibleItems.forEach { indexPath in
            guard let cell = collection.cellForItem(at: indexPath) as? PhotoCell else { return }
            
            if let asset = library.getCurrentAlbum()?.getAsset(at: indexPath.row) {
                cell.select(selectedAsset.contains(asset))
            }
        }
        
        updateButtonAppear()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return library.getCurrentAlbum()?.getCount() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotoCell
        else { return UICollectionViewCell() }

        cell.collection = collection
        cell.loadImage(indexPath.row, view.window?.windowScene?.screen.scale ?? 1)
        
        if let asset = library.getCurrentAlbum()?.getAsset(at: indexPath.row) {
            cell.select(selectedAsset.contains(asset))
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellWidth = (collection.frame.width - 20) / 3 - 0.2

        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let isPortrait = UIDevice.current.orientation.isPortrait

        if isPad {
            cellWidth = isPortrait ? (collection.bounds.width - 40) / 5 : (collection.bounds.width - 60) / 7
            cellWidth -= 0.2
        }
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collection.collectionViewLayout.invalidateLayout()
    }
}


// PRIVATE
extension PhotosVC {
    private func updateButtonAppear() {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut, .allowUserInteraction]) { [self] in
            
            limitAdd.alpha = library.getCurrentStatus() == .limited && selectedAsset.isEmpty ? 1 : 0
            convertNow.alpha = selectedAsset.isEmpty ? 0 : 1
            botBlur.alpha = library.getCurrentStatus() != .limited && selectedAsset.isEmpty ? 0 : 1
            botConstant.constant = library.getCurrentStatus() != .limited && selectedAsset.isEmpty ? -200 : 44
            
            view.layoutIfNeeded()
        }
    }
}
