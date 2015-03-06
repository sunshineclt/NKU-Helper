//
//  LogInViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/3.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UIAlertViewDelegate {
    
    @IBOutlet var validateCodeTextField: UITextField!
    @IBOutlet var validateCodeImageView: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        var view:UIView = UIView(frame: CGRectMake(0, 0, 320, 20))
        view.backgroundColor = UINavigationBar.appearance().barTintColor
        self.view.addSubview(view)
        
        refreshImage()
        validateCodeTextField.becomeFirstResponder()
    }
    
    func refreshImage() {
        
        var validateCodeGetter:imageGetter = imageGetter()
        validateCodeGetter.getImageWithBlock { (data, err) -> Void in
            if let temp = err {
                print("Validate Loading Error!\n")
            }
            else {
                print("Validate Loading Succeed!\n")
                self.validateCodeImageView.image = UIImage(data: data!)
            }
        }
    }
    
    @IBAction func login(sender: AnyObject) {
        
        
        var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var accountInfo:NSDictionary = userDefaults.objectForKey("accountInfo") as NSDictionary
        var userID:String = accountInfo.objectForKey("userID") as String
        var password:String = accountInfo.objectForKey("password") as String
        
        var loginer:LogIner = LogIner(userID: userID, password: password, validateCode: validateCodeTextField.text)
        loginer.login { (error) -> Void in
            if let temp = error {
                if error == "用户不存在或密码错误" {
                    var alert:UIAlertView = UIAlertView(title: "登录失败", message: "用户不存在或密码错误", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "好，重新设置用户名和密码")
                    alert.show()
                }
                else{
                    var alert:UIAlertView = UIAlertView(title: "登录失败", message: "验证码错误", delegate: self, cancelButtonTitle: "好，重新输入验证码")
                    alert.show()
                    self.refreshImage()
                }
            }
            else{
                print("Login Succeed!")
                self.dismissViewControllerAnimated(true, completion: nil)
                
            }
        }
    }
    
}