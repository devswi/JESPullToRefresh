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
    case stopped
    case dragging
    case animatingBounce
    case loading
    case animatingToStopped
    
    func isAnyOf(_ values: [JESPullToRefreshState]) -> Bool {
        return values.contains(where: { $0 == self })
    }
}

open class JESPullToRefreshView: UIView {

    // MARK: -
    // MARK: Vars
    
    fileprivate var _state: JESPullToRefreshState = .stopped
    fileprivate(set) var state: JESPullToRefreshState {
        get { return _state }
        set {
            let previousValue = state
            _state = newValue
            
            self.logoImageView.isHidden = _state != .dragging && _state != .animatingBounce
            if previousValue == .dragging && newValue == .animatingBounce {
                loadingView?.startAnimating()
                animateBounce()
            } else if newValue == .loading && actionHandler != nil {
                actionHandler()
            } else if newValue == .animatingToStopped {
                resetScrollViewContentInset(shouldAddObserverWhenFinished: true, animated: true, completion: { [weak self] () -> () in self?.state = .stopped })
            } else if newValue == .stopped {
                loadingView?.stopLoading()
            }
        }
    }
    
    fileprivate var originalContentInsetTop: CGFloat = 0.0 { didSet { layoutSubviews() } }
    fileprivate let shapeLayer = CAShapeLayer()
    
    fileprivate var displayLink: CADisplayLink!
    
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
                logoImageView.contentMode = .top
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
    
    var fillColor: UIColor = UIColor.clear { didSet { shapeLayer.fillColor = fillColor.cgColor } }
    
    // MARK: Views
    
    fileprivate let bounceAnimationHelperView = UIView()
    
    fileprivate let cControlPointView = UIView()
    fileprivate let lControlPointView = UIView()
    fileprivate let rControlPointView = UIView()
    
    fileprivate let controlPointView = UIView()
    
    // MARK: -
    // MARK: Constructors
    
    init() {
        super.init(frame: .zero)
        
        displayLink = CADisplayLink(target: self, selector: #selector(JESPullToRefreshView.displayLinkTick))
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        displayLink.isPaused = true
        
        shapeLayer.backgroundColor = UIColor.clear.cgColor
        shapeLayer.fillColor = UIColor.black.cgColor
        shapeLayer.actions = ["path" : NSNull(), "position" : NSNull(), "bounds" : NSNull()]
        layer.addSublayer(shapeLayer)
        
        addSubview(bounceAnimationHelperView)
        addSubview(lControlPointView)
        addSubview(rControlPointView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(JESPullToRefreshView.applicationWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
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
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: -
    // MARK: Observer
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == JESPullToRefreshConstants.KeyPath.ContentOffset {
            if let newContentOffsetY = (change?[.newKey] as? NSValue)?.cgPointValue.y, let scrollView = scrollView() {
                if state.isAnyOf([.loading, .animatingToStopped]) && newContentOffsetY < -scrollView.contentInset.top {
                    scrollView.contentOffset.y = -scrollView.contentInset.top
                } else {
                    scrollViewDidChangeContentOffset(dragging: scrollView.isDragging)
                }
                layoutSubviews()
            }
        } else if keyPath == JESPullToRefreshConstants.KeyPath.ContentInset {
            if let newContentInsetTop = (change?[.newKey] as? NSValue)?.uiEdgeInsetsValue.top {
                originalContentInsetTop = newContentInsetTop
            }
        } else if keyPath == JESPullToRefreshConstants.KeyPath.Frame {
            layoutSubviews()
        } else if keyPath == JESPullToRefreshConstants.KeyPath.PanGestureRecognizerState {
            if let gestureState = scrollView()?.panGestureRecognizer.state , gestureState.jes_isAnyOf([.ended, .cancelled, .failed]) {
                scrollViewDidChangeContentOffset(dragging: false)
            }
        }
    }
    
    // MARK: -
    // MARK: Notifications
    
    func applicationWillEnterForeground() {
        if state == .loading {
            layoutSubviews()
        }
    }
    
    // MARK: -
    // MARK: Methods (Public)
    
    fileprivate func scrollView() -> UIScrollView? {
        return superview as? UIScrollView
    }
    
    func stopLoading() {
        // Prevent stop close animation
        if state == .animatingToStopped { return }
        state = .animatingToStopped
    }
    
    // MARK: Methods (Private)
    
    fileprivate func isAnimating() -> Bool {
        return state.isAnyOf([.animatingBounce, .animatingToStopped])
    }
    
    fileprivate func actualContentOffsetY() -> CGFloat {
        guard let scrollView = scrollView() else { return 0.0 }
        return max(-scrollView.contentInset.top - scrollView.contentOffset.y, 0.0)
    }
    
    fileprivate func currentHeight() -> CGFloat {
        guard let scrollView = scrollView() else { return 0.0 }
        return max(-originalContentInsetTop - scrollView.contentOffset.y, 0)
    }
    
    fileprivate func currentWaveHeight() -> CGFloat {
        return min(bounds.height / 3.0 * 1.6, JESPullToRefreshConstants.LoadingViewMaxHeight)
    }
    
    fileprivate func currentPath() -> CGPath {
        let width: CGFloat = scrollView()?.bounds.width ?? 0.0
        
        let bezierPath = UIBezierPath()
        let animating = isAnimating()
        
        bezierPath.move(to: CGPoint(x: 0.0, y: 0.0))
        bezierPath.addLine(to: lControlPointView.jes_center(animating))
        bezierPath.addLine(to: rControlPointView.jes_center(animating))
        bezierPath.addLine(to: CGPoint(x: width, y: 0.0))
        
        bezierPath.close()
        
        return bezierPath.cgPath
    }
    
    fileprivate func scrollViewDidChangeContentOffset(dragging: Bool) {
        let offsetY = actualContentOffsetY()
        
        if state == .stopped && dragging {
            state = .dragging
            loadingView?.alpha = 1
        } else if state == .dragging && dragging == false {
            if offsetY >= JESPullToRefreshConstants.MinOffsetToPull {
                state = .animatingBounce
            } else {
                state = .stopped
            }
        } else if state.isAnyOf([.dragging, .stopped]) {
            var pullProgress: CGFloat = offsetY <= JESPullToRefreshConstants.LoadingViewMinOffsetY ? 0.0 : min(abs(offsetY - JESPullToRefreshConstants.LoadingViewMinOffsetY) / (JESPullToRefreshConstants.MinOffsetToPull), 1.0)
            if state == .stopped { pullProgress = 0.0 }
            let height = bounds.height
            if height > 2 * JESPullToRefreshConstants.LoadingViewTopSpacing { loadingView?.setPullProgress(pullProgress) }
        }
    }
    
    fileprivate func resetScrollViewContentInset(shouldAddObserverWhenFinished: Bool, animated: Bool, completion: (() -> ())?) {
        guard let scrollView = scrollView() else { return }
        
        var contentInset = scrollView.contentInset
        contentInset.top = originalContentInsetTop
        
        if state == .animatingBounce {
            contentInset.top += currentHeight()
        } else if state == .loading {
            contentInset.top += JESPullToRefreshConstants.LoadingContentInset
        }
        
        scrollView.jes_removeObserver(self, forKeyPath: JESPullToRefreshConstants.KeyPath.ContentInset)
        
        let animationBlock = {
            if self.state == .animatingToStopped { self.loadingView?.alpha = 0 }
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
            UIView.animate(withDuration: 0.2, animations: animationBlock, completion: { _ in
                self.stopDisplayLink()
                completionBlock()
            })
        } else {
            animationBlock()
            completionBlock()
        }
    }
    
    fileprivate func animateBounce() {
        guard let scrollView = scrollView() else { return }
        if (!self.observing) { return }
        
        resetScrollViewContentInset(shouldAddObserverWhenFinished: false, animated: false, completion: nil)
        
        let centerY = JESPullToRefreshConstants.LoadingContentInset
        let duration = 0.2
        
        scrollView.isScrollEnabled = false
        startDisplayLink()
        scrollView.jes_removeObserver(self, forKeyPath: JESPullToRefreshConstants.KeyPath.ContentOffset)
        scrollView.jes_removeObserver(self, forKeyPath: JESPullToRefreshConstants.KeyPath.ContentInset)
        
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.lControlPointView.center.y = centerY
            self?.rControlPointView.center.y = centerY
        }, completion: { [weak self] _ in
            self?.stopDisplayLink()
            self?.resetScrollViewContentInset(shouldAddObserverWhenFinished: true, animated: false, completion: nil)
            if let strongSelf = self, let scrollView = strongSelf.scrollView() {
                scrollView.jes_addObserver(strongSelf, forKeyPath: JESPullToRefreshConstants.KeyPath.ContentOffset)
                scrollView.isScrollEnabled = true
            }
            self?.state = .loading
        }) 
        
        bounceAnimationHelperView.center = CGPoint(x: 0.0, y: originalContentInsetTop + currentHeight())
        UIView.animate(withDuration: duration, animations: { [weak self] in
            if let contentInsetTop = self?.originalContentInsetTop {
                self?.bounceAnimationHelperView.center = CGPoint(x: 0.0, y: contentInsetTop + JESPullToRefreshConstants.LoadingContentInset)
            }
        }, completion: nil)
    }
    
    // MARK: -
    // MARK: CADisplayLink
    
    fileprivate func startDisplayLink() {
        displayLink.isPaused = false
    }
    
    fileprivate func stopDisplayLink() {
        displayLink.isPaused = true
    }
    
    func displayLinkTick() {
        let width = bounds.width
        var height: CGFloat = 0.0
        
        if state == .animatingBounce {
            guard let scrollView = scrollView() else { return }
            
            scrollView.contentInset.top = bounceAnimationHelperView.jes_center(isAnimating()).y
            scrollView.contentOffset.y = -scrollView.contentInset.top
            
            height = scrollView.contentInset.top - originalContentInsetTop
        } else if state == .animatingToStopped {
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
    
    fileprivate func layoutLoadingView() {
        
        let width = bounds.width
        let height: CGFloat = bounds.height
        
        let maxLoadingViewSize: CGFloat = JESPullToRefreshConstants.LoadingViewSize
        
        // Max origin Y of loading view
        let maxOriginY = (JESPullToRefreshConstants.LoadingContentInset - maxLoadingViewSize) / 2.0
        
        let originY: CGFloat = min((maxOriginY / (JESPullToRefreshConstants.LoadingContentInset * JESPullToRefreshConstants.LoadingContentInset)) * height * height + 1, maxOriginY)
        let loadingViewSize: CGFloat = min(max(height - 2 * originY, 0.0), maxLoadingViewSize)
        
        loadingView?.frame = CGRect(x: (width - loadingViewSize) / 2.0, y: originY, width: loadingViewSize, height: loadingViewSize)
        loadingView?.maskLayer.frame = convert(shapeLayer.frame, to: loadingView)
        loadingView?.maskLayer.path = shapeLayer.path
        
        logoImageView.frame = CGRect(x: 0, y: originY + maxLoadingViewSize + 20, width: width, height: 108)
        logoImageView.maskLayer.frame = convert(shapeLayer.frame, to: logoImageView)
        logoImageView.maskLayer.path = shapeLayer.path
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if let scrollView = scrollView() , state != .animatingBounce {
            let width = scrollView.bounds.width
            let height = currentHeight()
            
            frame = CGRect(x: 0.0, y: -height, width: width, height: height)
            
            // Loading || Stopped
            if state.isAnyOf([.loading, .animatingToStopped]) {
                lControlPointView.center = CGPoint(x: 0, y: height)
                rControlPointView.center = CGPoint(x: width, y: height)
            } else {
                lControlPointView.center = CGPoint(x: 0, y: height)
                rControlPointView.center = CGPoint(x: width, y: height)
            }
            
            shapeLayer.frame = CGRect(x: 0.0, y: 0.0, width: width, height: height)
            shapeLayer.path = currentPath()
            layoutLoadingView()
        }
    }

}
