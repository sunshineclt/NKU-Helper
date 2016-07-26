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
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var imageLoadActivityIndicator: UIActivityIndicatorView! {didSet{imageLoadActivityIndicator.hidesWhenStopped = true}}
    
    var progressHud:MBProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 5
    }
    
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
                        let saveSuccess = self.saveAccountInfo(name: name, timeEnteringSchool: timeEnteringSchool, departmentAdmitted: departmentAdmitted, majorAdmitted: majorAdmitted)
                        if saveSuccess {
                            self.navigationController?.popViewControllerAnimated(true)
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                        else {
                            self.presentViewController(ErrorHandler.alertWithAlertTitle("在钥匙串中存储密码失败", message: "请重试或通知开发者", cancelButtonTitle: "好"), animated: true, completion: nil)
                        }
                    case .NetworkError:
                        self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
                    case .AnalyzeError:
                        self.presentViewController(ErrorHandler.alert(ErrorHandler.HtmlAnalyseFail()), animated: true, completion: nil)
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
    
    func saveAccountInfo(name name:String, timeEnteringSchool:String, departmentAdmitted:String, majorAdmitted:String) -> Bool {
        let userAgent = UserAgent.sharedInstance
        let userDetailInfoAgent = UserDetailInfoAgent.sharedInstance
        let user = User(userID: userIDTextField.text!, password: passwordTextField.text!, name: name, timeEnteringSchool: timeEnteringSchool, departmentAdmitted: departmentAdmitted, majorAdmitted: majorAdmitted)
        userDetailInfoAgent.saveData(user)
        do {
            try userAgent.saveData(user)
        } catch {
            return false
        }
        return true
    }
    
    func refreshImage() {
        imageLoadActivityIndicator.startAnimating()
        let validateCodeGetter = NKNetworkValidateCodeGetter()
        validateCodeGetter.getValidateCodeWithBlock { (data, err) -> Void in
            self.imageLoadActivityIndicator.stopAnimating()
            guard err == nil else {
                self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
                return
            }
            self.validateCodeImageView.image = UIImage(data: data!)
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
