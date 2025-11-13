//
//  HomeEditor.swift
//  Image Converter
//
//  Created by Azuby on 10/24/25.
//

import UIKit

class HomeEditor: UIView {
    @IBOutlet weak var clear: UIButton!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var convertB: UIView!
    @IBOutlet weak var progressBox: UIView!
    @IBOutlet weak var progressWidth: NSLayoutConstraint!
    
    private var didLoad = false
    
    private var items: [ConvertItem] = []
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        setup()
        noti()
    }
    
    @IBAction func clear(_ sender: Any) {
        cHome.clearSelectedAssets()
    }
    
    @IBAction func convert(_ button: UIButton) {
        try! cHome.save(view: button)
    }
}

extension HomeEditor {
    private func setup() {
        UIView.performWithoutAnimation {
            tabUpdate()
        }
        
        items = cHome.getSelecteds()
        
        collection.delegate = self
        collection.dataSource = self
    }
}

extension HomeEditor {
    private func noti() {
        NotificationCenter.default.addObserver(self, selector: #selector(tabUpdate), name: CHome.tabUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(numberUpdate), name: CHome.convertNumberUpdate, object: nil)
    }
    
    @objc private func tabUpdate() {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut, .allowUserInteraction]) { [self] in
            alpha = cHome.getTab() != .convert && cHome.getTab() != .utility ? 1 : 0
            clear.alpha = cHome.getTab() != .convert && cHome.getTab() != .utility ? 1 : 0
        }
    }
    
    @objc private func numberUpdate() {
        let newItems = cHome.getSelecteds()
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

extension HomeEditor: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? HomeEditorCell else {
            return UICollectionViewCell()
        }
        
        if cHome.getSelecteds().indices.contains(indexPath.row) {
            cell.initCell(cHome.getSelecteds()[indexPath.row])
        } else {
            cell.initCell(nil)
        }
        
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collection.bounds.height / 200 * 154
        
        return CGSize(width: width, height: collection.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

extension HomeEditor: HomeEditorCellDelegate {
    func indexPath(for cell: HomeEditorCell) -> IndexPath? {
        return collection.indexPath(for: cell)
    }
}
