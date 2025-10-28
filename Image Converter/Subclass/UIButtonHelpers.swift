//
//  UIButtonHelpers.swift
//  Image Converter
//
//  Created by TapUniverse Dev9 on 27/10/25.
//

import UIKit

class UIButtonPro: UIButton {
    @IBInspectable var inset: CGPoint = .init(x: -10, y: -10)
    @IBInspectable var backgroundAlpha: Int = 80 {
        didSet {
            commonInit()
        }
    }
    
    private var titleContainer = AttributeContainer()
    private var subtitleContainer = AttributeContainer()
    private var backgroundColorConfig = UIColor.clear
    
    private var didLoad = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        var configuration = configuration
        
        configuration?.titleTextAttributesTransformer = .init({ [self] container in
            if !didLoad {
                self.titleContainer = container
            }
            
            return container
        })
        
        configuration?.subtitleTextAttributesTransformer = .init({ [self] container in
            if !didLoad {
                self.subtitleContainer = container
            }
            
            return container
        })
        
        if !didLoad,
           var backgroundColor = configuration?.baseBackgroundColor {
            if #available(iOS 26, *) {
                var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
                if backgroundColor.getRed(&r, green: &g, blue: &b, alpha: &a) {
                    backgroundColor = UIColor(red: r, green: g, blue: b, alpha: a * CGFloat(backgroundAlpha) / 100)
                }
            }
            
            self.backgroundColorConfig = backgroundColor
        }

        self.configuration = configuration
        
        didLoad = true
        
        configurationUpdateHandler = { [self] button in
            var updatedConfig: UIButton.Configuration?
            
            if #available(iOS 26, *) {
                updatedConfig = UIButton.Configuration.prominentGlass()
            } else {
                updatedConfig = button.configuration
            }
            
            guard var updatedConfig = updatedConfig else { return }

            updatedConfig.title = button.configuration?.title
            updatedConfig.subtitle = button.configuration?.subtitle
            updatedConfig.image = button.configuration?.image
            updatedConfig.imagePlacement = button.configuration?.imagePlacement ?? updatedConfig.imagePlacement
            updatedConfig.imagePadding = button.configuration?.imagePadding ?? updatedConfig.imagePadding
            updatedConfig.baseForegroundColor = button.configuration?.baseForegroundColor
            updatedConfig.contentInsets = button.configuration?.contentInsets ?? updatedConfig.contentInsets
            updatedConfig.cornerStyle = button.configuration?.cornerStyle ?? updatedConfig.cornerStyle
            updatedConfig.titleLineBreakMode = .byTruncatingTail
            updatedConfig.background = button.configuration?.background ?? updatedConfig.background
            updatedConfig.background.backgroundColor = backgroundColorConfig
            updatedConfig.baseBackgroundColor = .clear
            
            if let title = button.configuration?.title {
                updatedConfig.attributedTitle = AttributedString(title, attributes: titleContainer)
            }
            
            if let subtitle = button.configuration?.subtitle {
                updatedConfig.attributedSubtitle = AttributedString(subtitle, attributes: subtitleContainer)
            }
            
            self.configuration = updatedConfig
        }
        
        tintAdjustmentMode = .normal
    }
    
    func setContentColor(_ color: UIColor) {
        configuration?.baseForegroundColor = color
    }
    
    func setBackgroundColor(_ color: UIColor) {
        configuration?.baseBackgroundColor = color
        configuration?.background.backgroundColor = color
        configuration?.background.backgroundColorTransformer = .init({ _ in
            return color
        })
        backgroundColor = color
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds.insetBy(dx: inset.x, dy: inset.y)
        var isTouch = false
        for subview in subviews {
            if subview.point(inside: convert(point, to: subview), with: event) {
                isTouch = true
                break
            }
        }
        
        return rect.contains(point) || isTouch
    }
}
