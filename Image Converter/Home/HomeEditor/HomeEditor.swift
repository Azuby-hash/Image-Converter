//
//  HomeEditor.swift
//  Image Converter
//
//  Created by Azuby on 10/24/25.
//

import UIKit

class HomeEditor: UIView {
    @IBOutlet weak var clear: UIButton!
    @IBOutlet weak var selected: UICollectionView!
    
    private var didLoad = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        setup()
        noti()
    }
    
    @IBAction func clear(_ sender: Any) {
        cHome.clearSelectedAssets()
        cHome.setTab(CHomeTab.convert.rawValue)
    }
}

extension HomeEditor {
    private func setup() {
        UIView.performWithoutAnimation {
            tabUpdate()
        }
        
        selected.delegate = self
        selected.dataSource = self
    }
}

extension HomeEditor {
    private func noti() {
        NotificationCenter.default.addObserver(self, selector: #selector(tabUpdate), name: CHome.tabUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(numberUpdate), name: CHome.convertNumberUpdate, object: nil)
    }
    
    @objc private func tabUpdate() {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut, .allowUserInteraction]) { [self] in
            alpha = cHome.getTab() == .edit ? 1 : 0
            clear.alpha = cHome.getTab() == .edit ? 1 : 0
        }
    }
    
    @objc private func numberUpdate() {
        selected.reloadSections(IndexSet(0...0))
    }
}

extension HomeEditor: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cHome.getSelecteds().count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = selected.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? HomeEditorCell else {
            return UICollectionViewCell()
        }
        
        if cHome.getSelecteds().indices.contains(indexPath.row) {
            cell.initCell(cHome.getSelecteds()[indexPath.row])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = selected.bounds.height / 200 * 154
        
        return CGSize(width: width, height: selected.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
