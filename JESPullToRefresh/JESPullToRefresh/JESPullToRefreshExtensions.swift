//
//  JESPullToRefreshExtensions.swift
//  JESPullToRefresh
//
//  Created by Jerry on 8/16/16.
//  Copyright © 2016 jerryshi. All rights reserved.
//

import UIKit
import ObjectiveC

public struct Refresh<Base: Any> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public extension NSObjectProtocol {
    public var refresh: Refresh<Self> {
        return Refresh(self)
    }
}

// MARK: -
// MARK: (NSObject) Extension

public extension NSObject {
    
    public struct jes_associatedKeys {
        static var observersArray = "observers"
    }
    
    fileprivate var jes_observers: [[String: NSObject]] {
        get {
            if let observers = objc_getAssociatedObject(self, &jes_associatedKeys.observersArray) as? [[String : NSObject]] {
                return observers
            } else {
                let observers = [[String: NSObject]]()
                self.jes_observers = observers
                return observers
            }
        }
        set {
            objc_setAssociatedObject(self, &jes_associatedKeys.observersArray, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // Method
    
    public func jes_addObserver(_ observer: NSObject, forKeyPath keyPath: String) {
        let observerInfo = [keyPath: observer]
        
        if jes_observers.index(where: { $0 == observerInfo }) == nil {
            jes_observers.append(observerInfo)
            addObserver(observer, forKeyPath: keyPath, options: .new, context: nil)
        }
    }
    
    public func jes_removeObserver(_ observer: NSObject, forKeyPath keyPath: String) {
        let observerInfo = [keyPath: observer]
        
        if let index = jes_observers.index(where: { $0 == observerInfo}) {
            jes_observers.remove(at: index)
            removeObserver(observer, forKeyPath: keyPath)
        }
    }
}

// MARK: -
// MARK: (UIScrollView) Extension

public extension Refresh where Base: UIScrollView {
    
    // MARK: - Methods (public)
    
    public func handler(_ handler: @escaping () -> Void) {
        let loadingView = JESPullToRefreshLoadingViewCircle(fillColor: UIColor(red: 224/255.0, green: 231/255.0, blue: 235/255.0, alpha: 1.0))
        loadingView.tintColor = UIColor.white
        base.jes_addPullToRefreshWithActionHandler(handler, loadingView: loadingView, logoImage: "refresh_logo")
        base.jes_setPullToRefreshFillColor(UIColor(red: 224/255.0, green: 231/255.0, blue: 235/255.0, alpha: 1.0))
        base.jes_setPullToRefreshBackgroundColor(base.backgroundColor!)
    }
    
    public func remove() {
        base.jes_removePullToRefresh()
    }
    
    public func stop() {
        base.jes_stopLoading()
    }
    
}

public extension UIScrollView {
    
    // MARK: - Vars
    
    fileprivate struct jes_associatedKeys {
        static var pullToRefreshView = "pullToRefreshView"
        static var slidForMoreView = "slidForMoreView"
    }
    
    fileprivate var pullToRefreshView: JESPullToRefreshView? {
        get {
            return objc_getAssociatedObject(self, &jes_associatedKeys.pullToRefreshView) as? JESPullToRefreshView
        }
        set {
            objc_setAssociatedObject(self, &jes_associatedKeys.pullToRefreshView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Methods (private)
    
    public func jes_addPullToRefreshWithActionHandler(_ actionHandler: @escaping () -> Void, loadingView: JESPullToRefreshLoadingView?, logoImage: String? = nil) {
        isMultipleTouchEnabled = false
        panGestureRecognizer.maximumNumberOfTouches = 1
        
        let pullToRefreshView = JESPullToRefreshView()
        self.pullToRefreshView = pullToRefreshView
        pullToRefreshView.actionHandler = actionHandler
        pullToRefreshView.loadingView = loadingView
        if let logoImage = logoImage {
            pullToRefreshView.logoImage = logoImage
        }
        addSubview(pullToRefreshView)
        
        pullToRefreshView.observing = true
    }
    
    fileprivate func jes_removePullToRefresh() {
        pullToRefreshView?.disassociateDisplayLink()
        pullToRefreshView?.observing = false
        pullToRefreshView?.removeFromSuperview()
    }
    
    fileprivate func jes_stopLoading() {
        pullToRefreshView?.stopLoading()
    }
    
    // MARK: - Method (public)
    public func jes_setPullToRefreshBackgroundColor(_ color: UIColor) {
        pullToRefreshView?.backgroundColor = color
    }
    
    public func jes_setPullToRefreshFillColor(_ color: UIColor) {
        pullToRefreshView?.fillColor = color
    }
}

// MARK: -
// MARK: (UIView) Extension

public extension UIView {
    func jes_center(_ usePresentationLayerIfPossible: Bool = false) -> CGPoint {
        if usePresentationLayerIfPossible, let presentationLayer = layer.presentation() { return presentationLayer.position }
        return center
    }
}

// MARK: -
// MARK: (UIPanGestureRecognizer) Extension

public extension UIPanGestureRecognizer {
    func jes_resign() {
        isEnabled = false
        isEnabled = true
    }
}

// MARK: -
// MARK: (UIGestureRecognizerState) Extension

public extension UIGestureRecognizerState {
    func jes_isAnyOf(_ values: [UIGestureRecognizerState]) -> Bool {
        return values.contains(where: { $0 == self })
    }
}
