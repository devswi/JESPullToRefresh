//
//  JESRefreshIcon.swift
//  JESPullToRefresh
//
//  Created by Jerry on 9/5/16.
//  Copyright © 2016 jerryshi. All rights reserved.
//

import UIKit

class JESRefreshIcon: UIView {

    private var markedImage: UIImage = UIImage()
    private var shadowImage: UIImage = UIImage(named: JESRefreshIconConstants.shadowImageName)!
    
    private var markedImageView: UIImageView?
    private var shadowImageView: UIImageView?
    
    private var iconSize: CGFloat = 0.0
    
    private struct JESRefreshIconConstants {
        static let SCREENWIDTH: CGFloat = UIScreen.mainScreen().bounds.width
        static let shadowImageName: String = "jes_loading_shadow"
        static let iconSpacing: CGFloat = 40
        
        struct IconConstants {
            static let markedSpacing: CGFloat = 5
            static let shadowHeight: CGFloat = 6
        }
    }
    
    convenience init(withMarkedImageName name: String) {
        let iconSize: CGFloat = (JESRefreshIconConstants.SCREENWIDTH - JESRefreshIconConstants.iconSpacing * 2) / 4.0
        self.init(frame: CGRect(x: 0, y: 0, width: iconSize, height: iconSize))
        
        self.iconSize = iconSize
        self.markedImage = UIImage(named: name)!
        self.layoutIcon()
        
        /*
         self.starView = UIImageView(frame: CGRect(x: self.bounds.size.width / 2 - (self.bounds.size.width - 6) / 2, y: 0, width: self.bounds.size.width - 6, height: self.bounds.size.width - 6))
         self.starView?.contentMode = .ScaleToFill
         self.starView?.image = self.markedImage
         self.addSubview(self.starView!)
         */
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutIcon() {
        let size: CGFloat = self.iconSize - 4 * JESRefreshIconConstants.IconConstants.markedSpacing
        let offsetX: CGFloat = 2 * JESRefreshIconConstants.IconConstants.markedSpacing
        
        self.markedImageView = UIImageView(frame: CGRect(x: offsetX,
                y: 0,
            width: size,
           height: size))
        self.markedImageView?.image = self.markedImage
        self.markedImageView?.contentMode = .ScaleToFill
        self.addSubview(self.markedImageView!)
        
//        self.shadowImageView = UIImageView(frame: CGRect(x: offsetX, y: <#T##CGFloat#>, width: <#T##CGFloat#>, height: <#T##CGFloat#>))
    }

}
