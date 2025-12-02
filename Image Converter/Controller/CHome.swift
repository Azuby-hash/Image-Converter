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
    static let convertResetSettings = Notification.Name(UUID().uuidString)
}

enum CHomeTab: Int {
    case convert
    case upscale
    case compare
    case settings
    case edit
    case process
    case summary
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
    
    func getMime() -> ConvertMime {
        return Model.convert.getMimeType()
    }
    
    func isKeepInfo() -> Bool {
        return Model.convert.isKeepInfo()
    }
    
    func isKeepDate() -> Bool {
        return Model.convert.isKeepDate()
    }
    
    func setMime(_ mime: ConvertMime) {
        Model.convert.setMimeType(mime)
        NotificationCenter.default.post(name: CHome.convertSettingsUpdate, object: nil)
    }
    
    func setCompression(_ compression: CGFloat) {
        Model.convert.setCompression(compression)
        NotificationCenter.default.post(name: CHome.convertSettingsUpdate, object: nil)
    }
    
    func setKeepInfo(_ keep: Bool) {
        Model.convert.setKeepInfo(keep)
        NotificationCenter.default.post(name: CHome.convertSettingsUpdate, object: nil)
    }
    
    func setKeepDate(_ keep: Bool) {
        Model.convert.setKeepDate(keep)
        NotificationCenter.default.post(name: CHome.convertSettingsUpdate, object: nil)
    }
    
    func setTab(_ index: Int) {
        selectTab = CHomeTab(rawValue: index) ?? selectTab
        
        if selectTab != .edit {
            Model.convert.reset()
            NotificationCenter.default.post(name: CHome.convertResetSettings, object: nil)
        }
        
        if selectTab != .upscale {
            Controller.shared.cUpscale.resetToDefaults()
        }
        
        if selectTab != .compare {
            Controller.shared.cCompare.resetToDefaults()
        }
        
        NotificationCenter.default.post(name: CHome.tabUpdate, object: nil)
    }
    
    func setTab(_ tab: CHomeTab) {
        selectTab = tab
        
        if selectTab != .edit && selectTab != .process && selectTab != .summary {
            Model.convert.reset()
            NotificationCenter.default.post(name: CHome.convertResetSettings, object: nil)
        }
        
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

        if Model.convert.getSelecteds().isEmpty {
            setTab(CHomeTab.convert)
        }
    }
    
    func removeSelected(_ item: ConvertItem) {
        Model.convert.setSelecteds(Model.convert.getSelecteds().filter({ $0 != item }))
        NotificationCenter.default.post(name: CHome.convertNumberUpdate, object: nil)
        
        if Model.convert.getSelecteds().isEmpty {
            setTab(CHomeTab.convert)
        }
    }
    
    func clearSelectedAssets() {
        Model.convert.setSelecteds([])
        NotificationCenter.default.post(name: CHome.convertNumberUpdate, object: nil)
        
        if Model.convert.getSelecteds().isEmpty {
            setTab(CHomeTab.convert)
        }
    }
    
    func save(item: ConvertItem, view: UIView, toPhotos: @escaping () -> Void, toFiles: UIDocumentPickerDelegate?) throws {
        guard var url = item.getOutput() else {
            throw CHomeError.save("Item undone.")
        }
        
        if Model.convert.getMimeType() == .pdf {
            let newUrl = FileManager.url(name: "\(UUID().uuidString).pdf")
            try? FileManager.default.copyItem(at: url, to: newUrl)
            url = newUrl
        }
        
        if Model.convert.getMimeType() == .pdf {
            GDSender.request(with: GDObjectOpenFiles<Home>(source: view, delegate: toFiles, files: [url], selectMultiple: false))
        } else {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
            }) { success, error in
                if !success {
                    print(error!)
                }
                
                toPhotos()
            }
        }
    }
    
    func save(view: UIView, toPhotos: @escaping () -> Void, toFiles: UIDocumentPickerDelegate?) throws {
        if Model.convert.getSelecteds().first(where: { $0.getOutput() == nil }) != nil {
            throw CHomeError.save("Have some items undone.")
        }
        
        var urls: [URL] = []
        
        for item in Model.convert.getSelecteds() {
            guard var url = item.getOutput() else {
                continue
            }
            
            if Model.convert.getMimeType() == .pdf {
                let newUrl = FileManager.url(name: "\(UUID().uuidString).pdf")
                try? FileManager.default.copyItem(at: url, to: newUrl)
                url = newUrl
            }
            
            urls.append(url)
        }
        
        if urls.isEmpty {
            throw CHomeError.save("No items")
        }

        if Model.convert.getMimeType() == .pdf {
            GDSender.request(with: GDObjectOpenFiles<Home>(source: view, delegate: toFiles, files: urls, selectMultiple: false))
        } else {
            urls.forEach { url in
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
                }) { success, error in
                    if !success {
                        print(error!)
                    }
                    
                    toPhotos()
                }
            }
        }
    }
}
