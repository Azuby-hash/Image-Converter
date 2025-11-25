//
//  CGIF.swift
//  Image GIFer
//
//  Created by Azuby on 10/23/25.
//

import UIKit
import Photos

enum CGIFError: Error {
    case save(String)
}

extension UIView {
    var cGIF: CGIF {
        get { Controller.shared.cGIF }
    }
}

extension UIViewController {
    var cGIF: CGIF {
        get { Controller.shared.cGIF }
    }
}

extension CGIF {
    static let statusUpdate = Notification.Name(UUID().uuidString)
    static let selectUpdate = Notification.Name(UUID().uuidString)
    static let numberUpdate = Notification.Name(UUID().uuidString)
    static let settingsUpdate = Notification.Name(UUID().uuidString)
}

enum CGIFStatus: Int {
    case settings
    case process
    case summary
}

class CGIF {
    private var status = CGIFStatus.settings
    
    private var currSelect: GIFItem?
    
    func resetToDefaults() {
        Model.gif.resetToDefaults()
    }
    
    func getStatus() -> CGIFStatus {
        return status
    }
    
    func getCurrSelect() -> GIFItem? {
        return currSelect
    }
    
    func getSelecteds() -> [GIFItem] {
        return Model.gif.getSelecteds()
    }
    
    func getCompression() -> CGFloat {
        return Model.gif.getCompression()
    }

    func setCompression(_ compression: CGFloat) {
        Model.gif.setCompression(compression)
        NotificationCenter.default.post(name: CGIF.settingsUpdate, object: nil)
    }

    func setStatus(_ index: Int) {
        status = CGIFStatus(rawValue: index) ?? status

        NotificationCenter.default.post(name: CGIF.statusUpdate, object: nil)
    }
    
    func setTab(_ tab: CGIFStatus) {
        status = tab

        NotificationCenter.default.post(name: CGIF.statusUpdate, object: nil)
    }
    
    func selectItem(_ item: GIFItem?) {
        currSelect = item

        NotificationCenter.default.post(name: CGIF.selectUpdate, object: nil)
    }
    
    func appendSelected(_ item: Data) {
        let item = GIFItem(data: item)
        
        Model.gif.setSelecteds(Model.gif.getSelecteds() + [item])
        NotificationCenter.default.post(name: CGIF.numberUpdate, object: nil)
        
        if currSelect == nil && !Model.gif.getSelecteds().isEmpty {
            selectItem(item)
        }
    }
    
    func removeSelected(_ data: Data) {
        let previousSelecteds = Model.gif.getSelecteds()
        
        Model.gif.setSelecteds(Model.gif.getSelecteds().filter({ $0.getData() != data }))
        NotificationCenter.default.post(name: CGIF.numberUpdate, object: nil)
        
        if let index = previousSelecteds.firstIndex(where: { $0.getData() == data }) {
            if index == previousSelecteds.count - 1, previousSelecteds.indices.contains(index - 1) {
                selectItem(previousSelecteds[index - 1])
            } else if Model.gif.getSelecteds().indices.contains(index) {
                selectItem(Model.gif.getSelecteds()[index])
            } else {
                selectItem(nil)
            }
        }
    }
    
    func removeSelected(_ item: GIFItem) {
        let previousSelecteds = Model.gif.getSelecteds()
        
        Model.gif.setSelecteds(Model.gif.getSelecteds().filter({ $0 != item }))
        NotificationCenter.default.post(name: CGIF.numberUpdate, object: nil)
        
        if let index = previousSelecteds.firstIndex(of: item) {
            if index == previousSelecteds.count - 1, previousSelecteds.indices.contains(index - 1) {
                selectItem(previousSelecteds[index - 1])
            } else if Model.gif.getSelecteds().indices.contains(index) {
                selectItem(Model.gif.getSelecteds()[index])
            } else {
                selectItem(nil)
            }
        }
    }

    func save(view: UIView, toPhotos: @escaping () -> Void) throws {
//        guard let url = Model.gif.getOutput() else {
//            throw CGIFError.save("Item undone.")
//        }
//        
//        PHPhotoLibrary.shared().performChanges({
//            PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
//        }) { success, error in
//            if !success {
//                print(error!)
//            }
//            
//            toPhotos()
//        }
    }
}
