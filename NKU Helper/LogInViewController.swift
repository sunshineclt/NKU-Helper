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
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var imageLoadActivityIndicator: UIActivityIndicatorView! {
        didSet {
            imageLoadActivityIndicator.hidesWhenStopped = true
        }
    }
    
    var progressHud: MBProgressHUD!
    
    var loginer: NKNetworkLoginHandler?
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        loginButton.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshImage()
        validateCodeTextField.becomeFirstResponder()
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
    
    @IBAction func login(_ sender: AnyObject) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        loginer = NKNetworkLoginHandler(validateCode: validateCodeTextField.text ?? "")
        loginer?.login(onView: self.view, andBlock: { (result) in
            MBProgressHUD.hide(for: self.view, animated: true)
            switch result {
            case .success:
                self.dismiss(animated: true, completion: { () -> Void in
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "loginComplete"), object: self)
                })
            case .netWorkError:
                self.present(ErrorHandler.alert(withError: ErrorHandler.NetworkError()), animated: true, completion: nil)
            case .userNameOrPasswordWrong:
                self.present(ErrorHandler.alert(withError: ErrorHandler.UserNameOrPasswordWrong()), animated: true, completion: nil)
                self.refreshImage()
                self.validateCodeTextField.text = ""
            case .validateCodeWrong:
                self.present(ErrorHandler.alert(withError: ErrorHandler.ValidateCodeWrong(), andHandler: { (action) in
                    self.validateCodeTextField.becomeFirstResponder()
                }), animated: true, completion: nil)
                self.refreshImage()
                self.validateCodeTextField.text = ""
            }
        })
    }
    
    @IBAction func cancelButtonClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "loginCancel"), object: self)
    }
    
    @IBAction func validateCodeTextFieldDidEnd(_ sender: AnyObject) {
        login("FromReturnKey" as AnyObject)
    }
    
}
