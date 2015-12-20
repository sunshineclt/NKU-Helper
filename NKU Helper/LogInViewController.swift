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
    
    @IBOutlet var imageLoadActivityIndicator: UIActivityIndicatorView!
    
    var progressHud:MBProgressHUD!
    
    override func viewWillAppear(animated: Bool) {
        let view:UIView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 20))
        view.backgroundColor = UINavigationBar.appearance().barTintColor
        self.view.addSubview(view)
        imageLoadActivityIndicator.hidesWhenStopped = true
        refreshImage()
        validateCodeTextField.becomeFirstResponder()
    }
    
    func refreshImage() {
        
        let validateCodeGetter:imageGetter = imageGetter()
        imageLoadActivityIndicator.startAnimating()
        validateCodeGetter.getImageWithBlock { (data, err) -> Void in
            self.imageLoadActivityIndicator.stopAnimating()
            if let _ = err {
                print("Validate Loading Error!\n", terminator: "")
                let alert:UIAlertView = UIAlertView(title: "网络错误", message: "没有网没法获取验证码耶！", delegate: nil, cancelButtonTitle: "知道啦，现在就去搞点网")
                alert.show()
            }
            else {
                print("Validate Loading Succeed!\n", terminator: "")
                self.validateCodeImageView.image = UIImage(data: data!)
            }
        }
    }
    
    var userID:String {
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let accountInfo:NSDictionary = userDefaults.objectForKey("accountInfo") as! NSDictionary
        return accountInfo.objectForKey("userID") as! String
    }
    
    var password:String {
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let accountInfo:NSDictionary = userDefaults.objectForKey("accountInfo") as! NSDictionary
        return accountInfo.objectForKey("password") as! String
    }
    
    @IBAction func login(sender: AnyObject) {
        
        progressHud = MBProgressHUD(window: self.view.window)
        progressHud.mode = MBProgressHUDMode.Indeterminate
        self.view.addSubview(progressHud)
        progressHud.show(true)
        
        let webView = UIWebView()
        let filePath = NSBundle.mainBundle().pathForResource("RSA", ofType: "html")
        var htmlString:NSString?
        do {
            try htmlString = NSString(contentsOfFile: filePath!, encoding: NSUTF8StringEncoding)
            
        }
        catch {
            
        }
        webView.loadHTMLString(htmlString! as String, baseURL: nil)
        self.view.addSubview(webView)
        webView.delegate = self
        
    }
    
    @IBAction func cancelButtonClicked(sender: UIBarButtonItem) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func validateCodeTextFieldDidEnd(sender: AnyObject) {
        login("FromReturnKey")
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        webView.stringByEvaluatingJavaScriptFromString("document.title = \"" + password + "\"")
        webView.stringByEvaluatingJavaScriptFromString("encryption()")
        let encryptedPassword = webView.stringByEvaluatingJavaScriptFromString("document.body.innerHTML")!
        let loginer:LogIner = LogIner(userID: userID, password: encryptedPassword, validateCode: validateCodeTextField.text ?? "")
        loginer.login(errorHandler: { (error) -> Void in
            self.refreshImage()
            self.validateCodeTextField.text = ""
            self.progressHud.removeFromSuperview()
            let alert = UIAlertController(title: error.dynamicType.title, message: error.dynamicType.message, preferredStyle: .Alert)
            let action = UIAlertAction(title: error.dynamicType.cancelButtonTitle, style: .Cancel, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
            }, completion: {
                self.progressHud.removeFromSuperview()
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName("loginComplete", object: self)
                    
                })
        })

    }
}