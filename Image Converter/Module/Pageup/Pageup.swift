//
//  Pageup.swift
//  ModuleTest
//
//  Created by Azuby on 1/5/24.
//

import UIKit

fileprivate let DRAGGER_RANGE = CGFloat(-20)...CGFloat(50)

extension UIView {
    /**
     - Important: Pageup binding must inherit from ``Pageup`` and have XIB file as its owner. Bonus design programmatically on return binding of pageup() such as shadow view....
     - 3 Ways init
        - let pageup: YourPageupClass = sourceView.pageup()
        - let pageup = sourceView.pageup() as YourPageupClass
        - sourceView.pageup(YourPageupClass.self)
     - Design require
        - Design layout optional have heightAnchor, widthAnchor set with 950 > priority > 250, 250 > contraints for unactive
     */
    
    @discardableResult
    func pageup<T: Pageup>(_ binding: T.Type, supportOrientation: Bool) -> T {
        let pageup = T(supportOrientation: supportOrientation)
        pageup.attachPageup(to: self)
        
        return pageup
    }
}

protocol PageupDelegate: AnyObject {
    func pageupDismiss(pageup: Pageup)
}

class Pageup: UIView {
    private let backgroundView: UIView = {
        let background = UIView()
        background.translatesAutoresizingMaskIntoConstraints = false
        background.backgroundColor = .init(white: 0, alpha: 0.2)
        
        return background
    } ()
    
    private let content: PageupContent = {
        let content = PageupContent()
        content.translatesAutoresizingMaskIntoConstraints = false
        
        return content
    } ()
    
    private lazy var widthConstraint = content.widthAnchor.constraint(equalToConstant: 450).__with(950)
    private lazy var heightConstraint = content.heightAnchor.constraint(equalTo: heightAnchor).__with(250)
    private lazy var centerXConstraint = content.centerXAnchor.constraint(equalTo: centerXAnchor)
    private lazy var trailingConstraint = content.trailingAnchor.constraint(equalTo: trailingAnchor).__with(900)
    
    private var didLoad = false
    private var outsideTapDismiss = true
    
    private var supportOrientation: Bool
    
    weak var delegate: PageupDelegate?
    
    required init(supportOrientation: Bool) {
        self.supportOrientation = supportOrientation
        super.init(frame: .init(x: 0, y: 0, width: 10, height: 10))
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        self.supportOrientation = false
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        addSubview(content)
        __loadNib(to: content)
        
        content.supportOrientation = supportOrientation
        
        NSLayoutConstraint.activate([
            content.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: 0),
            widthConstraint, heightConstraint,
            centerXConstraint, trailingConstraint,
            content.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        backgroundView.__addConstraintFitBoundsTo(self)
        
        applyGesture()
        
        layoutIfNeeded()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if didLoad { return }
        didLoad = true
        
        layoutIfNeeded()
        
        appear(true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let potraitCondi = isPortrait || (!isPortrait && !supportOrientation)
        
        widthConstraint.priority = potraitCondi ? UILayoutPriority(950) : UILayoutPriority(250)
        heightConstraint.priority = potraitCondi ? UILayoutPriority(250) : UILayoutPriority(950)
        centerXConstraint.priority = potraitCondi ? UILayoutPriority(1000) : UILayoutPriority(900)
        trailingConstraint.priority = potraitCondi ? UILayoutPriority(900) : UILayoutPriority(1000)
    }
    
    private func appear(_ animated: Bool) {
        UIView.animate(withDuration: animated ? 0.5 : 0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut) { [self] in
            content.transform = .identity
            backgroundView.alpha = 1
        }
    }
    
    private func disappear(_ animated: Bool) {
        guard let vc = __findViewController() else { return }
        
        let potraitCondi = isPortrait || (!isPortrait && !supportOrientation)
        
        UIView.animate(withDuration: animated ? 0.5 : 0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut) { [self] in
            content.transform = .init(translationX: potraitCondi ? 0 : (vc.view.bounds.width - safeAreaLayoutGuide.layoutFrame.maxX + content.bounds.width),
                                      y: potraitCondi ? (vc.view.bounds.height - safeAreaLayoutGuide.layoutFrame.maxY + content.bounds.height) : 0)
            backgroundView.alpha = 0
        }
    }
    
    /** Close animation immediately */
    func close(_ animated: Bool) {
        delegate?.pageupDismiss(pageup: self)
        
        if animated{
            disappear(animated)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.removeFromSuperview()
            }
        } else {
            removeFromSuperview()
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if content.point(inside: convert(point, to: content), with: event) {
            return super.hitTest(point, with: event)
        } else {
            if outsideTapDismiss {
                close(true)
            }
            return super.hitTest(point, with: event)
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return true
    }
}

extension Pageup: UIGestureRecognizerDelegate {
    private func applyGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan))
        pan.delegate = self
        content.gestureRecognizers = [pan]
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let potraitCondi = isPortrait || (!isPortrait && !supportOrientation)
        let location = potraitCondi ? gestureRecognizer.location(in: content).y : gestureRecognizer.location(in: content).x
        
        return DRAGGER_RANGE.contains(location)
    }
    
    @objc private func pan(g: UIPanGestureRecognizer) {
        let tran = g.translation(in: self)
        
        let potraitCondi = isPortrait || (!isPortrait && !supportOrientation)
        
        let contentLength = potraitCondi ? content.bounds.height : content.bounds.width
        let velocity = potraitCondi ? g.velocity(in: self).y : g.velocity(in: self).x
        
        var value = potraitCondi ? tran.y : tran.x
        
        if value < 0 {
            value = -contentLength * 0.2 * atan(-value / 100) / (.pi / 2)
        }
        
        if g.state == .ended || g.state == .cancelled {
            if value > (contentLength * 0.6) || (value > (contentLength * 0.2) && velocity > 500) {
                close(true)
                return
            } else {
                value = 0
            }
        }
        
        UIView.animate(withDuration: g.state == .ended || g.state == .cancelled ? 0.5 : 0, delay: 0, usingSpringWithDamping: 1,
                       initialSpringVelocity: 0, options: [.allowUserInteraction, .curveEaseInOut]) { [self] in
            content.transform = .init(translationX: potraitCondi ? 0 : value, y: potraitCondi ? value : 0)
        }
    }
}

extension Pageup {
    /**
     Set false if you dont want close pageup when click outside of pageup
     */
    func setOutsideTapDismiss(_ bool: Bool) {
        outsideTapDismiss = bool
    }
    
    /**
     Set false if you dont want prevent pageup dragger
     */
    func setPageDragger(_ bool: Bool) {
        content.pageDragger = bool
        
        if bool {
            applyGesture()
        } else {
            content.gestureRecognizers = []
        }
    }
}

extension Pageup {
    fileprivate func attachPageup(to source: UIView) {
        guard let vc = source.__findViewController() else { return }
        
        vc.view.addSubview(self)
        __addConstraintFitBoundsTo(vc.view)
        disappear(false)
    }
}

fileprivate extension UIView {
    func __findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.__findViewController()
        } else {
            return nil
        }
    }
    
    func __loadNib(to contentView: UIView) {
        guard let className = NSStringFromClass(type(of: self)).split(separator: ".").last else {
            return
        }
        
        let nib = UINib(nibName: String(className), bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            view.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    func __addConstraintFitBoundsTo(_ view: UIView?) {
        guard let view = view
        else { return }
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

fileprivate extension NSLayoutConstraint {
    func __with(_ priority: Float) -> NSLayoutConstraint {
        self.priority = .init(rawValue: priority)
        
        return self
    }
}

class PageupContent: UIView {
    fileprivate var pageDragger = true
    fileprivate var supportOrientation = false
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let potraitCondi = isPortrait || (!isPortrait && !supportOrientation)
        
        if pageDragger && DRAGGER_RANGE.contains(potraitCondi ? point.y : point.x) {
            return true
        }
        
        var pointViews = [UIView]()
        for view in subviews {
            if view.isUserInteractionEnabled && view.alpha > 0.01 {
                pointViews.append(view)
            }
        }
        
        for pointView in pointViews {
            if pointView.bounds.insetBy(dx: -20, dy: -20).contains(convert(point, to: pointView)) {
                return true
            }
        }
        
        return false
    }
}
