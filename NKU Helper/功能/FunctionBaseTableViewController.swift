//
//  FunctionBaseTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/18.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import UIKit

class FunctionBaseTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            let loginResult = NKNetworkIsLogin.isLoggedin()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                SVProgressHUD.dismiss()
                switch loginResult {
                case .Loggedin:
                    self.doWork()
                case .NotLoggedin:
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.loginComplete), name: "loginComplete", object: nil)
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.loginCancel), name: "loginCancel", object: nil)
                    self.performSegueWithIdentifier(R.segue.gradeShowerTableViewController.login.identifier, sender: "GradeShowerTableViewController")
                case .UnKnown:
                    self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
                }
            })
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        SVProgressHUD.dismiss()
    }
    
    func doWork() {
        
    }
    
    func loginComplete() {
        
    }
    
    func loginCancel() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "loginCancel", object: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
}
