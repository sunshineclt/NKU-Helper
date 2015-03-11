//
//  GradeSetUpViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/2/14.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class GradeSetUpViewController: UIViewController, UIAlertViewDelegate {

    var gradeResult:NSArray = NSArray()
    
    @IBOutlet var validateCodeImageView: UIImageView!
    @IBOutlet var validateCodeTextField: UITextField!
    
    @IBOutlet var imageLoadActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        imageLoadActivityIndicator.hidesWhenStopped = true

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(animated: Bool) {
        refreshImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refreshImage() {
        
        validateCodeTextField.becomeFirstResponder()
        var validateCodeGetter:imageGetter = imageGetter()
        imageLoadActivityIndicator.startAnimating()
        validateCodeGetter.getImageWithBlock { (data, err) -> Void in
            self.imageLoadActivityIndicator.stopAnimating()
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
                var 😌gradeGetter:GradeGetter = GradeGetter()
                😌gradeGetter.getGrade() { (result, error) -> Void in
                    
                    if let temp = error {
                        var alert:UIAlertView = UIAlertView(title: "失败", message: error!, delegate: nil, cancelButtonTitle: "知道了！")
                        alert.show()
                        self.refreshImage()
                    }
                        
                    else {
                        self.gradeResult = result!
                        self.performSegueWithIdentifier("ShowGrade", sender: nil)
                    }
                    
                }

                
            }
        }

        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowGrade" {
            var destination:GradeShowerTableViewController = segue.destinationViewController as GradeShowerTableViewController
            destination.gradeResult = self.gradeResult
        }
        
    }
    
 /*   func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.buttonTitleAtIndex(buttonIndex) == "好，重新设置用户名和密码" {
            self.performSegueWithIdentifier("editAccountInfo", sender: nil)
        }
    }
   */ 
}

