//
//  SaveAccountInfoViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/3.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

class SaveAccountInfoViewController: UIViewController, UIAlertViewDelegate, UITextFieldDelegate, UIWebViewDelegate {
    
    @IBOutlet var userIDTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var validateCodeTextField: UITextField!
    @IBOutlet var validateCodeImageView: UIImageView!
    
    @IBOutlet var imageLoadActivityIndicator: UIActivityIndicatorView! {didSet{imageLoadActivityIndicator.hidesWhenStopped = true}}
    
    var progressHud:MBProgressHUD!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshImage()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        userIDTextField.becomeFirstResponder()
    }

    lazy var loginer = NKNetworkLogin()
    lazy var userInfoGetter = NKNetworkFetchUserInfo()
    
    @IBAction func login(sender: AnyObject) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loginer.loginWithID(userIDTextField.text ?? "", password: passwordTextField.text ?? "", validateCode: validateCodeTextField.text ?? "", onView: self.view) { (result) -> Void in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            switch result {
            case .Success:
                self.userInfoGetter.getAllAccountInfoWithBlock({ (result) -> Void in
                    switch result {
                    case .Success(let name, let timeEnteringSchool, let departmentAdmitted, let majorAdmitted):
                        self.saveAccountInfo(name: name, timeEnteringSchool: timeEnteringSchool, departmentAdmitted: departmentAdmitted, majorAdmitted: majorAdmitted)
                        self.navigationController?.popViewControllerAnimated(true)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    case .NetworkError:
                        self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
                    }
                })
            case .UserNameOrPasswordWrong:
                self.presentViewController(ErrorHandler.alert(ErrorHandler.UserNameOrPasswordWrong()), animated: true, completion: nil)
            case .ValidateCodeWrong:
                self.refreshImage()
                self.validateCodeTextField.text = ""
                self.presentViewController(ErrorHandler.alert(ErrorHandler.ValidateCodeWrong()), animated: true, completion: nil)
            case .NetWorkError:
                self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
            }
        }
    }
    
    func saveAccountInfo(name name:String, timeEnteringSchool:String, departmentAdmitted:String, majorAdmitted:String) {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let accountInfo:NSMutableDictionary = NSMutableDictionary()
        accountInfo.setObject(userIDTextField.text!, forKey: "userID")
        accountInfo.setObject(passwordTextField.text!, forKey: "password")
        accountInfo.setObject(name, forKey: "name")
        accountInfo.setObject(timeEnteringSchool, forKey: "timeEnteringSchool")
        accountInfo.setObject(departmentAdmitted, forKey: "departmentAdmitted")
        accountInfo.setObject(majorAdmitted, forKey: "majorAdmitted")
        userDefaults.removeObjectForKey("accountInfo")
        userDefaults.removeObjectForKey("courses")
        userDefaults.removeObjectForKey("courseStatus")
        userDefaults.setObject(accountInfo, forKey: "accountInfo")
        userDefaults.synchronize()
    }
    
    func refreshImage() {
        imageLoadActivityIndicator.startAnimating()
        let validateCodeGetter = NKNetworkValidateCodeGetter()
        validateCodeGetter.getValidateCodeWithBlock { (data, err) -> Void in
            self.imageLoadActivityIndicator.stopAnimating()
            if let _ = err {
                self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
            }
            else {
                self.validateCodeImageView.image = UIImage(data: data!)
            }
        }
    }
        
    @IBAction func nameTextFieldDidEnd(sender: AnyObject) {
        passwordTextField.becomeFirstResponder()
    }

    @IBAction func passwordTextFieldDidEnd(sender: AnyObject) {
        validateCodeTextField.becomeFirstResponder()
    }
    
    @IBAction func validateCodeTextFieldDidEnd(sender: AnyObject) {
        sender.resignFirstResponder()
        login("FromReturnKey")
    }
    
}
