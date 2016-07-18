//
//  FunctionBaseViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/18.
//  Copyright © 2016年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

protocol FunctionDelegate {
    func loginComplete()
    func doWork()
}

class FunctionBaseViewController: UIViewController, FunctionDelegate {

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
                    self.performSegueWithIdentifier(SegueIdentifier.Login, sender: "GradeShowerTableViewController")
                case .UnKnown:
                    self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
                }
            })
        }
    }
    
    func doWork() {
        
    }
    
    func loginComplete() {
        
    }
    
}
