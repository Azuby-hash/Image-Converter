//
//  HomeEditorMime.swift
//  Image Converter
//
//  Created by Azuby on 11/3/25.
//

import UIKit

fileprivate let ITEM_LENGTH: CGFloat = 70

class HomeEditorMime: UIViewPointSubview {
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var selector: UIButtonPro!
    @IBOutlet var stacks: [UIStackView]!
    
    private var didLoad = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        setup()
        noti()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scroll.contentInset = .init(top: 0, left: scroll.bounds.midX - ITEM_LENGTH / 2,
                                    bottom: 0, right: scroll.bounds.midX - ITEM_LENGTH / 2)
    }
}

extension HomeEditorMime: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut, .allowUserInteraction]) { [self] in
            selector.transform = .init(scaleX: 1.2, y: 1.2)
            selector.setBackgroundColor(._primary)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // The content inset value, which also serves as the offset needed to center an item.
        let centerAdjustment = scrollView.contentInset.left
        
        // Get the proposed content offset
        let proposedOffset = targetContentOffset.pointee.x
        
        // Calculate the 'effective' proposed offset relative to the items' start.
        let effectiveProposedOffset = proposedOffset + centerAdjustment
        
        // Determine the base index of the closest item
        var proposedIndex = round(effectiveProposedOffset / ITEM_LENGTH)
        
        // Adjust index for high velocity (flick gesture)
        if abs(velocity.x) > 0.1 {
            if velocity.x > 0 {
                proposedIndex = ceil(effectiveProposedOffset / ITEM_LENGTH)
            } else {
                proposedIndex = floor(effectiveProposedOffset / ITEM_LENGTH)
            }
        }
        
        if ConvertMime.allCases.indices.contains(Int(proposedIndex)) {
            cHome.setMime(ConvertMime.allCases[Int(proposedIndex)])
        }
        
        // Calculate the final, corrected content offset that centers the item.
        let newOffset = (proposedIndex * ITEM_LENGTH) - centerAdjustment
        
        // 9. Set the new target content offset
        targetContentOffset.pointee.x = newOffset
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [.curveEaseInOut, .allowUserInteraction]) { [self] in
            selector.transform = .identity
            selector.setBackgroundColor(._primary.withAlphaComponent(0.8))
        }
    }
}

extension HomeEditorMime {
    private func setup() {
        stacks.enumerated().forEach { (index, stack) in
            ConvertMime.allCases.forEach { mime in
                let view = UIView()
                view.translatesAutoresizingMaskIntoConstraints = false
                
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = mime.rawValue.uppercased()
                label.font = .systemFont(ofSize: 16, weight: .bold)
                label.textColor = index == 0 ? ._gray60 : ._white
                
                view.addSubview(label)
                
                NSLayoutConstraint.activate([
                    view.widthAnchor.constraint(equalToConstant: ITEM_LENGTH),
                    label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                ])
                
                stack.addArrangedSubview(view)
            }
        }
        
        scroll.delegate = self
        scroll.decelerationRate = .fast
        
        selector.setBackgroundColor(._primary.withAlphaComponent(0.8))
    }
}

extension HomeEditorMime {
    private func noti() {
        NotificationCenter.default.addObserver(self, selector: #selector(reset), name: CHome.convertResetSettings, object: nil)
    }
    
    @objc private func reset() {
        scroll.contentOffset.x = -scroll.contentInset.left
    }
}
