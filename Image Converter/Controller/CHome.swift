//
//  CHome.swift
//  Image Converter
//
//  Created by Azuby on 10/23/25.
//

import UIKit

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
    
    func getTab() -> CHomeTab {
        return selectTab
    }
    
    func setTab(_ index: Int) {
        selectTab = CHomeTab(rawValue: index) ?? selectTab
        print(selectTab)
        NotificationCenter.default.post(name: CHome.tabUpdate, object: nil)
    }
}
