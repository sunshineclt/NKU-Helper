//
//  LogInViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/3.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UIAlertViewDelegate, UIWebViewDelegate {
    
    @IBOutlet var validateCodeTextField: UITextField!
    @IBOutlet var validateCodeImageView: UIImageView!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var imageLoadActivityIndicator: UIActivityIndicatorView!
    
    var progressHud:MBProgressHUD!
    
    let loginer = NKNetworkLogin()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        imageLoadActivityIndicator.hidesWhenStopped = true
        refreshImage()
        validateCodeTextField.becomeFirstResponder()
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
    
    @IBAction func login(sender: AnyObject) {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        loginer.loginWithValidateCode(validateCodeTextField.text ?? "", onView: self.view) { (result) -> Void in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            switch result {
            case .Success:
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName("loginComplete", object: self)
                })
            case .NetWorkError:
                self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
            case .UserNameOrPasswordWrong:
                self.presentViewController(ErrorHandler.alert(ErrorHandler.UserNameOrPasswordWrong()), animated: true, completion: nil)
                self.refreshImage()
                self.validateCodeTextField.text = ""
                self.validateCodeTextField.becomeFirstResponder()
            case .ValidateCodeWrong:
                self.presentViewController(ErrorHandler.alert(ErrorHandler.ValidateCodeWrong()), animated: true, completion: nil)
                self.refreshImage()
                self.validateCodeTextField.text = ""
                self.validateCodeTextField.becomeFirstResponder()
            }
        }
    }
    
    @IBAction func cancelButtonClicked(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func validateCodeTextFieldDidEnd(sender: AnyObject) {
        login("FromReturnKey")
    }
    
}