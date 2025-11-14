//
//  Utility.swift
//  Image Converter
//
//  Created by TapUniverse Dev9 on 14/11/25.
//

import UIKit

class Upscale: UIViewController {
    @IBOutlet weak var width: NSLayoutConstraint!
    @IBOutlet weak var height: NSLayoutConstraint!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var sizeBefore: UILabel!
    @IBOutlet weak var sizeAfter: UILabel!
    
    @IBOutlet weak var upscaleB: UIView!
    @IBOutlet weak var saveB: UIView!
    
    private var didLoad = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func upscale(_ sender: Any) {
        
    }
    
    @IBAction func save(_ sender: Any) {
        
    }
}
