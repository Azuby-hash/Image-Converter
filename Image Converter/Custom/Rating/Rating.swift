//
//  Rating.swift
//  Image Remover
//
//  Created by Azuby on 7/12/24.
//

import UIKit
import StoreKit

class Rating: Pageup {
    required init() {
        super.init()
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setOutsideTapDismiss(false)
        setPageDragger(false)
    }
    
    @IBAction func bad(_ sender: Any) {
        badRating()
    }
    
    @IBAction func normal(_ sender: Any) {
        badRating()
    }
    
    @IBAction func good(_ sender: Any) {
        goodRating()
    }
    
    override func close(_ animated: Bool) {
        super.close(animated)
        
        UserDefaults.standard.set(true, forKey: "414eba80-a41c-4052-a9e7-72ea23a3c883")
    }
    
    private func badRating() {
        let alert = UIAlertController(title: "Write Your Feedback", message: "Help us improve by sharing your experience.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .destructive))
        alert.addAction(UIAlertAction(title: "Feedback", style: .default, handler: { _ in
            let email = "azuby.dev@gmail.com"
            if let url = URL(string: "mailto:\(email)?subject=Image Converter Feedback") {
                UIApplication.shared.open(url)
            }
        }))
        
        findViewController()?.present(alert, animated: true)
        
        close(true)
    }
    
    private func goodRating() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
        
        close(true)
    }
}
