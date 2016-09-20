//
//  ViewController.swift
//  JESPullToRefresh
//
//  Created by Jerry on 8/16/16.
//  Copyright © 2016 jerryshi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: JESPullToRefreshTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showPreLoading()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.dismissPreLoading()
        })
        
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.separatorColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 231/255.0, alpha: 1.0)
        tableView.backgroundColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 251/255.0, alpha: 1.0)
        
        tableView.refresh { 
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self.tableView.jes_stopLoading()
            })
        }
        
    }

    deinit {
        tableView.jes_removePullToRefresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

