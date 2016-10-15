//
//  AccountLogInViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/3.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import Locksmith

class AccountLogInViewController: UIViewController, UIAlertViewDelegate, UITextFieldDelegate, UIWebViewDelegate {
    
    @IBOutlet var userIDTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var validateCodeTextField: UITextField!
    @IBOutlet var validateCodeImageView: UIImageView!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var imageLoadActivityIndicator: UIActivityIndicatorView! {didSet{imageLoadActivityIndicator.hidesWhenStopped = true}}
    
    var progressHud:MBProgressHUD!
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        loginButton.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userIDTextField.becomeFirstResponder()
    }

    var loginer: NKNetworkLoginHandler!
    lazy var userInfoGetter = NKNetworkUserInfoHandler()
    
    @IBAction func login(_ sender: AnyObject) {
        guard let userID = userIDTextField.text,
            let password = passwordTextField.text,
            let validateCode = validateCodeTextField.text else {
                present(ErrorHandler.alertWith(title: "信息错误", message: "用户名、密码、验证码不能为空", cancelButtonTitle: "好"), animated: true, completion: nil)
                return
        }
        MBProgressHUD.showAdded(to: self.view, animated: true)
        loginer = NKNetworkLoginHandler(ID: userID, password: password, validateCode: validateCode)
        loginer.login(onView: self.view) { (result) in
            MBProgressHUD.hide(for: self.view, animated: true)
            switch result {
            case .success:
                NKNetworkUserInfoHandler.getAllAccountInfo(withBlock: { (result) in
                    switch result {
                    case .success(let name, let timeEnteringSchool, let departmentAdmitted, let majorAdmitted):
                        let saveSuccess = self.saveAccountInfo(name: name, timeEnteringSchool: timeEnteringSchool, departmentAdmitted: departmentAdmitted, majorAdmitted: majorAdmitted)
                        NKNetworkInfoHandler.registerUser()
                        if saveSuccess {
                            let _ = self.navigationController?.popViewController(animated: true)
                            self.dismiss(animated: true, completion: nil)
                        }
                        else {
                            self.present(ErrorHandler.alertWith(title: "在钥匙串中存储密码失败", message: "请重试或通知开发者", cancelButtonTitle: "好"), animated: true, completion: nil)
                        }
                    case .networkError:
                        self.present(ErrorHandler.alert(withError: ErrorHandler.NetworkError()), animated: true, completion: nil)
                    case .analyzeError:
                        self.refreshImage()
                        self.present(ErrorHandler.alert(withError: ErrorHandler.HtmlAnalyseFail()), animated: true, completion: nil)
                    }
                })
            case .userNameOrPasswordWrong:
                self.present(ErrorHandler.alert(withError: ErrorHandler.UserNameOrPasswordWrong(), andHandler: { (action) in
                    self.userIDTextField.becomeFirstResponder()
                }), animated: true, completion: nil)
            case .validateCodeWrong:
                self.refreshImage()
                self.validateCodeTextField.text = ""
                self.present(ErrorHandler.alert(withError: ErrorHandler.ValidateCodeWrong(), andHandler: { ( action) in
                    self.validateCodeTextField.becomeFirstResponder()
                }), animated: true, completion: nil)
            case .netWorkError:
                self.present(ErrorHandler.alert(withError: ErrorHandler.NetworkError()), animated: true, completion: nil)
            }
        }
    }
    
    func saveAccountInfo(name:String, timeEnteringSchool:String, departmentAdmitted:String, majorAdmitted:String) -> Bool {
        let user = User(userID: userIDTextField.text!, password: passwordTextField.text!, name: name, timeEnteringSchool: timeEnteringSchool, departmentAdmitted: departmentAdmitted, majorAdmitted: majorAdmitted)
        do {
            try UserAgent.sharedInstance.save(data: user)
        } catch {
            return false
        }
        return true
    }
    
    func refreshImage() {
        imageLoadActivityIndicator.startAnimating()
        NKNetworkValidateCodeGetter.getValidateCode { (data, err) in
            self.imageLoadActivityIndicator.stopAnimating()
            guard err == nil else {
                self.present(ErrorHandler.alert(withError: ErrorHandler.NetworkError()), animated: true, completion: nil)
                return
            }
            self.validateCodeImageView.image = UIImage(data: data!)
        }
    }
    
    @IBAction func nameTextFieldDidEnd(_ sender: AnyObject) {
        passwordTextField.becomeFirstResponder()
    }

    @IBAction func passwordTextFieldDidEnd(_ sender: AnyObject) {
        validateCodeTextField.becomeFirstResponder()
    }
    
    @IBAction func validateCodeTextFieldDidEnd(_ sender: AnyObject) {
        let _ = sender.resignFirstResponder()
        login("FromReturnKey" as AnyObject)
    }
    
}
