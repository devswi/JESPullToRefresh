//
//  ViewController.swift
//  JESPullToRefresh
//
//  Created by Jerry on 8/16/16.
//  Copyright © 2016 jerryshi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.separatorColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 231/255.0, alpha: 1.0)
        tableView.backgroundColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 251/255.0, alpha: 1.0)
        
        let loadingView = JESPullToRefreshLoadingViewCircle(fillColor: UIColor(red: 224/255.0, green: 231/255.0, blue: 235/255.0, alpha: 1.0))
        loadingView.tintColor = UIColor.whiteColor()
        tableView.jes_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                self?.tableView.jes_stopLoading()
            })
        }, loadingView: loadingView, logoImage: "refresh_logo")
        tableView.jes_setPullToRefreshFillColor(UIColor(red: 224/255.0, green: 231/255.0, blue: 235/255.0, alpha: 1.0))
        tableView.jes_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
        
    }

    deinit {
        tableView.jes_removePullToRefresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

