//
//  JESPullToRefreshTableView.swift
//  JESPullToRefresh
//
//  Created by Jerry on 9/8/16.
//  Copyright © 2016 jerryshi. All rights reserved.
//

import UIKit
import ObjectiveC

/**
 *  @author Shi Wei, 16-08-29 10:08:32
 *
 *  table view refresh protocol
 */

typealias RefreshHandler = () -> Void

protocol Refreshable {
    
}

protocol Preloadable {
    
}

extension Refreshable where Self: UIScrollView {
    
    func refresh(withActionHandler actionHandler: RefreshHandler) {
        let loadingView = JESPullToRefreshLoadingViewCircle(fillColor: UIColor(red: 224/255.0, green: 231/255.0, blue: 235/255.0, alpha: 1.0))
        loadingView.tintColor = UIColor.whiteColor()
        self.jes_addPullToRefreshWithActionHandler(actionHandler, loadingView: loadingView, logoImage: "refresh_logo")
        self.jes_setPullToRefreshFillColor(UIColor(red: 224/255.0, green: 231/255.0, blue: 235/255.0, alpha: 1.0))
        self.jes_setPullToRefreshBackgroundColor(self.backgroundColor!)
    }
    
}

public extension UIViewController {
    
    private struct Constants {
        static let loadingWidth: CGFloat = 143
        static let loadingHeight: CGFloat = 32
        static var loadingKey = "loadingKey"
    }
    
    private var loadingBgView: UIView? {
        get {
            return objc_getAssociatedObject(self, &Constants.loadingKey) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &Constants.loadingKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func showLoading() {
        if self.loadingBgView == nil {
            let loadingBgView = UIView(frame: self.view.bounds)
            self.loadingBgView = loadingBgView
            loadingBgView.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(loadingBgView)
            
            let loadingView = JESRefreshView(frame: CGRect(x: 0, y: 0, width: Constants.loadingWidth, height: Constants.loadingHeight))
            loadingView.center = CGPoint(x: self.view.bounds.width / 2.0, y: (self.view.bounds.height - Constants.loadingHeight) / 2.0)
            
            loadingBgView.addSubview(loadingView)
            
            loadingView.animate()
        }
    }
    
    public func dismissLoading() {        
        // Remove Animation and background view
        UIView.animateWithDuration(0.375, animations: {
            self.loadingBgView?.alpha = 0.0
        }) { _ in
            self.loadingBgView?.removeFromSuperview()
            self.loadingBgView = nil
        }
    }
}

class JESPullToRefreshTableView: UITableView, Refreshable {

}
