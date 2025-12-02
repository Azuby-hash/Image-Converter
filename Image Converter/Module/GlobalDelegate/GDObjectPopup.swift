//
//  GlobalTap.swift
//  PrinttoSize
//
//  Created by TapUniverse Dev9 on 12/12/24.
//

import UIKit

extension GDReceiver {
    func receivePageup(_ noti: Notification) {
        guard let destinition = destinition as? UIViewController,
              let object = noti.object as? GDObjectCorePageup<GD>
        else { return }
        
        object.show(from: destinition)
    }
}

class GDObjectCorePageup<GD: GDReceiverProtocol>: GDObject<GD> {
    fileprivate func show(from viewController: UIViewController) { }
}

class GDObjectPageupDelegateIgnore: PageupDelegate {
    func pageupDismiss(pageup: Pageup) { }
}

class GDObjectPageup<GD: GDReceiverProtocol & UIViewController, T: Pageup, D: PageupDelegate>: GDObjectCorePageup<GD> {
    private weak var delegate: D?
    
    init(delegate: D?) {
        super.init()
        self.delegate = delegate
    }
    
    override func show(from viewController: UIViewController) {
        let pageup = viewController.view.pageup(T.self)
        pageup.delegate = delegate
    }
}
