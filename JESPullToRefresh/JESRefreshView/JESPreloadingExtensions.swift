//
//  JESPreloadingExtensions.swift
//  JESPullToRefresh
//
//  Created by Jerry on 09/10/2016.
//  Copyright © 2016 jerryshi. All rights reserved.
//

import UIKit

public struct Preloading<Base: Any> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public extension NSObjectProtocol {
    public var preloading: Preloading<Self> {
        return Preloading(self)
    }
}

public extension Preloading where Base: UIViewController {
    public func show(withBackgroundColor color: UIColor = UIColor.white) {
        base.showPreLoading(color)
    }
    
    public func dismiss() {
        base.dismissPreLoading()
    }
}

public extension UIViewController {
    
    fileprivate struct Constants {
        static let loadingWidth: CGFloat = 143
        static let loadingHeight: CGFloat = 32
        static var loadingKey = "loadingKey"
    }
    
    fileprivate var loadingBgView: UIView? {
        get {
            return objc_getAssociatedObject(self, &Constants.loadingKey) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &Constants.loadingKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate func showPreLoading(_ backgroundColor: UIColor) {
        if self.loadingBgView == nil {
            let loadingBgView = UIView(frame: self.view.bounds)
            self.loadingBgView = loadingBgView
            loadingBgView.backgroundColor = backgroundColor
            self.view.addSubview(loadingBgView)
            
            let loadingView = JESRefreshView(frame: CGRect(x: 0, y: 0, width: Constants.loadingWidth, height: Constants.loadingHeight))
            loadingView.center = CGPoint(x: self.view.bounds.width / 2.0, y: (self.view.bounds.height - Constants.loadingHeight) / 2.0)
            
            loadingBgView.addSubview(loadingView)
            
            loadingView.animate()
        }
    }
    
    fileprivate func dismissPreLoading() {
        // Remove Animation and background view
        UIView.animate(withDuration: 0.375, animations: {
            self.loadingBgView?.alpha = 0.0
            }, completion: { _ in
                self.loadingBgView?.removeFromSuperview()
                self.loadingBgView = nil
        })
    }
}
