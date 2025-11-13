//
//  GDObjectOpenFiles.swift
//  PrinttoSize
//
//  Created by TapUniverse Dev9 on 20/12/24.
//

import UIKit
import Photos

extension GDReceiver {
    func receiveOpenFiles(_ noti: Notification) {
        guard let destinition = destinition as? UIViewController,
              let object = noti.object as? GDObjectCoreOpenFiles<GD>
        else { return }
        
        object.show(from: destinition)
    }
}

class GDObjectCoreOpenFiles<GD: GDReceiverProtocol>: GDObject<GD> {
    private(set) weak var source: UIView?
    
    fileprivate init(source: UIView) {
        self.source = source
    }
    
    fileprivate func show(from viewController: UIViewController) { }
}

protocol GDObjectOpenFilesDelegate: AnyObject {
    func doneSelectPhoto(images: [UIImage])
}

fileprivate var holderGDOF = [String: Any]()

class GDObjectOpenFiles<GD: GDReceiverProtocol & UIViewController>: GDObjectCoreOpenFiles<GD> {
    private weak var delegate: UIDocumentPickerDelegate?
    
    private var id = UUID().uuidString
    private var files: [URL]?
    private var selectMultiple: Bool
    
    init(source: UIView, delegate: UIDocumentPickerDelegate?, files: [URL]?, selectMultiple: Bool) {
        self.selectMultiple = selectMultiple
        super.init(source: source)
        self.delegate = delegate
        self.files = files
        
        holderGDOF[id] = self
    }

    override func show(from viewController: UIViewController) {
        var fileCol = UIDocumentPickerViewController(forOpeningContentTypes: [.image], asCopy: true)
        fileCol.allowsMultipleSelection = selectMultiple
        fileCol.modalPresentationStyle = .fullScreen
        
        if let files = files {
            fileCol = UIDocumentPickerViewController(forExporting: files)
        }
        
        fileCol.delegate = delegate
        
        viewController.present(fileCol, animated: true)
    }
}
