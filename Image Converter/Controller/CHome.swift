//
//  CHome.swift
//  Image Converter
//
//  Created by Azuby on 10/23/25.
//

import UIKit
import Photos

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
    
    func setTab(_ index: Int) {
        selectTab = CHomeTab(rawValue: index) ?? selectTab
        NotificationCenter.default.post(name: CHome.tabUpdate, object: nil)
    }
    
    func appendSelected(_ asset: PHAsset) {
        Model.convert.setSelecteds(Model.convert.getSelecteds() + [ConvertItem(asset: asset)])
        NotificationCenter.default.post(name: CHome.convertNumberUpdate, object: nil)
    }
    
    func removeSelected(_ asset: PHAsset) {
        Model.convert.setSelecteds(Model.convert.getSelecteds().filter({ $0.getAsset() != asset }))
        NotificationCenter.default.post(name: CHome.convertNumberUpdate, object: nil)
    }
    
    func clearSelectedAssets() {
        Model.convert.setSelecteds([])
        NotificationCenter.default.post(name: CHome.convertNumberUpdate, object: nil)
    }
}
