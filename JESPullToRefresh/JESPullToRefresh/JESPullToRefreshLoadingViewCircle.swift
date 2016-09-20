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
    
    fileprivate let shapeLayer = CAShapeLayer()
    
    fileprivate init(fillColor: UIColor) {
        super.init(frame: .zero)
        
        self.backgroundColor = UIColor.clear
        
        shapeLayer.lineWidth = 0.01
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.actions = ["strokeEnd": NSNull(), "transform": NSNull()]
        layer.addSublayer(shapeLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    // MARK: Layout
    
    override fileprivate func layoutSubviews() {
        super.layoutSubviews()
        
        shapeLayer.frame = bounds
        shapeLayer.path = UIBezierPath(ovalIn: shapeLayer.frame).cgPath
    }
}

// MARK: -
// MARK: JESPullToRefreshLoadingViewCircle

open class JESPullToRefreshLoadingViewCircle: JESPullToRefreshLoadingView {
    
    // MARK: -
    // MARK: Vars
    
    fileprivate let kRotationAnimation = "kRotationAnimation"
    
    fileprivate let shapeLayer = CAShapeLayer()
    fileprivate var insideView: JESPullToRefreshLoadingInsideViewCircle?
    
    // MARK: -
    // MARK: Rings
    fileprivate let ringLayerT = CAShapeLayer()
    fileprivate let ringLayerR = CAShapeLayer()
    fileprivate let ringLayerX = CAShapeLayer()
    fileprivate let ringLayerO = CAShapeLayer()
    
    // MARK: -
    // MARK: Constructors
    
    public init(fillColor: UIColor) {
        super.init(frame: .zero)
        
        shapeLayer.lineWidth = 0.01
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.fillColor = JESPullToRefreshConstants.LoadingViewBackgroundColor.cgColor
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
    
    override open func setPullProgress(_ progress: CGFloat) {
        super.setPullProgress(progress)
        
        if progress < 1.0 {
            self.stopLoading()
        }
        
        let width = bounds.width
        let height = bounds.height
        let insideSize = abs((6 - width) * (progress * progress - 2 * progress))
        
        self.insideView?.frame = CGRect(x: width / 2.0, y: height / 2.0, width: insideSize, height: insideSize)
        self.insideView?.center = CGPoint(x: width / 2.0, y: height / 2.0)
        
        if progress == 1.0 { startAnimating() }
    }
    
    override open func startAnimating() {
        super.startAnimating()
        
        // 如果正在执行动画 return
        if shapeLayer.animation(forKey: kRotationAnimation) != nil { return }
        
        // 四色曲线
        // 6CE4E8
        // E5A8E1
        // 7DA8F9
        // FA6979
        ringLayerT.lineWidth = 3.0
        ringLayerT.strokeColor = UIColor(hex: 0x6CE4E8).cgColor
        ringLayerT.fillColor = UIColor.clear.cgColor
        shapeLayer.addSublayer(ringLayerT)
        
        ringLayerT.strokeStart = 0
        ringLayerT.strokeEnd = 0.25
        
        ringLayerR.lineWidth = 3.0
        ringLayerR.strokeColor = UIColor(hex: 0xE5A8E1).cgColor
        ringLayerR.fillColor = UIColor.clear.cgColor
        shapeLayer.addSublayer(ringLayerR)
        
        ringLayerR.strokeStart = 0.25
        ringLayerR.strokeEnd = 0.5
        
        ringLayerX.lineWidth = 3.0
        ringLayerX.strokeColor = UIColor(hex: 0x7DA8F9).cgColor
        ringLayerX.fillColor = UIColor.clear.cgColor
        shapeLayer.addSublayer(ringLayerX)
        
        ringLayerX.strokeStart = 0.5
        ringLayerX.strokeEnd = 0.75
        
        ringLayerO.lineWidth = 3.0
        ringLayerO.strokeColor = UIColor(hex: 0xFA6979).cgColor
        ringLayerO.fillColor = UIColor.clear.cgColor
        shapeLayer.addSublayer(ringLayerO)
        
        ringLayerO.strokeStart = 0.75
        ringLayerO.strokeEnd = 1.0
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(2 * M_PI) + currentDegree()
        rotationAnimation.duration = 1.0
        rotationAnimation.repeatCount = Float.infinity
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.fillMode = kCAFillModeForwards
        shapeLayer.add(rotationAnimation, forKey: kRotationAnimation)
    }
    
    override open func stopLoading() {
        super.stopLoading()
        
        shapeLayer.removeAnimation(forKey: kRotationAnimation)
        ringLayerO.removeFromSuperlayer()
        ringLayerX.removeFromSuperlayer()
        ringLayerR.removeFromSuperlayer()
        ringLayerT.removeFromSuperlayer()
        
        shapeLayer.fillColor = JESPullToRefreshConstants.LoadingViewBackgroundColor.cgColor
    }
    
    fileprivate func currentDegree() -> CGFloat {
        return shapeLayer.value(forKeyPath: "transform.rotation.z") as! CGFloat
    }
    
    override open func tintColorDidChange() {
        super.tintColorDidChange()
        
        shapeLayer.strokeColor = JESPullToRefreshConstants.LoadingViewBackgroundColor.cgColor
    }
    
    // MARK: -
    // MARK: Layout
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
        shapeLayer.path = UIBezierPath(ovalIn: shapeLayer.frame).cgPath
        
        let inset = ringLayerT.lineWidth / 2.0
        ringLayerT.path = UIBezierPath(ovalIn: shapeLayer.bounds.insetBy(dx: inset, dy: inset)).cgPath
        ringLayerO.path = UIBezierPath(ovalIn: shapeLayer.bounds.insetBy(dx: inset, dy: inset)).cgPath
        ringLayerX.path = UIBezierPath(ovalIn: shapeLayer.bounds.insetBy(dx: inset, dy: inset)).cgPath
        ringLayerR.path = UIBezierPath(ovalIn: shapeLayer.bounds.insetBy(dx: inset, dy: inset)).cgPath
    }
    
}

extension UIColor {
    convenience init(hex: Int) {
        self.init(red: CGFloat((hex & 0xFF0000) >> 16) / 255.0, green: CGFloat((hex & 0xFF00) >> 8) / 255.0, blue: CGFloat(hex & 0xFF) / 255.0, alpha: 1.0)
    }
}
