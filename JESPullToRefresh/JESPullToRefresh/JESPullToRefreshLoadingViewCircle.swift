//
//  JESPullToRefreshLoadingViewCircle.swift
//  JESPullToRefresh
//
//  Created by Jerry on 8/16/16.
//  Copyright © 2016 jerryshi. All rights reserved.
//

import UIKit

// MARK: -
// MARK: (CGFloat) Extension

public extension CGFloat {
    
    public func toRadians() -> CGFloat {
        return (self * CGFloat(M_PI)) / 180.0
    }
    
    public func toDegrees() -> CGFloat {
        return self * 180.0 / CGFloat(M_PI)
    }
    
}

// MARK: -
// MARK: JESPullToRefreshLoadingViewCircle

public class JESPullToRefreshLoadingViewCircle: JESPullToRefreshLoadingView {
    
    // MARK: -
    // MARK: Vars
    
    private let kRotationAnimation = "kRotationAnimation"
    
    private let kMinProgress: CGFloat = 0.0823529411764706
    
    private let shapeLayer = CAShapeLayer()
    private lazy var identityTransform: CATransform3D = {
        var transform = CATransform3DIdentity
        transform.m34 = CGFloat(1.0 / -500.0)
        transform = CATransform3DRotate(transform, CGFloat(-90.0).toRadians(), 0.0, 0.0, 1.0)
        return transform
    }()
    
    // MARK: -
    // MARK: Constructors
    
    public override init() {
        super.init(frame: .zero)
        
        shapeLayer.lineWidth = 3.0
        shapeLayer.strokeColor = JESPullToRefreshConstants.LoadingViewBackgroundColor.CGColor
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.actions = ["strokeEnd" : NSNull(), "transform" : NSNull()]
        layer.addSublayer(shapeLayer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    // MARK: Methods
    
    override public func setPullProgress(progress: CGFloat) {
        super.setPullProgress(progress)
//        shapeLayer.lineWidth = (3 * progress + 3 * kMinProgress - 6) / (kMinProgress - 1)
        print("\(progress)")
    }
    
    override public func startAnimating() {
        super.startAnimating()
        
//        if shapeLayer.animationForKey(kRotationAnimation) != nil { return }
        
//        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
//        rotationAnimation.toValue = CGFloat(2 * M_PI) + currentDegree()
//        rotationAnimation.duration = 1.0
//        rotationAnimation.repeatCount = Float.infinity
//        rotationAnimation.removedOnCompletion = false
//        rotationAnimation.fillMode = kCAFillModeForwards
//        shapeLayer.addAnimation(rotationAnimation, forKey: kRotationAnimation)
    }
    
    override public func stopLoading() {
        super.stopLoading()
        
        shapeLayer.removeAnimationForKey(kRotationAnimation)
    }
    
    private func currentDegree() -> CGFloat {
        return shapeLayer.valueForKeyPath("transform.rotation.z") as! CGFloat
    }
    
    override public func tintColorDidChange() {
        super.tintColorDidChange()
        
        shapeLayer.strokeColor = JESPullToRefreshConstants.LoadingViewBackgroundColor.CGColor
    }
    
    // MARK: -
    // MARK: Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        shapeLayer.frame = bounds
        
        shapeLayer.path = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: (frame.size.height - 6) / 2.0, startAngle: 0.0, endAngle: CGFloat(M_PI * 2.0), clockwise: true).CGPath
    }
    
}
