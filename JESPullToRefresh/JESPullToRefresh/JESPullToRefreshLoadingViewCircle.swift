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

private class JESPullToRefreshLoadingInsideViewCircle: UIView {
    
    private let shapeLayer = CAShapeLayer()
    
    private init(fillColor: UIColor) {
        super.init(frame: .zero)
        
        self.backgroundColor = UIColor.clearColor()
        
        shapeLayer.lineWidth = 0.01
        shapeLayer.strokeColor = UIColor.clearColor().CGColor
        shapeLayer.fillColor = fillColor.CGColor
        shapeLayer.actions = ["strokeEnd": NSNull(), "transform": NSNull()]
        layer.addSublayer(shapeLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    // MARK: Layout
    
    override private func layoutSubviews() {
        super.layoutSubviews()
        
        shapeLayer.frame = bounds
        
        shapeLayer.path = UIBezierPath(ovalInRect: shapeLayer.frame).CGPath
    }
}

// MARK: -
// MARK: JESPullToRefreshLoadingViewCircle

public class JESPullToRefreshLoadingViewCircle: JESPullToRefreshLoadingView {
    
    // MARK: -
    // MARK: Vars
    
    private let kRotationAnimation = "kRotationAnimation"
    
    private let shapeLayer = CAShapeLayer()
    private let insideShapeLayer = CAShapeLayer()
    
    private var insideView: JESPullToRefreshLoadingInsideViewCircle?
    
    // MARK: -
    // MARK: Constructors
    
    public init(fillColor: UIColor) {
        super.init(frame: .zero)
        
        shapeLayer.lineWidth = 0.01
        shapeLayer.strokeColor = UIColor.clearColor().CGColor
        shapeLayer.fillColor = JESPullToRefreshConstants.LoadingViewBackgroundColor.CGColor
        shapeLayer.actions = ["strokeEnd": NSNull(), "transform": NSNull()]
        layer.addSublayer(shapeLayer)
        
        self.insideView = JESPullToRefreshLoadingInsideViewCircle(fillColor: fillColor)
        self.addSubview(insideView!)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    // MARK: Methods
    
    override public func setPullProgress(progress: CGFloat) {
        super.setPullProgress(progress)
        
        let width = bounds.width
        let height = bounds.height
        let insideSize = abs((6 - width) * (progress * progress - 2 * progress))
        
        self.insideView?.frame = CGRect(x: width / 2.0, y: height / 2.0, width: insideSize, height: insideSize)
        self.insideView?.center = CGPoint(x: width / 2.0, y: height / 2.0)
        
        if progress == 1.0 { startAnimating() }
    }
    
    override public func startAnimating() {
        super.startAnimating()
        
        // 如果正在执行动画 return
        if shapeLayer.animationForKey(kRotationAnimation) != nil { return }
        
        // 创建颜色 layer
        
        
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
        shapeLayer.path = UIBezierPath(ovalInRect: shapeLayer.frame).CGPath
        
    }
    
}
