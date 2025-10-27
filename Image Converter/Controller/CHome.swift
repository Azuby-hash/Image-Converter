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
        get { Controller.cHome }
    }
}

extension UIViewController {
    var cHome: CHome {
        get { Controller.cHome }
    }
}

extension CHome {
    static let tabUpdate = Notification.Name(UUID().uuidString)
    static let convertNumberUpdate = Notification.Name(UUID().uuidString)
    static let convertSettingsUpdate = Notification.Name(UUID().uuidString)
}

extension Controller {
    static let cHome = CHome()
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
    private var selectedAssets: [PHAsset] = []
    
    func getTab() -> CHomeTab {
        return selectTab
    }
    
    func getSelectedAssets() -> [PHAsset] {
        return selectedAssets
    }
    
    func setTab(_ index: Int) {
        selectTab = CHomeTab(rawValue: index) ?? selectTab
        NotificationCenter.default.post(name: CHome.tabUpdate, object: nil)
    }
    
    func setSelectedAssets(_ assets: [PHAsset]) {
        selectedAssets = assets
        NotificationCenter.default.post(name: CHome.convertNumberUpdate, object: nil)
    }
    
    func appendSelectedAsset(_ asset: PHAsset) {
        selectedAssets.append(asset)
        NotificationCenter.default.post(name: CHome.convertNumberUpdate, object: nil)
    }
    
    func clearSelectedAssets() {
        selectedAssets.removeAll()
        NotificationCenter.default.post(name: CHome.convertNumberUpdate, object: nil)
    }
}
