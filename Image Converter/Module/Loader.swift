//
//  Loader.swift
//  BlurPhoto
//
//  Created by Tap Dev5 on 17/03/2022.
//

import UIKit

extension UIViewController {
    
    @discardableResult
    func procLoading(srcV: UIView, _ size: CGFloat = 20, compleLabel: String = "", delay: CGFloat = 0) -> Loader? {
        
        for view in srcV.subviews {
            if let _ = view as? Loader {
                return nil
            }
        }
        
        let loader = Loader()
        
        loader.draw(CGRect(origin: .zero, size: CGSize(width: 10, height: 10)))
        loader.delay = delay
        
        srcV.addSubview(loader)
        
        loader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loader.leadingAnchor.constraint(equalTo: srcV.leadingAnchor),
            loader.trailingAnchor.constraint(equalTo: srcV.trailingAnchor),
            loader.topAnchor.constraint(equalTo: srcV.topAnchor),
            loader.bottomAnchor.constraint(equalTo: srcV.bottomAnchor),
        ])
        
        srcV.layoutIfNeeded()
        
        loader.size = size
        loader.draw()
        
        loader.startLoading()
        
        return loader
    }
    
    func endLoading(on view: UIView, completion: (()->Void)? = nil) {
        var foundLoader = false
        for view in view.subviews {
            if let loader = view as? Loader {
                loader.endLoading(completion)
                foundLoader = true
            }
        }
        if !foundLoader {
            completion?()
        }
    }
}

class Loader: UIView {
    var background = UIView()
    var size: CGFloat = CGFloat.zero
    var uV = UIView()
    var cV = UIView()
    var uC = CAShapeLayer()
    var oC = CAShapeLayer()
    var gradient = CAGradientLayer()
    var p = UIBezierPath()
    
    var delay: CGFloat = 0
    
    private var didLoad = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        reworkAnim()
        
        if didLoad { return }
        didLoad = true
        
        addSubview(background)
        addSubview(uV)
        addSubview(cV)
        uV.layer.addSublayer(uC)
        cV.layer.addSublayer(gradient)
        cV.layer.addSublayer(oC)

        background.translatesAutoresizingMaskIntoConstraints = false
        cV.translatesAutoresizingMaskIntoConstraints = false
        uV.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            background.centerXAnchor.constraint(equalTo: centerXAnchor),
            background.centerYAnchor.constraint(equalTo: centerYAnchor),
            background.widthAnchor.constraint(equalTo: widthAnchor),
            background.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 2),
            
            cV.centerXAnchor.constraint(equalTo: centerXAnchor),
            cV.centerYAnchor.constraint(equalTo: centerYAnchor),
            cV.widthAnchor.constraint(equalToConstant: 0.1),
            cV.heightAnchor.constraint(equalToConstant: 0.1),
            
            uV.centerXAnchor.constraint(equalTo: centerXAnchor),
            uV.centerYAnchor.constraint(equalTo: centerYAnchor),
            uV.widthAnchor.constraint(equalToConstant: 0.1),
            uV.heightAnchor.constraint(equalToConstant: 0.1),
        ])
        
        cV.layer.mask = oC
        
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.colors = [UIColor._primary.cgColor,
                           UIColor._primary.cgColor,]
        
        NotificationCenter.default.addObserver(self, selector: #selector(reworkAnim), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func reworkAnim() {
        oC.removeAnimation(forKey: "1")
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1.2
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        
        oC.add(rotation, forKey: "1")
    }
    
    func draw() {
        reworkAnim()
        
        isUserInteractionEnabled = true
        alpha = 0
        background.backgroundColor = UIColor(white: 0, alpha: 0.2)
        
        gradient.frame = CGRect(x: -size, y: -size, width: size * 2, height: size * 2).insetBy(dx: -10, dy: -15)
        
        p.append(UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: size, startAngle: 0,
                              endAngle: .pi * 2, clockwise: true))
        
        uC.path = p.cgPath.copy(strokingWithWidth: size * 2 / 5, lineCap: .round, lineJoin: .round, miterLimit: 0)
        uC.fillColor = UIColor.init(white: 0, alpha: 0.8).cgColor
        
        p.removeAllPoints()
        
        p.append(UIBezierPath(arcCenter: CGPoint.zero, radius: size,
                              startAngle: .pi / 2, endAngle: .pi, clockwise: true))
        
        oC.path = p.cgPath.copy(strokingWithWidth: size * 2 / 5, lineCap: .round, lineJoin: .round, miterLimit: 0)

        oC.fillColor = UIColor._primary.cgColor
        
        p.removeAllPoints()
    }

    func startLoading() {
        frame = superview?.bounds ?? frame
        
        layoutIfNeeded()
        
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allowUserInteraction) { [self] in
            
            alpha = 1
        }
    }

    func endLoading(_ completion: (()->Void)? = nil) {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut) { [self] in
            alpha = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [self] in
            removeFromSuperview()
            completion?()
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return true
    }
}

extension Loader {
    fileprivate func __findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
