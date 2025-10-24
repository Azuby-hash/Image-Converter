//
//  UIViewControllerStoryboard.swift
//  AIVideoGenerator
//
//  Created by TapUniverse Dev9 on 01/04/2024.
//

import UIKit

extension UIViewController {
    static func create(id: String = "main") -> UIViewController {
        return UIStoryboard(name: String(describing: self), bundle: nil).instantiateViewController(withIdentifier: id)
    }
}
