//
//  JESRefreshIcon.swift
//  JESPullToRefresh
//
//  Created by Jerry on 9/5/16.
//  Copyright © 2016 jerryshi. All rights reserved.
//

import UIKit

enum InitialState {
    case up(offsetY: CGFloat)
    case down(offsetY: CGFloat)
    
    func getOffsetY() -> CGFloat {
        switch self {
        case .up(offsetY: let offsetY): return offsetY
        case .down(offsetY: let offsetY): return offsetY
        }
    }
    
    func initialDirecton() -> String {
        switch self {
        case .up(offsetY: _): return "jumpUp"
        case .down(offsetY: _): return "jumpDown"
        }
    }
    
    func nextDirection() -> String {
        switch self {
        case .up(offsetY: _): return "jumpDown"
        case .down(offsetY: _): return "jumpUp"
        }
    }
}

class JESRefreshIcon: UIView {

    private var markedImage: UIImage = UIImage()
    private var shadowImage: UIImage = UIImage(named: JESRefreshIconConstants.shadowImageName)!
    
    private var markedImageView: UIImageView?
    private var shadowImageView: UIImageView?
    
    private var iconSize: CGFloat = 0.0
    private var shadowWidth: CGFloat = 0
    
    private var displayLink: CADisplayLink!
    
    private var animating: Bool = false
    
    private var state: InitialState = .up(offsetY: 0.0)
    private var offsetY: CGFloat = 0.0
    
    private struct JESRefreshIconConstants {
        static let shadowImageName: String = "jes_loading_shadow"
        static let iconSize: CGFloat = 32
        static let maxOffsetY: CGFloat = 16
        
        // MARK: - Animation
        static let jumpDuration: Double = 0.235
        static let downDuration: Double = 0.475
        static let shadowScale: CGFloat = 1.6
        
        struct IconConstants {
            static let markedSpacing: CGFloat = 3
            static let shadowHeight: CGFloat = 3
        }
    }
    
    convenience init(withMarkedImageName name: String, initialState: InitialState) {
        
        self.init(frame: CGRect(x: 0, y: 0, width: JESRefreshIconConstants.iconSize, height: JESRefreshIconConstants.iconSize))
        
        self.state = initialState
        self.iconSize = JESRefreshIconConstants.iconSize
        self.markedImage = UIImage(named: name)!
        self.layoutIcon()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutIcon() {
        self.backgroundColor = UIColor.clearColor()
        
        displayLink = CADisplayLink(target: self, selector: #selector(JESRefreshIcon.displayLinkTick))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        displayLink.paused = true
        
        let size: CGFloat = self.iconSize - 2 * JESRefreshIconConstants.IconConstants.markedSpacing
        let offsetX: CGFloat = JESRefreshIconConstants.IconConstants.markedSpacing
        
        self.markedImageView = UIImageView(frame: CGRect(x: offsetX,
                y: -self.state.getOffsetY(),
            width: size,
           height: size))
        self.markedImageView?.image = self.markedImage
        self.markedImageView?.contentMode = .ScaleToFill
        self.addSubview(self.markedImageView!)
        
        self.shadowImageView = UIImageView(frame: CGRect(x: offsetX, y: self.iconSize - JESRefreshIconConstants.IconConstants.shadowHeight, width: size, height: JESRefreshIconConstants.IconConstants.shadowHeight))
        self.shadowImageView?.alpha = 0.7
        self.shadowImageView?.image = self.shadowImage
        self.addSubview(self.shadowImageView!)
    }
    
    func animate() {
        if animating { return }
        startDisplayLink()
        
        animating = true
        
        let positionAnimation = CABasicAnimation(keyPath: "position.y")
        positionAnimation.fromValue = self.markedImageView!.center.y
        positionAnimation.toValue =  -JESRefreshIconConstants.maxOffsetY
        positionAnimation.duration = JESRefreshIconConstants.jumpDuration
        positionAnimation.fillMode = kCAFillModeForwards
        positionAnimation.removedOnCompletion = false
        positionAnimation.delegate = self
        positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        self.markedImageView!.layer.addAnimation(positionAnimation, forKey: self.state.initialDirecton())
    }
    
    private func startDisplayLink() {
        displayLink.paused = false
    }
    
    private func stopDisplayLink() {
        displayLink.paused = true
        
        self.markedImageView!.layer.removeAllAnimations()
        animating = false
    }
    
    func stopAnimate() {
        self.stopDisplayLink()
    }
    
    // MARK
    // MARK: Display Link
    func displayLinkTick() {
        animate()
    }
    
    // MARK: -
    
    func disassociateDisplayLink() {
        displayLink?.invalidate()
    }
    
    override func animationDidStart(anim: CAAnimation) {
        if anim.isEqual(self.markedImageView?.layer.animationForKey("jumpUp")) {
            UIView.animateWithDuration(JESRefreshIconConstants.jumpDuration, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
                self.shadowImageView!.bounds = CGRect(x: 0, y: 0, width: self.shadowImageView!.bounds.size.width / JESRefreshIconConstants.shadowScale, height: self.shadowImageView!.bounds.size.height)
                }, completion: nil)
        } else if anim.isEqual(self.markedImageView?.layer.animationForKey("jumpDown")) {
            UIView.animateWithDuration(JESRefreshIconConstants.downDuration, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
                self.shadowImageView!.bounds = CGRect(x: 0, y: 0, width: self.shadowImageView!.bounds.size.width * JESRefreshIconConstants.shadowScale, height: self.shadowImageView!.bounds.size.height)
                }, completion: nil)
        }
    }
    
    // 下落动画
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if anim.isEqual(self.markedImageView?.layer.animationForKey("jumpUp")) {
            
            let positionAnimation: CABasicAnimation = CABasicAnimation(keyPath: "position.y")
            positionAnimation.fromValue = -JESRefreshIconConstants.maxOffsetY
            positionAnimation.toValue = 0
            positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            positionAnimation.duration = JESRefreshIconConstants.downDuration
            positionAnimation.fillMode = kCAFillModeForwards
            positionAnimation.removedOnCompletion = false
            positionAnimation.delegate = self
            
            self.markedImageView!.layer.addAnimation(positionAnimation, forKey: "jumpDown")
            
        } else if anim.isEqual(self.markedImageView?.layer.animationForKey("jumpDown")) {
            
            let positionAnimation: CABasicAnimation = CABasicAnimation(keyPath: "position.y")
            positionAnimation.fromValue = 0
            positionAnimation.toValue = -JESRefreshIconConstants.maxOffsetY
            positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            positionAnimation.duration = JESRefreshIconConstants.downDuration
            positionAnimation.fillMode = kCAFillModeForwards
            positionAnimation.removedOnCompletion = false
            positionAnimation.delegate = self
            
            self.markedImageView!.layer.addAnimation(positionAnimation, forKey: "jumpUp")
        }
        
    }

}
