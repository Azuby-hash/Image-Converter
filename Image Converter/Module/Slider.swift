//
//  Slider.swift
//  ModuleTest
//
//  Created by Azuby on 01/10/2023.
//

import UIKit

protocol SliderDelegate: AnyObject {
    func onBegan(_ slider: Slider)
    func onChanged(_ slider: Slider)
    func onEnd(_ slider: Slider)
}

extension SliderDelegate {
    func onBegan(_ slider: Slider) { }
    func onChanged(_ slider: Slider) { }
    func onEnd(_ slider: Slider) { }
}

/**
 A Slider can change layout with your settings.
 
 Override draw or set manual to change layout
 
 ```
 class YourSlider: Slider {
     private var didLoad = false
     
     override func draw(_ rect: CGRect) {
         if didLoad {
             return
         }
         didLoad = true

         setColors([._adaptive, ._adaptive]) // at least 2 colors
         setGradient(of: .thumb)
         setGradient(of: .trackActive)
         
         setColors([._gray10, ._gray10]) // at least 2 colors
         setGradient(of: .trackUnactive)
         
         setRadius(of: .thumb, value: 16)
         setHeight(of: .trackUnactive, value: 15)
         
         layoutIfNeeded()
         
         setMidPoint(at: 0)
         setSnapPoints(at: [], delta: 0)
         
         if #available(iOS 17.0, *) {
             registerForTraitChanges([UITraitUserInterfaceStyle.self], target: self, action: #selector(traitCollectionDidChange))
         }
     }
     
     @objc override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
         super.traitCollectionDidChange(previousTraitCollection)
         
         setColors([._adaptive, ._adaptive])
         setGradient(of: .thumb)
         setGradient(of: .trackActive)

         setColors([._gray10, ._gray10])
         setGradient(of: .trackUnactive)
     }
 }
 ```
 
 - Important: Set all element gradient for their visible. Using setColors and setGradient and height and radius
 */
class Slider: UIView {
    private let DEFAULT_THUMB_SIZE: CGSize = CGSize(width: 20, height: 20)
    private let DEFAULT_TRACK_HEIGHT: CGFloat = 4
    private let DEFAULT_SNAP_TIME: CGFloat = 0.5
    
    weak var delegate: SliderDelegate?
    
    /** Dragger */
    private let thumbMain = SliderThumbExtent()
    private let thumbConfig = UIView()
    
    private weak var thumbLead: NSLayoutConstraint?

    /** Bar */
    private let trackMain = UIView()
    private let trackConfig = UIView()
    
    private let trackMid = UIView()
    private let trackLead = UIView()
    private let trackLeadUI = UIView()
    private let trackRight = UIView()
    private let trackRightUI = UIView()
    
    private weak var midLead: NSLayoutConstraint?
    
    /** Config & Value */
    private(set) var value: CGFloat = 0
    private(set) var mid: CGFloat = 0
    private(set) var snaps: [CGFloat] = [0, 0.5, 1]
    private(set) var delta: CGFloat = 0.02
    
    private(set) var dragConfig: DragConfig = .normal
    private(set) var snapConfig: SnapConfig = .normal
    
    /** Pending Config shadow */
    private var colors: [UIColor] = [UIColor.black, UIColor.black]
    private var locations: [CGFloat] = [0, 1]
    private var range: SliderRange = .init(type: .vertical)
    
    /** Private value */
    private var deltaSnap: CGFloat = 0 // different spacing between drag point and snap point
    private var pendingSnap: Bool = false // pending spacing between done pending and pre pending
    private var pendingTime = Date(timeIntervalSinceNow: -.greatestFiniteMagnitude) // pending snap time
    
    private var preValue: CGFloat = 0 // previous different `value`
    private var entryValue: CGFloat = .zero // start `value` at touch began
    
    private var firstTouch: CGPoint? // start location at touch began
    private var preTouch: CGPoint? // previous location when touch
    private var didTouchThumb: Bool = false // flag that confirm thumb has been touch at touch began
    
    private var velocity: CGFloat = 0 // speed of dragger
    
    init() {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 10, height: 10)))
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
}

/**
 Defaults slider setup
 */
extension Slider {
    
    func getElement(_ element: SliderElement) -> [UIView] {
        switch(element) {
        case .thumb:
            return [thumbMain]
        case .trackActive:
            return [trackLead, trackRight]
        case .trackUnactive:
            return [trackMain]
        }
    }
}

extension Slider {
    /**
     Config how user drag
      - Parameters:
        - config: Way to drag
     */
    func configDrag(_ config: DragConfig) {
        dragConfig = config
    }
    
    /**
     Config how snap active
      - Parameters:
        - config: Snap config
     */
    func configSnap(_ config: SnapConfig) {
        snapConfig = config
        valueCorrectionIfNeeded()
    }
}

/**
 Slider layout: Colors, Gradient, Height and Radius
 */
extension Slider {
    /**
     - Important: This is just pending, call setGradient to apply
     */
    func setColors(_ colors: [UIColor]) {
        self.colors = colors
    }
    
    /**
     - Important: This is just pending, call setGradient to apply
     */
    func setRange(_ range: SliderRange) {
        self.range = range
    }
    
    /**
     - Important: This is just pending, call setGradient to apply
     */
    func setLocation(_ locations: [CGFloat]) {
        self.locations = locations
    }
    
    /**
     Apply gradient to a view
     */
    func setGradient(of view: UIView) {
        var gradient = CAGradientLayer()
        var isNew = true
        
        if let sublayers = view.layer.sublayers {
            for layer in sublayers {
                if let layer = layer as? CAGradientLayer {
                    gradient = layer
                    isNew = false
                }
            }
        }
        
        if isNew {
            view.layer.insertSublayer(gradient, at: 0)
        }

        layoutIfNeeded()
        
        gradient.frame = view.bounds
        gradient.colors = colors.map({ color in
            color.cgColor
        })
        gradient.locations = locations.map({ value in
            NSNumber(value: Float(value))
        })
        gradient.startPoint = range.start
        gradient.endPoint = range.end
    }
    
    /**
     Apply gradient to an element
     */
    func setGradient(of element: SliderElement) {
        switch(element) {
        case .thumb:
            setGradient(of: thumbMain)
        case .trackUnactive:
            setGradient(of: trackMain)
        case .trackActive:
            setGradient(of: trackLeadUI)
            setGradient(of: trackRightUI)
        }
    }
    
    /**
     Set height or radius of an element
     */
    func setHeight(of element: SliderElement, value: CGFloat, radius: CGFloat? = nil) {
        switch(element) {
        case .thumb:
            thumbConfig.frame.size = CGSize(width: value, height: value)
            thumbMain.layer.cornerRadius = radius ?? value / 2
            
            layoutIfNeeded()
            
            if let gradient = thumbMain.layer.sublayers?.first(where: { layer in
                return layer is CAGradientLayer
            }) {
                gradient.frame = thumbMain.bounds
            }
        case .trackUnactive:
            trackConfig.frame.size = CGSize(width: .pi, height: value)
            trackMain.layer.cornerRadius = radius ?? value / 2
            trackLead.layer.cornerRadius = radius ?? value / 2
            trackRight.layer.cornerRadius = radius ?? value / 2
            
            layoutIfNeeded()
            
            [trackMain, trackLeadUI, trackRightUI].forEach { view in
                if let gradient = view.layer.sublayers?.first(where: { layer in
                    return layer is CAGradientLayer
                }) {
                    gradient.frame = view.bounds
                }
            }
        default:
            break
        }
    }
    
    /**
     Set height or radius of an element
     */
    func setRadius(of element: SliderElement, value: CGFloat, radius: CGFloat? = nil) {
        setHeight(of: element, value: value, radius: radius)
    }
}

/**
 Slider setup: Mid point, Default point, Snap
 */
extension Slider {
    /**
     Set start point of active track
     - Parameters:
        - point: Start point of active track
     */
    func setMidPoint(at point: CGFloat) {
        mid = max(0, min(1, point))
        valueCorrectionIfNeeded()
    }
    
    /**
     Set current value of thumb
     - Parameters:
        - point: Current value of thumb
     */
    func setCurrentPoint(at point: CGFloat) {
        value = max(0, min(1, point))
        valueCorrectionIfNeeded()
    }
    
    /**
     Set points of which value snap when close
     - Parameters:
        - points: Array of point which value snap when close
     */
    func setSnapPoints(at points: [CGFloat], delta: CGFloat) {
        self.delta = delta

        snaps = points.map({ point in
            return max(0, min(1, point))
        })
        valueCorrectionIfNeeded()
    }
    
    /**
     Set number points which value snap when close, evenly
     - Parameters:
        - count: Number of snap point, evenly
     */
    func setSnapPoints(count: Int, delta: CGFloat) {
        self.delta = delta
        
        if count <= 0 {
            snaps = []
            return
        }
        if count == 1 {
            snaps = [0.5]
            return
        }
        if count > 1 {
            snaps = (0..<count).map({ index in
                return CGFloat(index) / CGFloat(count - 1)
            })
        }
        valueCorrectionIfNeeded()
    }
    
    private func valueCorrectionIfNeeded() {
        func correct(_ value: UnsafeMutablePointer<CGFloat>) {
            guard let closestSnap = snaps.sorted(by: { a, b in
                abs(a - value.pointee) < abs(b - value.pointee)
            }).first else { return }

            if snapConfig == .normal {
                // do nothing if dev set this
            }
            if snapConfig == .step {
                value.pointee = closestSnap
            }
            if snapConfig == .none {
                // do nothing
            }
        }
        
        correct(&value)
        correct(&mid)
        
        updateLayouts()
        layoutIfNeeded()
    }
}

/**
 Slider definition: SliderElement, SliderRange, SliderConfig
 */
extension Slider {
    enum SliderElement {
        /** Bar unactive */
        case trackUnactive
        
        /** Bar active */
        case trackActive
        
        /** Dragger */
        case thumb
    }
    
    enum SliderRangeType {
        /** Colors layout from left to right */
        case horizontal
        
        /** Colors layout from top to bottom */
        case vertical
        
        /** Colors layout from top left to bottom right */
        case diagonalUp
        
        /** Colors layout from bottom left to top right */
        case diagonalDown
    }
    
    struct SliderRange {
        let start: CGPoint
        let end: CGPoint
        
        /**
         Custom start point, end point
          - Parameters:
            - start: Point to start gradient 0->1
            - end: Point to end gradient 0->1
         */
        init(start: CGPoint, end: CGPoint) {
            self.start = start
            self.end = end
        }
        
        /**
         Default start point, end point
          - Parameters:
            - type: Range default config
         */
        init(type: SliderRangeType) {
            switch(type) {
            case .horizontal:
                start = CGPoint(x: 0, y: 0)
                end = CGPoint(x: 1, y: 0)
            case .vertical:
                start = CGPoint(x: 0, y: 0)
                end = CGPoint(x: 0, y: 1)
            case .diagonalDown:
                start = CGPoint(x: 0, y: 0)
                end = CGPoint(x: 1, y: 1)
            case .diagonalUp:
                start = CGPoint(x: 0, y: 1)
                end = CGPoint(x: 1, y: 0)
            }
        }
    }
    
    enum DragConfig {
        /** Config that slider can drag from anywhere, apply translate on thumb */
        case freeSmooth
        
        /** Config that slider can drag from anywhere, apply current location on thumb */
        case freeFollow
        
        /** Config that slider can drag from thumb only, apply translate on thumb */
        case normal
    }
    
    enum SnapConfig {
        /** Config that slider value only snap when close */
        case normal
        
        /** Config that slider value always snap */
        case step
        
        /** Config that slider not snap, ignore setSnapPoints in this config  */
        case none
    }

}

/** Init */
extension Slider {
    private func commonInit() {
        addSubview(trackMain)
        addSubview(trackLead)
        addSubview(trackRight)
        addSubview(trackMid)
        addSubview(thumbMain)
        
        trackMain.addSubview(trackConfig)
        thumbMain.addSubview(thumbConfig)
        
        trackMain.translatesAutoresizingMaskIntoConstraints = false
        thumbMain.translatesAutoresizingMaskIntoConstraints = false
        
        trackConfig.fitContraints(to: trackMain, config: .vel)
        thumbConfig.fitContraints(to: thumbMain)
        
        trackConfig.frame.size = CGSize(width: .pi, height: DEFAULT_TRACK_HEIGHT)
        thumbConfig.frame.size = DEFAULT_THUMB_SIZE
        
        trackMain.layer.cornerRadius = DEFAULT_TRACK_HEIGHT / 2
        trackMain.layer.cornerCurve = .continuous
        trackMain.clipsToBounds = true
        
        thumbMain.layer.cornerRadius = DEFAULT_THUMB_SIZE.width / 2
        thumbMain.layer.cornerCurve = .continuous
        thumbMain.clipsToBounds = true
        
        let thumbLead = thumbMain.centerXAnchor.constraint(equalTo: leadingAnchor)
        self.thumbLead = thumbLead
        
        NSLayoutConstraint.activate([
            trackMain.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackMain.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackMain.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            thumbLead,
            thumbMain.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        // Active
        
        trackLead.addSubview(trackLeadUI)
        trackRight.addSubview(trackRightUI)
        
        for view in [trackMid, trackLead, trackRight, trackLeadUI, trackRightUI] {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        trackMid.fitContraints(to: trackMain, config: .vel)
        trackLead.fitContraints(to: trackMain, config: .vel)
        trackRight.fitContraints(to: trackMain, config: .vel)
        
        trackLeadUI.fitContraints(to: trackMain)
        trackRightUI.fitContraints(to: trackMain)
        
        trackLead.clipsToBounds = true
        trackLead.layer.cornerCurve = .continuous
        trackRight.clipsToBounds = true
        trackRight.layer.cornerCurve = .continuous

        let midLead = trackMid.widthAnchor.constraint(equalToConstant: bounds.width * mid)
        self.midLead = midLead
        
        NSLayoutConstraint.activate([
            midLead, trackMid.leadingAnchor.constraint(equalTo: trackMain.leadingAnchor),
            
            trackLead.trailingAnchor.constraint(equalTo: trackMid.trailingAnchor),
            trackLead.leadingAnchor.constraint(lessThanOrEqualTo: trackMid.trailingAnchor, constant: 0),
            trackLead.leadingAnchor.constraint(equalTo: thumbMain.centerXAnchor).with(priority: 900),
            
            trackRight.leadingAnchor.constraint(equalTo: trackMid.trailingAnchor),
            trackRight.trailingAnchor.constraint(greaterThanOrEqualTo: trackMid.trailingAnchor, constant: 0),
            trackRight.trailingAnchor.constraint(equalTo: thumbMain.centerXAnchor).with(priority: 900),
        ])
        
        meansureVelocity()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateLayouts()
    }
    
    private func updateLayouts(_ impact: Bool = false) {
        for view in [thumbMain, trackMain] {
            if let gradient = view.layer.sublayers?.first(where: { view in
                view is CAGradientLayer
            }) {
                gradient.frame = view.bounds
            }
        }
        
        thumbLead?.constant = bounds.width * value
        midLead?.constant = bounds.width * mid
        
        if impact && abs(preValue - value) > .leastNonzeroMagnitude {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            pendingTime = Date()
        }
        
        preValue = value
    }
}

/** Pan */
extension Slider {
    private func meansureVelocity() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan))
        pan.cancelsTouchesInView = false
        gestureRecognizers = [pan]
    }
    
    @objc private func pan(g: UIPanGestureRecognizer) {
        velocity = g.velocity(in: self).x
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: thumbMain) else { return }

        deltaSnap = .zero
        entryValue = value
        firstTouch = touches.first?.location(in: self)
        preTouch = firstTouch
        didTouchThumb = thumbMain.point(inside: point, with: event)
        
        delegate?.onBegan(self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = firstTouch,
              let preTouch = preTouch,
              let point = touches.first?.location(in: self).applying(.init(translationX: deltaSnap, y: .zero))
        else { return }
        
        self.preTouch = point
        let translate = point.applying(.init(translationX: -firstTouch.x, y: -firstTouch.y))
        
        if dragConfig == .normal {
            normalGesture(translate: translate, point: point, direction: point.x - preTouch.x)
        }
        if dragConfig == .freeSmooth {
            freeSmoothGesture(translate: translate, point: point, direction: point.x - preTouch.x)
        }
        if dragConfig == .freeFollow {
            freeFollowGesture(translate: translate, point: point, direction: point.x - preTouch.x)
        }
        
        delegate?.onChanged(self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        ended()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        ended()
    }
    
    private func ended() {
        firstTouch = nil
        didTouchThumb = false
        
        delegate?.onEnd(self)
    }
    
    private func normalGesture(translate: CGPoint, point: CGPoint, direction: CGFloat) {
        guard didTouchThumb, bounds.width > .leastNonzeroMagnitude else { return }
        
        let currPoint = entryValue + translate.x / bounds.width

        setCurrentSnapPoint(at: currPoint, direction: direction)
    }
    
    private func freeSmoothGesture(translate: CGPoint, point: CGPoint, direction: CGFloat) {
        let currPoint = entryValue + translate.x / bounds.width
        
        setCurrentSnapPoint(at: currPoint, direction: direction)
    }
    
    private func freeFollowGesture(translate: CGPoint, point: CGPoint, direction: CGFloat) {
        var currPoint = point.x / bounds.width
        
        if didTouchThumb {
            currPoint = entryValue + translate.x / bounds.width
        }
        
        setCurrentSnapPoint(at: currPoint, direction: direction)
    }
    
    private func setCurrentSnapPoint(at point: CGFloat, direction: CGFloat) {
        let closestSnap = snaps.sorted(by: { a, b in
            abs(a - point) < abs(b - point)
        }).first ?? .greatestFiniteMagnitude
        
        func snap() {
            updateLayouts(true)
            UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut) { [self] in
                layoutIfNeeded()
            }
        }

        if snapConfig == .normal {
            if -pendingTime.timeIntervalSinceNow < DEFAULT_SNAP_TIME {
                pendingSnap = true
                return
            }
            
            if pendingSnap {
                deltaSnap += (value - point) * bounds.width
                pendingSnap = false
                return
            }
            
            if abs(point - closestSnap) < delta {
                if (closestSnap - point) * direction > 0 && abs(velocity) < 500 * delta {
                    if abs(direction) > delta * bounds.width {
                        return
                    }
                    deltaSnap += (closestSnap - value) * bounds.width
                    value = closestSnap
                    snap()
                    return
                }
                if abs(direction) < .leastNonzeroMagnitude {
                    return
                }
            }
        }
        if snapConfig == .step {
            value = closestSnap
            snap()
            return
        }
        if snapConfig == .none {
            // do nothing
        }
        
        value = max(0, min(1, point))
        updateLayouts()
    }
}

extension Slider {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for view in subviews {
            if view.point(inside: convert(point, to: view), with: event) {
                return true
            }
        }
        return super.point(inside: point, with: event)
    }
}

fileprivate extension UIView {
    enum Config {
        case all
        case hoz
        case vel
    }
    func fitContraints(to view: UIView, config: Config = .all) {
        if config == .all || config == .hoz {
            NSLayoutConstraint.activate([
                leadingAnchor.constraint(equalTo: view.leadingAnchor),
                trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
        }
        if config == .all || config == .vel {
            NSLayoutConstraint.activate([
                topAnchor.constraint(equalTo: view.topAnchor),
                bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        }
    }
}

fileprivate class SliderThumbExtent: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if alpha > 0 && isUserInteractionEnabled,
           getTouchBounds().contains(point) {
            return true
        }
        
        return super.point(inside: point, with: event)
    }
    
    func getTouchBounds() -> CGRect {
        return bounds.insetBy(dx: -bounds.midX, dy: -bounds.midY)
    }
}

fileprivate extension NSLayoutConstraint {
    func with(priority: CGFloat) -> NSLayoutConstraint {
        self.priority = UILayoutPriority(Float(priority))
        
        return self
    }
}
