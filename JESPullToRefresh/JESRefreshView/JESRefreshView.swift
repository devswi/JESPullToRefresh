//
//  JESRefreshView.swift
//  AnimationCircleDemo
//
//  Created by JerryShi on 10/19/15.
//  Copyright © 2015 shiwei. All rights reserved.
//

import UIKit

class JESRefreshView: UIView {
    
    private var loadingViewO: JESRefreshIcon?
    private var loadingViewR: JESRefreshIcon?
    private var loadingViewT: JESRefreshIcon?
    private var loadingViewX: JESRefreshIcon?
    
    private var loadingViews: [JESRefreshIcon] = []
    
    private struct Constants {
        static let iconSize: CGFloat = 32
    }
    
    convenience init() {
        
        self.init(frame: CGRect())
        
        self.layoutSubviews()
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
        
        if self.loadingViewO == nil {
            self.loadingViewO = JESRefreshIcon(withMarkedImageName: "jes_loading_o", initialState: .up(beginTime: 0))
            self.addSubview(self.loadingViewO!)
            
            self.loadingViews.append(self.loadingViewO!)
        }
        if self.loadingViewR == nil {
            self.loadingViewR = JESRefreshIcon(withMarkedImageName: "jes_loading_r", initialState: .up(beginTime: 0.235))
            self.addSubview(self.loadingViewR!)
            self.loadingViews.append(self.loadingViewR!)
        }
        if self.loadingViewT == nil {
            self.loadingViewT = JESRefreshIcon(withMarkedImageName: "jes_loading_t", initialState: .up(beginTime: 0.175))
            self.addSubview(self.loadingViewT!)
            self.loadingViews.append(self.loadingViewT!)
        }
        if self.loadingViewX == nil {
            self.loadingViewX = JESRefreshIcon(withMarkedImageName: "jes_loading_x", initialState: .up(beginTime: 0.385))
            self.addSubview(self.loadingViewX!)
            self.loadingViews.append(self.loadingViewX!)
        }
        
        self.layoutFrames()
        
        // MARK: -
        // MARK: 
    }
    
    private func layoutFrames() {
        self.loadingViews.forEach { icon in
            let index: Int = self.loadingViews.indexOf(icon) ?? 0
            let x = CGFloat(index) * (icon.bounds.width + 5)
            var frame = icon.frame
            frame.origin.x = x
            icon.frame = frame
        }
    }
    
    func animate() {
        UIView.animateWithDuration(0.35) {
            self.alpha = 1.0
        }
    }
    
}
