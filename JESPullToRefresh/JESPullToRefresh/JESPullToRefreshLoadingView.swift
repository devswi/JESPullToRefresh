//
//  JESPullToRefreshLoadingView.swift
//  JESPullToRefresh
//
//  Created by Jerry on 8/16/16.
//  Copyright © 2016 jerryshi. All rights reserved.
//

import UIKit

public class JESPullToRefreshLogoImageView: UIImageView {
    
    // MARK: -
    // MARK: Vars
    
    lazy var maskLayer: CAShapeLayer = {
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.clearColor().CGColor
        maskLayer.fillColor = UIColor.blackColor().CGColor
        maskLayer.actions = ["path": NSNull(), "position": NSNull(), "bounds": NSNull()]
        self.layer.mask = maskLayer
        return maskLayer
    }()
    
    // MARK: -
    // MARK: Constructors
    
    public init() {
        super.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class JESPullToRefreshLoadingView: UIView {
    
    // MARK: -
    // MARK: Vars
    
    lazy var maskLayer: CAShapeLayer = {
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.clearColor().CGColor
        maskLayer.fillColor = UIColor.blackColor().CGColor
        maskLayer.actions = ["path" : NSNull(), "position" : NSNull(), "bounds" : NSNull()]
        self.layer.mask = maskLayer
        return maskLayer
    }()
    
    // MARK: -
    // MARK: Constructors
    
    public init() {
        super.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    // MARK: Methods
    
    public func setPullProgress(progress: CGFloat) {
        
    }
    
    public func startAnimating() {
        
    }
    
    public func stopLoading() {
        
    }
}
