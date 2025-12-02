//
//  GDObjectPresent.swift
//  PrinttoSize
//
//  Created by TapUniverse Dev9 on 20/12/24.
//

import UIKit
import Photos

extension GDReceiver {
    func receivePresent(_ noti: Notification) {
        guard let destinition = destinition as? UIViewController,
              let object = noti.object as? GDObjectPresent<GD>
        else { return }
        
        object.show(from: destinition)
    }
}

class GDObjectPresent<GD: GDReceiverProtocol>: GDObject<GD> {
    private(set) weak var sourceVC: UIViewController?
    
    init(sourceVC: UIViewController) {
        self.sourceVC = sourceVC
    }
    
    func show(from viewController: UIViewController) {
        guard let sourceVC = sourceVC else { return }
        
        viewController.present(sourceVC, animated: true)
    }
}
