//
//  JESPullToRefreshConstants.swift
//  JESPullToRefresh
//
//  Created by Jerry on 8/16/16.
//  Copyright © 2016 jerryshi. All rights reserved.
//

import CoreGraphics

public struct JESPullToRefreshConstants {
    struct KeyPath {
        static let ContentOffset = "contentOffset"
        static let ContentInset = "contentInset"
        static let Frame = "frame"
        static let PanGestureRecognizerState = "panGestureRecognizer.state"
    }
    
    public static var LoadingViewMaxHeight: CGFloat = 70.0
    public static var MinOffsetToPull: CGFloat = 85.0
    public static var LoadingContentInset: CGFloat = 64.0
    public static var LoadingViewSize: CGFloat = 30.0
}
