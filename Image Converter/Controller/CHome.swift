//
//  CHome.swift
//  Image Converter
//
//  Created by Azuby on 10/23/25.
//

import UIKit
import Photos

enum CHomeError: Error {
    case save(String)
}

extension UIView {
    var cHome: CHome {
        get { Controller.shared.cHome }
    }
}

extension UIViewController {
    var cHome: CHome {
        get { Controller.shared.cHome }
    }
}

extension CHome {
    static let tabUpdate = Notification.Name(UUID().uuidString)
    static let convertNumberUpdate = Notification.Name(UUID().uuidString)
    static let convertSettingsUpdate = Notification.Name(UUID().uuidString)
}

enum CHomeTab: Int {
    case convert
    case utility
    case edit
    
    func getTitle() -> String {
        switch self {
            case .convert: return "Image Converter"
            case .utility: return "Image Utility"
            case .edit: return "Image Converter"
        }
    }
}

class CHome {
    private var selectTab = CHomeTab.convert
    
    func getTab() -> CHomeTab {
        return selectTab
    }
    
    func getSelecteds() -> [ConvertItem] {
        return Model.convert.getSelecteds()
    }
    
    func getCompression() -> CGFloat {
        return Model.convert.getCompression()
    }
    
    func setMime(_ mime: ConvertMime) {
        Model.convert.setMimeType(mime)
        NotificationCenter.default.post(name: CHome.convertSettingsUpdate, object: nil)
    }
    
    func setCompression(_ compression: CGFloat) {
        Model.convert.setCompression(compression)
        NotificationCenter.default.post(name: CHome.convertSettingsUpdate, object: nil)
    }
    
    func setTab(_ index: Int) {
        selectTab = CHomeTab(rawValue: index) ?? selectTab
        NotificationCenter.default.post(name: CHome.tabUpdate, object: nil)
    }
    
    func appendSelected(_ item: (data: Data, date: Date)) {
        Model.convert.setSelecteds(Model.convert.getSelecteds() + [ConvertItem(data: item.data, date: item.date)])
        NotificationCenter.default.post(name: CHome.convertNumberUpdate, object: nil)
    }
    
    func appendSelecteds(_ items: [(data: Data, date: Date)]) {
        Model.convert.setSelecteds(Model.convert.getSelecteds() + items.map({ ConvertItem(data: $0.data, date: $0.date) }))
        NotificationCenter.default.post(name: CHome.convertNumberUpdate, object: nil)
    }
    
    func removeSelected(_ data: Data) {
        Model.convert.setSelecteds(Model.convert.getSelecteds().filter({ $0.getData() != data }))
        NotificationCenter.default.post(name: CHome.convertNumberUpdate, object: nil)
    }
    
    func removeSelected(_ item: ConvertItem) {
        Model.convert.setSelecteds(Model.convert.getSelecteds().filter({ $0 != item }))
        NotificationCenter.default.post(name: CHome.convertNumberUpdate, object: nil)
    }
    
    func clearSelectedAssets() {
        Model.convert.setSelecteds([])
        NotificationCenter.default.post(name: CHome.convertNumberUpdate, object: nil)
    }
    
    func save(item: ConvertItem, view: UIView) throws {
        guard let url = item.getOutput() else {
            throw CHomeError.save("Item undone.")
        }
        
        if Model.convert.getMimeType() == .pdf {
            GDSender.request(with: GDObjectOpenFiles<Home>(source: view, delegate: nil, files: [url], selectMultiple: false))
        } else {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
            }) { success, error in
                if !success {
                    print(error!)
                }
            }
        }
    }
    
    func save(view: UIView) throws {
        if Model.convert.getSelecteds().first(where: { $0.getOutput() == nil }) != nil {
            throw CHomeError.save("Have some items undone.")
        }
        
        var urls: [URL] = []
        
        for item in Model.convert.getSelecteds() {
            guard let url = item.getOutput() else {
                continue
            }
            
            urls.append(url)
        }

        if Model.convert.getMimeType() == .pdf {
            GDSender.request(with: GDObjectOpenFiles<Home>(source: view, delegate: nil, files: urls, selectMultiple: false))
        } else {
            urls.forEach { url in
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
                }) { success, error in
                    if !success {
                        print(error!)
                    }
                }
            }
        }
    }
}
