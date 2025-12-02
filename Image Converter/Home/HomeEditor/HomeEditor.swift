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
    @IBOutlet weak var progressHidden: UIStackView!
    
    @IBOutlet weak var summaryBox: UIStackView!
    @IBOutlet weak var summaryNum: UILabel!
    @IBOutlet weak var summaryOriSize: UILabel!
    @IBOutlet weak var summaryOutSize: UILabel!
    @IBOutlet weak var summaryOriType: UILabel!
    @IBOutlet weak var summaryOutType: UILabel!
    
    @IBOutlet weak var saveB: UIView!
    
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
        cHome.setTab(CHomeTab.process)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut) { [self] in
            progressWidth.constant = progressBox.bounds.width
            layoutIfNeeded()
        } completion: { [self] _ in
            waitForBool { [self] in
                return cHome.getSelecteds().first(where: { $0.getOutput() == nil }) == nil
            } completion: { [self] in
                cHome.setTab(CHomeTab.summary)
                
                if !UserDefaults.standard.bool(forKey: "414eba80-a41c-4052-a9e7-72ea23a3c883") {
                    GDSender.request(with: GDObjectPageup<Home, Rating, GDObjectPageupDelegateIgnore>(delegate: nil))
                }
            }
        }
    }
    
    @IBAction func save(_ button: UIButton) {
        try? cHome.save(view: button, toPhotos: {
            DispatchQueue.main.async {
                self.showActivity()
            }
        }, toFiles: self)
    }
}

extension HomeEditor: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        DispatchQueue.main.async {
            self.showActivity()
        }
    }
    
    private func showActivity() {
        GDSender.request(with: GDObjectSystemAlert<Home>(source: self, title: "Saved", message: "Image is saved to your destination", actions: [
            .init(title: "OK", style: .cancel),
            .init(title: "Share", style: .default, handler: { [self] _ in
                var urls: [URL] = []
                
                for item in cHome.getSelecteds() {
                    guard let url = item.getOutput() else {
                        continue
                    }
                    
                    urls.append(url)
                }
                
                let ac = UIActivityViewController(activityItems: urls, applicationActivities: nil)
                ac.popoverPresentationController?.sourceView = saveB
                ac.popoverPresentationController?.sourceRect = saveB.bounds
                
                findViewController()?.present(ac, animated: true)
            }),
        ]))
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
        NotificationCenter.default.addObserver(self, selector: #selector(summayUpdate), name: Controller.globalTimer25, object: nil)
    }
    
    @objc private func tabUpdate() {
        progressHidden.isUserInteractionEnabled = cHome.getTab() != .process && cHome.getTab() != .summary
        
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut, .allowUserInteraction]) { [self] in
            alpha = cHome.getTab() == .edit || cHome.getTab() == .process || cHome.getTab() == .summary ? 1 : 0
            clear.alpha = cHome.getTab() == .edit || cHome.getTab() == .process || cHome.getTab() == .summary ? 1 : 0
            convertB.alpha = cHome.getTab() == .edit ? 1 : 0
            progressBox.alpha = cHome.getTab() == .process ? 1 : 0
            
            progressHidden.alpha = 1
            
            if cHome.getTab() == .process {
                progressHidden.alpha = 0.5
            }
            
            if cHome.getTab() == .summary {
                progressHidden.alpha = 0
            }
            
            summaryBox.alpha = cHome.getTab() == .summary ? 1 : 0
            saveB.alpha = cHome.getTab() == .summary ? 1 : 0
        }
        
        if cHome.getTab() == .convert {
            UIView.performWithoutAnimation {
                progressWidth.constant = 0
                layoutIfNeeded()
            }
        }
    }
    
    @objc private func summayUpdate() {
        summaryNum.text = "\(cHome.getSelecteds().count)"
        
        var oriSize = 0
        var outSize = 0
        var types = [ConvertMime]()
        
        for selected in cHome.getSelecteds() {
            if let data = selected.getData() {
                oriSize += data.count
            }
            
            if let output = selected.getOutput(),
               let fileAttrs = try? FileManager.default.attributesOfItem(atPath: output.path),
               let count = fileAttrs[.size] as? Int {
                outSize += count
            }
            
            if let type = try? selected.getType(), !types.contains(type) {
                types.append(type)
            }
        }
        
        summaryOriSize.text = Double(oriSize).toSizeString()
        summaryOutSize.text = Double(outSize).toSizeString()
        summaryOriType.text = types.map({ $0.rawValue.uppercased() }).joined(separator: ", ")
        summaryOutType.text = cHome.getMime().rawValue.uppercased()
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
