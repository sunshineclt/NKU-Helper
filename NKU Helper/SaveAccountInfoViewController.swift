//
//  SaveAccountInfoViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/3.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class SaveAccountInfoViewController: UIViewController, UIAlertViewDelegate {
    
    @IBOutlet var userIDTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        userIDTextField.becomeFirstResponder()
    }
    
    @IBAction func save(sender: AnyObject) {
        
        var alert:UIAlertView = UIAlertView(title: "注意", message: "NKU Helper在这里无法验证您信息的准确性，只有在查询课程表等输入验证码后才能验证，请认真核对", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "好")
        alert.show()
    }
    
    func saveAccountInfo() {
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var accountInfo:NSMutableDictionary = NSMutableDictionary()
        accountInfo.setObject(userIDTextField.text, forKey: "userID")
        accountInfo.setObject(passwordTextField.text, forKey: "password")
        userDefaults.removeObjectForKey("accountInfo")
        userDefaults.setObject(accountInfo, forKey: "accountInfo")
        userDefaults.synchronize()

    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.buttonTitleAtIndex(buttonIndex) == "好" {
            saveAccountInfo()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
}
