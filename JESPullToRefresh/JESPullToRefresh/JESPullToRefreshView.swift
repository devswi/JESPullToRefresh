//
//  JESPullToRefreshView.swift
//  JESPullToRefresh
//
//  Created by Jerry on 8/16/16.
//  Copyright © 2016 jerryshi. All rights reserved.
//

import UIKit

public
enum JESPullToRefreshState {
    case Stopped
    case Dragging
    case AnimatingBounce
    case Loading
    case AnimatingToStopped
    
    func isAnyOf(values: [JESPullToRefreshState]) -> Bool {
        return values.contains({ $0 == self })
    }
}

public class JESPullToRefreshView: UIView {

    // MARK: -
    // MARK: Vars
    
    private var _state: JESPullToRefreshState = .Stopped
    private(set) var state: JESPullToRefreshState {
        get { return _state }
        set {
            let previousValue = state
            _state = newValue
            
            self.logoImageView.hidden = _state != .Dragging && _state != .AnimatingBounce
            if previousValue == .Dragging && newValue == .AnimatingBounce {
                loadingView?.startAnimating()
                animateBounce()
            } else if newValue == .Loading && actionHandler != nil {
                actionHandler()
            } else if newValue == .AnimatingToStopped {
                resetScrollViewContentInset(shouldAddObserverWhenFinished: true, animated: true, completion: { [weak self] () -> () in self?.state = .Stopped })
            } else if newValue == .Stopped {
                loadingView?.stopLoading()
            }
        }
    }
    
    private var originalContentInsetTop: CGFloat = 0.0 { didSet { layoutSubviews() } }
    private let shapeLayer = CAShapeLayer()
    
    private var displayLink: CADisplayLink!
    
    var actionHandler: (() -> Void)!
    
    var loadingView: JESPullToRefreshLoadingView? {
        willSet {
            loadingView?.removeFromSuperview()
            if let newValue = newValue {
                addSubview(newValue)
            }
        }
    }
    
    var logoImageView: JESPullToRefreshLogoImageView = JESPullToRefreshLogoImageView()
    
    var logoImage: String? {
        willSet {
            logoImageView.removeFromSuperview()
            if let newValue = newValue {
                logoImageView.image = UIImage(named: newValue)
                logoImageView.contentMode = .Top
                addSubview(logoImageView)
            }
        }
    }
    
    var observing: Bool = false {
        didSet {
            guard let scrollView = scrollView() else { return }
            if observing {
                scrollView.jes_addObserver(self, forKeyPath: JESPullToRefreshConstants.KeyPath.ContentOffset)
                scrollView.jes_addObserver(self, forKeyPath: JESPullToRefreshConstants.KeyPath.ContentInset)
                scrollView.jes_addObserver(self, forKeyPath: JESPullToRefreshConstants.KeyPath.Frame)
                scrollView.jes_addObserver(self, forKeyPath: JESPullToRefreshConstants.KeyPath.PanGestureRecognizerState)
            } else {
                scrollView.jes_removeObserver(self, forKeyPath: JESPullToRefreshConstants.KeyPath.ContentOffset)
                scrollView.jes_removeObserver(self, forKeyPath: JESPullToRefreshConstants.KeyPath.ContentInset)
                scrollView.jes_removeObserver(self, forKeyPath: JESPullToRefreshConstants.KeyPath.Frame)
                scrollView.jes_removeObserver(self, forKeyPath: JESPullToRefreshConstants.KeyPath.PanGestureRecognizerState)
            }
        }
    }
    
    var fillColor: UIColor = .clearColor() { didSet { shapeLayer.fillColor = fillColor.CGColor } }
    
    // MARK: Views
    
    private let bounceAnimationHelperView = UIView()
    
    private let cControlPointView = UIView()
    private let lControlPointView = UIView()
    private let rControlPointView = UIView()
    
    private let controlPointView = UIView()
    
    // MARK: -
    // MARK: Constructors
    
    init() {
        super.init(frame: .zero)
        
        displayLink = CADisplayLink(target: self, selector: #selector(JESPullToRefreshView.displayLinkTick))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        displayLink.paused = true
        
        shapeLayer.backgroundColor = UIColor.clearColor().CGColor
        shapeLayer.fillColor = UIColor.blackColor().CGColor
        shapeLayer.actions = ["path" : NSNull(), "position" : NSNull(), "bounds" : NSNull()]
        layer.addSublayer(shapeLayer)
        
        addSubview(bounceAnimationHelperView)
        addSubview(controlPointView)
        addSubview(lControlPointView)
        addSubview(rControlPointView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JESPullToRefreshView.applicationWillEnterForeground), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
    func disassociateDisplayLink() {
        displayLink?.invalidate()
    }
    
    deinit {
        observing = false
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: -
    // MARK: Observer
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == JESPullToRefreshConstants.KeyPath.ContentOffset {
            if let newContentOffsetY = change?[NSKeyValueChangeNewKey]?.CGPointValue.y, let scrollView = scrollView() {
                if state.isAnyOf([.Loading, .AnimatingToStopped]) && newContentOffsetY < -scrollView.contentInset.top {
                    scrollView.contentOffset.y = -scrollView.contentInset.top
                } else {
                    scrollViewDidChangeContentOffset(dragging: scrollView.dragging)
                }
                layoutSubviews()
            }
        } else if keyPath == JESPullToRefreshConstants.KeyPath.ContentInset {
            if let newContentInsetTop = change?[NSKeyValueChangeNewKey]?.UIEdgeInsetsValue().top {
                originalContentInsetTop = newContentInsetTop
            }
        } else if keyPath == JESPullToRefreshConstants.KeyPath.Frame {
            layoutSubviews()
        } else if keyPath == JESPullToRefreshConstants.KeyPath.PanGestureRecognizerState {
            if let gestureState = scrollView()?.panGestureRecognizer.state where gestureState.jes_isAnyOf([.Ended, .Cancelled, .Failed]) {
                scrollViewDidChangeContentOffset(dragging: false)
            }
        }
    }
    
    // MARK: -
    // MARK: Notifications
    
    func applicationWillEnterForeground() {
        if state == .Loading {
            layoutSubviews()
        }
    }
    
    // MARK: -
    // MARK: Methods (Public)
    
    private func scrollView() -> UIScrollView? {
        return superview as? UIScrollView
    }
    
    func stopLoading() {
        // Prevent stop close animation
        if state == .AnimatingToStopped {
            return
        }
        state = .AnimatingToStopped
    }
    
    // MARK: Methods (Private)
    
    private func isAnimating() -> Bool {
        return state.isAnyOf([.AnimatingBounce, .AnimatingToStopped])
    }
    
    private func actualContentOffsetY() -> CGFloat {
        guard let scrollView = scrollView() else { return 0.0 }
        return max(-scrollView.contentInset.top - scrollView.contentOffset.y, 0.0)
    }
    
    private func currentHeight() -> CGFloat {
        guard let scrollView = scrollView() else { return 0.0 }
        return max(-originalContentInsetTop - scrollView.contentOffset.y, 0)
    }
    
    private func currentWaveHeight() -> CGFloat {
        return min(bounds.height / 3.0 * 1.6, JESPullToRefreshConstants.LoadingViewMaxHeight)
    }
    
    private func currentPath() -> CGPath {
        let width: CGFloat = scrollView()?.bounds.width ?? 0.0
        
        let bezierPath = UIBezierPath()
        let animating = isAnimating()
        
        bezierPath.moveToPoint(CGPoint(x: 0.0, y: 0.0))
        bezierPath.addLineToPoint(lControlPointView.jes_center(animating))
        bezierPath.addQuadCurveToPoint(rControlPointView.jes_center(animating), controlPoint: controlPointView.jes_center(animating))
        bezierPath.addLineToPoint(rControlPointView.jes_center(animating))
        bezierPath.addLineToPoint(CGPoint(x: width, y: 0.0))
        
        bezierPath.closePath()
        
        return bezierPath.CGPath
    }
    
    private func scrollViewDidChangeContentOffset(dragging dragging: Bool) {
        let offsetY = actualContentOffsetY()
        
        if state == .Stopped && dragging {
            state = .Dragging
            loadingView?.alpha = 1
            alpha = 1
        } else if state == .Dragging && dragging == false {
            if offsetY >= JESPullToRefreshConstants.MinOffsetToPull {
                state = .AnimatingBounce
            } else {
                state = .Stopped
            }
        } else if state.isAnyOf([.Dragging, .Stopped]) {
            var pullProgress: CGFloat = offsetY <= JESPullToRefreshConstants.LoadingViewMinOffsetY ? 0.0 : min(abs(offsetY - JESPullToRefreshConstants.LoadingViewMinOffsetY) / (JESPullToRefreshConstants.MinOffsetToPull), 1.0)
            if state == .Stopped { pullProgress = 0.0 }
            let height = bounds.height
            if height > 2 * JESPullToRefreshConstants.LoadingViewTopSpacing { loadingView?.setPullProgress(pullProgress) }
        }
    }
    
    private func resetScrollViewContentInset(shouldAddObserverWhenFinished shouldAddObserverWhenFinished: Bool, animated: Bool, completion: (() -> ())?) {
        guard let scrollView = scrollView() else { return }
        
        var contentInset = scrollView.contentInset
        contentInset.top = originalContentInsetTop
        
        if state == .AnimatingBounce {
            contentInset.top += currentHeight()
        } else if state == .Loading {
            contentInset.top += JESPullToRefreshConstants.LoadingContentInset
        }
        
        scrollView.jes_removeObserver(self, forKeyPath: JESPullToRefreshConstants.KeyPath.ContentInset)
        
        let animationBlock = {
            if self.state == .AnimatingToStopped {
                self.loadingView?.alpha = 0
                self.alpha = 0
            }
            scrollView.contentInset = contentInset
        }
        let completionBlock = { () -> Void in
            if shouldAddObserverWhenFinished && self.observing {
                scrollView.jes_addObserver(self, forKeyPath: JESPullToRefreshConstants.KeyPath.ContentInset)
            }
            completion?()
        }
        
        if animated {
            startDisplayLink()
            UIView.animateWithDuration(0.5, animations: animationBlock, completion: { _ in
                self.stopDisplayLink()
                completionBlock()
            })
        } else {
            animationBlock()
            completionBlock()
        }
    }
    
    private func animateBounce() {
        guard let scrollView = scrollView() else { return }
        if (!self.observing) { return }
        
        resetScrollViewContentInset(shouldAddObserverWhenFinished: false, animated: false, completion: nil)
        
        let centerY = JESPullToRefreshConstants.LoadingContentInset
        let duration = 0.2
        
        scrollView.scrollEnabled = false
        startDisplayLink()
        scrollView.jes_removeObserver(self, forKeyPath: JESPullToRefreshConstants.KeyPath.ContentOffset)
        scrollView.jes_removeObserver(self, forKeyPath: JESPullToRefreshConstants.KeyPath.ContentInset)
        UIView.animateWithDuration(duration, animations: { [weak self] in
            self?.controlPointView.center.y = centerY
            self?.lControlPointView.center.y = centerY
            self?.rControlPointView.center.y = centerY
        }) { [weak self] _ in
            self?.stopDisplayLink()
            self?.resetScrollViewContentInset(shouldAddObserverWhenFinished: true, animated: false, completion: nil)
            if let strongSelf = self, scrollView = strongSelf.scrollView() {
                scrollView.jes_addObserver(strongSelf, forKeyPath: JESPullToRefreshConstants.KeyPath.ContentOffset)
                scrollView.scrollEnabled = true
            }
            self?.state = .Loading
        }
        
        bounceAnimationHelperView.center = CGPoint(x: 0.0, y: originalContentInsetTop + currentHeight())
        UIView.animateWithDuration(duration, animations: { [weak self] in
            if let contentInsetTop = self?.originalContentInsetTop {
                self?.bounceAnimationHelperView.center = CGPoint(x: 0.0, y: contentInsetTop + JESPullToRefreshConstants.LoadingContentInset)
            }
        }, completion: nil)
    }
    
    // MARK: -
    // MARK: CADisplayLink
    
    private func startDisplayLink() {
        displayLink.paused = false
    }
    
    private func stopDisplayLink() {
        displayLink.paused = true
    }
    
    func displayLinkTick() {
        let width = bounds.width
        var height: CGFloat = 0.0
        
        if state == .AnimatingBounce {
            guard let scrollView = scrollView() else { return }
            
            scrollView.contentInset.top = bounceAnimationHelperView.jes_center(isAnimating()).y
            scrollView.contentOffset.y = -scrollView.contentInset.top
            
            height = scrollView.contentInset.top - originalContentInsetTop
        } else if state == .AnimatingToStopped {
            guard let scrollView = scrollView() else { return }
            height = -scrollView.contentOffset.y
        }
        
        frame = CGRect(x: 0.0, y: -height - 1.0, width: width, height: height)
        shapeLayer.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        shapeLayer.path = currentPath()
        
        layoutLoadingView()
    }
    
    // MARK: -
    // MARK: Layout
    
    private func layoutLoadingView() {
        
        let width = bounds.width
        let height: CGFloat = bounds.height
        
        let maxLoadingViewSize: CGFloat = JESPullToRefreshConstants.LoadingViewSize
        
        // Max origin Y of loading view
        let maxOriginY = (JESPullToRefreshConstants.LoadingContentInset - maxLoadingViewSize) / 2.0
        
        let originY: CGFloat = min((maxOriginY / (JESPullToRefreshConstants.LoadingContentInset * JESPullToRefreshConstants.LoadingContentInset)) * height * height + 1, maxOriginY)
        let loadingViewSize: CGFloat = min(max(height - 2 * originY, 0.0), maxLoadingViewSize)
        
        loadingView?.frame = CGRect(x: (width - loadingViewSize) / 2.0, y: originY, width: loadingViewSize, height: loadingViewSize)
//        loadingView?.maskLayer.frame = convertRect(shapeLayer.frame, toView: loadingView)
//        loadingView?.maskLayer.path = shapeLayer.path
        
        logoImageView.frame = CGRect(x: 0, y: originY + maxLoadingViewSize + 20, width: width, height: 108)
        logoImageView.maskLayer.frame = convertRect(shapeLayer.frame, toView: logoImageView)
        logoImageView.maskLayer.path = shapeLayer.path
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if let scrollView = scrollView() where state != .AnimatingBounce {
            let width = scrollView.bounds.width
            let height = state == .AnimatingToStopped ? -scrollView.contentOffset.y :  currentHeight()
            
            frame = CGRect(x: 0.0, y: -height, width: width, height: height)
            
            // Loading || Stopped
            if state.isAnyOf([.Loading, .AnimatingToStopped]) {
                controlPointView.center = CGPoint(x: width / 2.0, y: height)
                lControlPointView.center = CGPoint(x: 0, y: height)
                rControlPointView.center = CGPoint(x: width, y: height)
            } else {
                controlPointView.center = CGPoint(x: width / 2.0, y: height)
                lControlPointView.center = CGPoint(x: 0, y: height)
                rControlPointView.center = CGPoint(x: width, y: height)
            }
            
            shapeLayer.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            shapeLayer.path = currentPath()
            layoutLoadingView()
        }
    }

}
