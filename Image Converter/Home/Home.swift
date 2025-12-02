//
//  ViewController.swift
//  Image Converter
//
//  Created by Azuby on 10/22/25.
//

import UIKit

class Home: UIViewController {
    private let globalDelegate = GDReceiver<Home>()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        overrideUserInterfaceStyle = .light
        
        globalDelegate.attach(destinition: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.global(qos: .default).async {
            ModelUpscale.shared.loadModel()
        }
    }
}

extension Home: GDReceiverProtocol { }

