//
//  Utility.swift
//  Image Converter
//
//  Created by TapUniverse Dev9 on 14/11/25.
//

import UIKit
import Photos

class GIFCombine: UIViewController, GDReceiverProtocol {
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBOutlet weak var width: NSLayoutConstraint!
    @IBOutlet weak var height: NSLayoutConstraint!
    
    @IBOutlet weak var box: UIView!
    @IBOutlet weak var empty: GIFCombineEmpty!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var collection: UICollectionView!
    
    private var didLoad = false
    
    private let globalDelegate = GDReceiver<GIFCombine>()
    
    private var items: [GIFItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scroll.delegate = self
        globalDelegate.attach(destinition: self)
        
        setup()
        noti()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if didLoad { return }
        didLoad = true
        
        openPhoto(self)
    }

    @IBAction func close(_ sender: Any) {
        cGIF.resetToDefaults()
        dismiss(animated: true)
    }
    
    @IBAction func openPhoto(_ sender: Any) {
        PhotosVC.present(vc: self, delegate: GIFCombineStatic.shared, config: .init(doneTitle: "Add Photos"))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        selectUpdate()
    }
}

extension GIFCombine {
    private func setup() {
        items = cGIF.getSelecteds()
        
        collection.delegate = self
        collection.dataSource = self
    }
}

extension GIFCombine {
    private func noti() {
        NotificationCenter.default.addObserver(self, selector: #selector(numberUpdate), name: CGIF.numberUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectUpdate), name: CGIF.selectUpdate, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(statusUpdate), name: CGIF.statusUpdate, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(summayUpdate), name: Controller.globalTimer25, object: nil)
    }
    
//    @objc private func statusUpdate() {
//        progressHidden.isUserInteractionEnabled = cGIF.getTab() != .process && cGIF.getTab() != .summary
//        
//        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut, .allowUserInteraction]) { [self] in
//            alpha = cGIF.getTab() != .convert && cGIF.getTab() != .utility ? 1 : 0
//            clear.alpha = cGIF.getTab() != .convert && cGIF.getTab() != .utility ? 1 : 0
//            convertB.alpha = cGIF.getTab() == .edit ? 1 : 0
//            progressBox.alpha = cGIF.getTab() == .process ? 1 : 0
//            
//            progressHidden.alpha = 1
//            
//            if cGIF.getTab() == .process {
//                progressHidden.alpha = 0.5
//            }
//            
//            if cGIF.getTab() == .summary {
//                progressHidden.alpha = 0
//            }
//            
//            summaryBox.alpha = cGIF.getTab() == .summary ? 1 : 0
//            saveB.alpha = cGIF.getTab() == .summary ? 1 : 0
//        }
//        
//        if cGIF.getTab() == .convert {
//            UIView.performWithoutAnimation {
//                progressWidth.constant = 0
//                layoutIfNeeded()
//            }
//        }
//    }
//    
//    @objc private func summayUpdate() {
//        summaryNum.text = "\(cGIF.getSelecteds().count)"
//        
//        var oriSize = 0
//        var outSize = 0
//        var types = [ConvertMime]()
//        
//        for selected in cGIF.getSelecteds() {
//            if let data = selected.getData() {
//                oriSize += data.count
//            }
//            
//            if let output = selected.getOutput(),
//               let fileAttrs = try? FileManager.default.attributesOfItem(atPath: output.path),
//               let count = fileAttrs[.size] as? Int {
//                outSize += count
//            }
//            
//            if let type = try? selected.getType(), !types.contains(type) {
//                types.append(type)
//            }
//        }
//        
//        summaryOriSize.text = Double(oriSize).toSizeString()
//        summaryOutSize.text = Double(outSize).toSizeString()
//        summaryOriType.text = types.map({ $0.rawValue.uppercased() }).joined(separator: ", ")
//        summaryOutType.text = cGIF.getMime().rawValue.uppercased()
//    }
    
    @objc private func selectUpdate() {
        for cell in (collection.visibleCells as? [GIFCombineCell] ?? []) {
            cell.setSelect(cell.item == cGIF.getCurrSelect())
        }
        
        if let data = cGIF.getCurrSelect()?.getData(),
           let image = UIImage(data: data) {
            let size = image.size.aspectFit(to: box.bounds.insetBy(dx: 48, dy: 0).size)
            
            width.constant = size.width
            height.constant = size.height
            
            UIView.transition(with: imageView, duration: 0.25, options: .transitionCrossDissolve) { [self] in
                imageView.image = image
                empty.alpha = 0
                view.layoutIfNeeded()
            }
        } else {
            UIView.transition(with: imageView, duration: 0.25, options: .transitionCrossDissolve) { [self] in
                imageView.image = nil
                empty.alpha = 1
            }
        }
    }
    
    @objc private func numberUpdate() {
        let newItems = cGIF.getSelecteds()
        let oldItems = items
        
        oldItems.transformArray(to: newItems) { [self] item, index in
            collection.performBatchUpdates {
                collection.insertItems(at: [IndexPath(row: index, section: 0)])
                items.insert(item, at: index)
            }
        } remove: { [self] index in
            collection.performBatchUpdates {
                collection.deleteItems(at: [IndexPath(row: index, section: 0)])
                items.remove(at: index)
            }
        } move: { [self] from, to in
            collection.performBatchUpdates {
                collection.moveItem(at: IndexPath(row: from, section: 0), to: IndexPath(row: to, section: 0))
                let item = items.remove(at: from)
                items.insert(item, at: to)
            }
        }
    }
}

class GIFCombineStatic: UIView {
    static let shared = GIFCombineStatic()
}

extension GIFCombineStatic: PhotosDelegate {
    func didSelectPHAssets(controller: PhotosVC, assets: [PHAsset]) {
        
    }
    
    func didSelectPHAsset(controller: PhotosVC, asset: PHAsset) {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { [self] data, _, _, _ in
            guard let data = data else { return }
            
            cGIF.appendSelected(data)
        }
    }
    
    func didDeselectPHAsset(controller: PhotosVC, asset: PHAsset) {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { [self] data, _, _, _ in
            guard let data = data else {
                return
            }
            
            cGIF.removeSelected(data)
        }
    }
}

extension GIFCombine: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
}

extension GIFCombine: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? GIFCombineCell,
              let item = cell.item
        else { return }
        
        cGIF.selectItem(item)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? GIFCombineCell else {
            return UICollectionViewCell()
        }
        
        if cGIF.getSelecteds().indices.contains(indexPath.row) {
            cell.initCell(cGIF.getSelecteds()[indexPath.row])
        } else {
            cell.initCell(nil)
        }
        
        cell.delegate = self
        
        cell.setSelect(cell.item == cGIF.getCurrSelect() && cGIF.getCurrSelect() != nil)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collection.bounds.height, height: collection.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
}

extension GIFCombine: GIFCombineCellDelegate {
    func indexPath(for cell: GIFCombineCell) -> IndexPath? {
        return collection.indexPath(for: cell)
    }
}
