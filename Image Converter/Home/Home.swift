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
        
        globalDelegate.attach(destinition: self)
    }
}

extension Home: GDReceiverProtocol { }

