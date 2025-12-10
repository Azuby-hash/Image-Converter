//
//  GlobalDelegates.swift
//  PrinttoSize
//
//  Created by TapUniverse Dev9 on 12/12/24.
//

import UIKit

fileprivate let GLOBAL_DELEGATE_NOTI = Notification.Name(UUID().uuidString)

class GDReceiver<GD: GDReceiverProtocol> {
    private(set) weak var destinition: GD?
    
    func attach(destinition: GD) {
        self.destinition = destinition
        
        NotificationCenter.default.addObserver(self, selector: #selector(executeTask), name: GLOBAL_DELEGATE_NOTI, object: nil)
    }
    
    @objc private func executeTask(_ noti: Notification) {
        receiveSystemAlert(noti)
        receiveOpenFiles(noti)
        receivePresent(noti)
        receivePageup(noti)
    }
}

class GDSender {
    private init() { }
    
    static func request<GD: GDReceiverProtocol>(with object: GDObject<GD>) {
        NotificationCenter.default.post(name: GLOBAL_DELEGATE_NOTI, object: object)
    }
}

class GDObject<GD: GDReceiverProtocol> { }

protocol GDReceiverProtocol: NSObject {

}
