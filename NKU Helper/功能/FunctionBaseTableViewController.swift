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
        DispatchQueue.global().async { () -> Void in
            let loginResult = NKNetworkIsLogin.isLoggedin()
            DispatchQueue.main.async(execute: { () -> Void in
                SVProgressHUD.dismiss()
                switch loginResult {
                case .loggedin:
                    self.doWork()
                case .notLoggedin:
                    NotificationCenter.default.addObserver(self, selector: #selector(self.loginComplete), name: NSNotification.Name(rawValue: "loginComplete"), object: nil)
                    NotificationCenter.default.addObserver(self, selector: #selector(self.loginCancel), name: NSNotification.Name(rawValue: "loginCancel"), object: nil)
                    self.performSegue(withIdentifier: R.segue.gradeShowerTableViewController.login.identifier, sender: "GradeShowerTableViewController")
                case .unKnown:
                    self.present(ErrorHandler.alert(withError: ErrorHandler.NetworkError()), animated: true, completion: nil)
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SVProgressHUD.dismiss()
    }
    
    func doWork() {
        
    }
    
    func loginComplete() {
        
    }
    
    func loginCancel() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "loginCancel"), object: nil)
        let _ = self.navigationController?.popViewController(animated: true)
    }
}
