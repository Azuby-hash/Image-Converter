//
//  Controller.swift
//  Image Converter
//
//  Created by Azuby on 10/23/25.
//

import UIKit

extension Controller {
    static let globalTimer25 = Notification.Name(UUID().uuidString)
    static let globalTimer01 = Notification.Name(UUID().uuidString)
}

class Controller {
    static let shared = Controller()
    
    let cHome = CHome()
    
    private init() {
        FileManager.eraseDocumentAndData()
        
        Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(globalTimer01), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(globalTimer25), userInfo: nil, repeats: true)
    }
    
    @objc private func globalTimer01() {
        NotificationCenter.default.post(name: Controller.globalTimer01, object: nil)
    }
    
    @objc private func globalTimer25() {
        NotificationCenter.default.post(name: Controller.globalTimer25, object: nil)
    }
}
