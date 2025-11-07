//
//  GDObjectSystemAlert.swift
//  PrinttoSize
//
//  Created by TapUniverse Dev9 on 20/12/24.
//

import UIKit
import VisionKit

extension GDReceiver {
    func receiveSystemAlert(_ noti: Notification) {
        guard let destinition = destinition as? UIViewController,
              let object = noti.object as? GDObjectSystemAlert<GD>
        else { return }
        
        object.show(from: destinition)
    }
}

class GDObjectSystemAlert<GD: GDReceiverProtocol>: GDObject<GD> {
    private(set) weak var source: UIView?
    private(set) var actions: [UIAlertAction]
    private(set) var title: String?
    private(set) var message: String?
    private(set) var style: UIAlertController.Style
    
    init(source: UIView, title: String?, message: String?, style: UIAlertController.Style = .alert, actions: [UIAlertAction]) {
        self.source = source
        self.actions = actions
        self.title = title
        self.message = message
        self.style = style
    }
    
    fileprivate func show(from viewController: UIViewController) {
        guard let source = source else {
            print("No source view.")
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        alert.popoverPresentationController?.sourceView = source
        alert.popoverPresentationController?.sourceRect = source.bounds
        actions.forEach({ alert.addAction($0) })
        viewController.present(alert, animated: true)
    }
}
