//
//  JESRefreshView.swift
//  AnimationCircleDemo
//
//  Created by JerryShi on 10/19/15.
//  Copyright © 2015 shiwei. All rights reserved.
//

import UIKit

enum State {
    case non_Mark
    case Mark
}

let jumpDuration: Double = 0.125
let downDuration: Double = 0.215
let shadowScale: CGFloat = 1.6

class JESRefreshView: UIView {

    private var state: State = .non_Mark {
        willSet {
            self.starView?.image = self.state == .Mark ? self.markedImage : self.non_markedImage
        }
    }
    private var animating: Bool = false
    
    private var markedImage: UIImage = UIImage(named: "jes_refresh_star")!
    private var non_markedImage: UIImage = UIImage(named: "jes_refresh_circle")!
    private var starView: UIImageView?
    private var shadowView: UIImageView?
    private var shadowWidth: CGFloat = 0
    
    init() {
        super.init(frame: CGRect())
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.clearColor()
        if self.starView == nil {
            self.starView = UIImageView(frame: CGRect(x: self.bounds.size.width / 2 - (self.bounds.size.width - 6) / 2, y: 0, width: self.bounds.size.width - 6, height: self.bounds.size.width - 6))
            self.starView?.contentMode = .ScaleToFill
            self.starView?.image = self.markedImage
            self.addSubview(self.starView!)
        }
        if self.shadowView == nil {
            self.shadowWidth = self.frame.size.width - 10
            self.shadowView = UIImageView(frame: CGRect(x: (self.frame.size.width - shadowWidth) / 2, y: self.frame.size.height - 3, width: shadowWidth, height: 3))
            self.shadowView?.alpha = 0.4
            self.shadowView?.image = UIImage(named: "jes_refresh_shadow")
            self.addSubview(self.shadowView!)
        }
    }
    
    func animate() {
        if animating {
            return
        }
        animating = true
        
        let transformAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
        transformAnimation.fromValue = 0
        transformAnimation.toValue = M_PI_2
        transformAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let positionAnimation = CABasicAnimation(keyPath: "position.y")
        positionAnimation.fromValue = self.starView!.center.y
        positionAnimation.toValue = self.starView!.center.y - 14
        positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = jumpDuration
        animationGroup.fillMode = kCAFillModeForwards
        animationGroup.removedOnCompletion = false
        animationGroup.delegate = self
        animationGroup.animations = [transformAnimation, positionAnimation]
        
        self.starView?.layer.addAnimation(animationGroup, forKey: "jumpUp")
    }
    
    override func animationDidStart(anim: CAAnimation) {
        if anim.isEqual(self.starView?.layer.animationForKey("jumpUp")) {
            UIView.animateWithDuration(jumpDuration, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.shadowView!.alpha = 0.2
                self.shadowView!.bounds = CGRect(x: 0, y: 0, width: self.shadowView!.bounds.size.width / shadowScale, height: self.shadowView!.bounds.size.height)
                }, completion: nil)
        } else if anim.isEqual(self.starView?.layer.animationForKey("jumpDown")) {
            UIView.animateWithDuration(jumpDuration, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.shadowView!.alpha = 0.4
                self.shadowView!.bounds = CGRect(x: 0, y: 0, width: self.shadowView!.bounds.size.width * shadowScale, height: self.shadowView!.bounds.size.height)
                }, completion: nil)
        }
    }
    
    // 下落动画
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if anim.isEqual(self.starView?.layer.animationForKey("jumpUp")) {
            self.state = self.state == .Mark ? .non_Mark : .Mark
            let transformAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
            transformAnimation.fromValue = M_PI_2
            transformAnimation.toValue = M_PI
            transformAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            let positionAnimation: CABasicAnimation = CABasicAnimation(keyPath: "position.y")
            positionAnimation.fromValue = self.starView!.center.y - 14
            positionAnimation.toValue = self.starView!.center.y
            positionAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = downDuration
            animationGroup.fillMode = kCAFillModeForwards
            animationGroup.removedOnCompletion = false
            animationGroup.delegate = self
            animationGroup.animations = [transformAnimation, positionAnimation]
            
            self.starView!.layer.addAnimation(animationGroup, forKey: "jumpDown")
            
        } else if anim.isEqual(self.starView?.layer.animationForKey("jumpDown")) {
            self.starView!.layer.removeAllAnimations()
            animating = false
        }
        
    }
    
}
