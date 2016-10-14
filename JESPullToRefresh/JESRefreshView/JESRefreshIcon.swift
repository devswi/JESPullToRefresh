//
//  JESRefreshIcon.swift
//  JESPullToRefresh
//
//  Created by Jerry on 9/5/16.
//  Copyright © 2016 jerryshi. All rights reserved.
//

import UIKit

enum InitialState {
    case up(beginTime: Double)
    case down
    
    func animationBeginTime() -> Double {
        switch self {
        case .down: return 0
        case .up(beginTime: let time): return time
        }
    }
}

class JESRefreshIcon: UIView {

    fileprivate var markedImage: UIImage = UIImage()
    fileprivate var shadowImage: UIImage = UIImage(named: JESRefreshIconConstants.shadowImageName)!
    
    fileprivate var markedImageView: UIImageView?
    fileprivate var shadowImageView: UIImageView?
    
    fileprivate var iconSize: CGFloat = 0.0
    fileprivate var shadowWidth: CGFloat = 0
    
    fileprivate var displayLink: CADisplayLink!
    
    fileprivate var animating: Bool = false
    
    fileprivate var state: InitialState = .up(beginTime: 0.0)
    fileprivate var offsetY: CGFloat = 0.0
    fileprivate var beginTime: Double = 0.0
    
    fileprivate struct JESRefreshIconConstants {
        static let shadowImageName: String = "jes_loading_shadow"
        static let iconSize: CGFloat = 32
        static let maxOffsetY: CGFloat = 14
        
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
        self.animate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func layoutIcon() {
        self.backgroundColor = UIColor.clear
        
        let size: CGFloat = self.iconSize - 2 * JESRefreshIconConstants.IconConstants.markedSpacing
        let offsetX: CGFloat = JESRefreshIconConstants.IconConstants.markedSpacing
        
        self.markedImageView = UIImageView(frame: CGRect(x: offsetX,
                y: 0,
            width: size,
           height: size))
        self.markedImageView?.image = self.markedImage
        self.markedImageView?.contentMode = .scaleToFill
        self.addSubview(self.markedImageView!)
        
        self.shadowImageView = UIImageView(frame: CGRect(x: offsetX, y: self.iconSize - JESRefreshIconConstants.IconConstants.shadowHeight, width: size, height: JESRefreshIconConstants.IconConstants.shadowHeight))
        self.shadowImageView?.alpha = 0.7
        self.shadowImageView?.image = self.shadowImage
        self.addSubview(self.shadowImageView!)
    }
    
    func animate() {
        
        let upAnimation = CABasicAnimation(keyPath: "position.y")
        upAnimation.fromValue = self.markedImageView!.center.y
        upAnimation.toValue = self.markedImageView!.center.y - JESRefreshIconConstants.maxOffsetY
        upAnimation.duration = JESRefreshIconConstants.jumpDuration
        upAnimation.beginTime = 0
        upAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let downAnimation = CABasicAnimation(keyPath: "position.y")
        downAnimation.fromValue = self.markedImageView!.center.y - JESRefreshIconConstants.maxOffsetY
        downAnimation.toValue = self.markedImageView!.center.y
        downAnimation.duration = JESRefreshIconConstants.downDuration
        downAnimation.beginTime = JESRefreshIconConstants.jumpDuration
        downAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [upAnimation, downAnimation]
        animationGroup.duration = JESRefreshIconConstants.jumpDuration + JESRefreshIconConstants.downDuration
        animationGroup.beginTime = self.state.animationBeginTime()
        animationGroup.fillMode = kCAFillModeForwards
        animationGroup.repeatCount = Float.infinity
        animationGroup.isRemovedOnCompletion = false
        animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        self.markedImageView!.layer.add(animationGroup, forKey: "image.animation.key")
        
        let smallAnimation = CABasicAnimation(keyPath: "bounds.size.width")
        smallAnimation.fromValue = self.markedImageView!.bounds.width
        smallAnimation.toValue = self.markedImageView!.bounds.width / JESRefreshIconConstants.shadowScale
        smallAnimation.duration = JESRefreshIconConstants.jumpDuration
        smallAnimation.beginTime = 0
        smallAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let bigAnimation = CABasicAnimation(keyPath: "bounds.size.width")
        bigAnimation.fromValue = self.markedImageView!.bounds.width / JESRefreshIconConstants.shadowScale
        bigAnimation.toValue = self.markedImageView!.bounds.width
        bigAnimation.duration = JESRefreshIconConstants.downDuration
        bigAnimation.beginTime = JESRefreshIconConstants.jumpDuration
        bigAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        let shadowAnimationGroup = CAAnimationGroup()
        shadowAnimationGroup.animations = [smallAnimation, bigAnimation]
        shadowAnimationGroup.duration = JESRefreshIconConstants.jumpDuration + JESRefreshIconConstants.downDuration
        shadowAnimationGroup.beginTime = self.state.animationBeginTime()
        shadowAnimationGroup.fillMode = kCAFillModeForwards
        shadowAnimationGroup.repeatCount = Float.infinity
        shadowAnimationGroup.isRemovedOnCompletion = false
        shadowAnimationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        self.shadowImageView!.layer.add(shadowAnimationGroup, forKey: "shadow.animation.key")
    }

}
