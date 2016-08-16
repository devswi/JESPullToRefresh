//
//  JESPullToRefreshExtensions.swift
//  JESPullToRefresh
//
//  Created by Jerry on 8/16/16.
//  Copyright © 2016 jerryshi. All rights reserved.
//

import UIKit
import ObjectiveC

// MARK: -
// MARK: (NSObject) Extension

public extension NSObject {
    
    public struct jes_associatedKeys {
        static var observersArray = "observers"
    }
    
    private var jes_observers: [[String: NSObject]] {
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
    
    public func jes_addObserver(observer: NSObject, forKeyPath keyPath: String) {
        let observerInfo = [keyPath: observer]
        
        if jes_observers.indexOf({ $0 == observerInfo }) == nil {
            jes_observers.append(observerInfo)
            addObserver(observer, forKeyPath: keyPath, options: .New, context: nil)
        }
    }
    
    public func jes_removeObserver(observer: NSObject, forKeyPath keyPath: String) {
        let observerInfo = [keyPath : observer]
        
        if let index = jes_observers.indexOf({ $0 == observerInfo}) {
            jes_observers.removeAtIndex(index)
            removeObserver(observer, forKeyPath: keyPath)
        }
    }
}

// MARK: -
// MARK: (UIScrollView) Extension

public extension UIScrollView {
    
    // MARK: - Vars
    
    private struct jes_associatedKeys {
        static var pullToRefreshView = "pullToRefreshView"
    }
    
    private var pullToRefreshView: JESPullToRefreshView? {
        get {
            return objc_getAssociatedObject(self, &jes_associatedKeys.pullToRefreshView) as? JESPullToRefreshView
        }
        set {
            objc_setAssociatedObject(self, &jes_associatedKeys.pullToRefreshView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Methods (Public)
    
    public func jes_addPullToRefreshWithActionHandler(actionHandler: () -> Void, loadingView: JESPullToRefreshLoadingView?) {
        multipleTouchEnabled = false
        panGestureRecognizer.maximumNumberOfTouches = 1
        
        let pullToRefreshView = JESPullToRefreshView()
        self.pullToRefreshView = pullToRefreshView
        pullToRefreshView.actionHandler = actionHandler
        pullToRefreshView.loadingView = loadingView
        addSubview(pullToRefreshView)
        
        pullToRefreshView.observing = true
    }
    
    public func jes_removePullToRefresh() {
        pullToRefreshView?.disassociateDisplayLink()
        pullToRefreshView?.observing = false
        pullToRefreshView?.removeFromSuperview()
    }
    
    public func jes_setPullToRefreshBackgroundColor(color: UIColor) {
        pullToRefreshView?.backgroundColor = color
    }
    
    public func jes_setPullToRefreshFillColor(color: UIColor) {
        pullToRefreshView?.fillColor = color
    }
    
    public func jes_stopLoading() {
        pullToRefreshView?.stopLoading()
    }
}

// MARK: -
// MARK: (UIView) Extension

public extension UIView {
    func jes_center(usePresentationLayerIfPossible: Bool) -> CGPoint {
        if usePresentationLayerIfPossible, let presentationLayer = layer.presentationLayer() as? CALayer {
            return presentationLayer.position
        }
        return center
    }
}

// MARK: -
// MARK: (UIPanGestureRecognizer) Extension

public extension UIPanGestureRecognizer {
    func jes_resign() {
        enabled = false
        enabled = true
    }
}

// MARK: -
// MARK: (UIGestureRecognizerState) Extension

public extension UIGestureRecognizerState {
    func jes_isAnyOf(values: [UIGestureRecognizerState]) -> Bool {
        return values.contains({ $0 == self })
    }
}