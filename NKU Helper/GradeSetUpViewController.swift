//
//  GradeSetUpViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/2/14.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class GradeSetUpViewController: UIViewController, UIAlertViewDelegate, UITextFieldDelegate, UIWebViewDelegate {

    var gradeResult:NSArray = NSArray()
    var abcgpa:NSString!
    var progressHud:MBProgressHUD = MBProgressHUD()
    
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowGrade" {
            let destination:GradeShowerTableViewController = segue.destinationViewController as! GradeShowerTableViewController
            destination.gradeResult = self.gradeResult
            destination.ABCGPA = self.abcgpa as String
        }
        
    }
    
    @IBAction func validateCodeTextFieldDidEnd(sender: AnyObject) {
        login("FromReturnKey")
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webView.stringByEvaluatingJavaScriptFromString("document.title = " + password)
        webView.stringByEvaluatingJavaScriptFromString("encryption()")
        let encryptedPassword = webView.stringByEvaluatingJavaScriptFromString("document.body.innerHTML")!
        let loginer:LogIner = LogIner(userID: userID, password: encryptedPassword, validateCode: self.validateCodeTextField.text ?? "")
        loginer.login { (error) -> Void in
            self.progressHud.removeFromSuperview()
            if let _ = error {
                if error == "用户不存在或密码错误" {
                    self.validateCodeTextField.text = ""
                    let alert:UIAlertView = UIAlertView(title: "登录失败", message: "用户不存在或密码错误", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "好，重新设置用户名和密码")
                    alert.show()
                }
                else{
                    if error == "验证码错误" {
                        self.validateCodeTextField.text = ""
                        let alert:UIAlertView = UIAlertView(title: "登录失败", message: "验证码错误", delegate: self, cancelButtonTitle: "好，重新输入验证码")
                        alert.show()
                        self.refreshImage()
                    }
                    else {
                        let alertView:UIAlertView = UIAlertView(title: "网络错误", message: "没有网没法登陆", delegate: nil, cancelButtonTitle: "好，知道啦，现在就去搞点网")
                        alertView.show()
                    }
                }
            }
            else{
                let 😌gradeGetter:GradeGetter = GradeGetter()
                😌gradeGetter.getGrade() { (result, abcgpa, error) -> Void in
                    
                    if let _ = error {
                        let alert:UIAlertView = UIAlertView(title: "失败", message: error!, delegate: nil, cancelButtonTitle: "知道了！")
                        alert.show()
                        self.refreshImage()
                    }
                        
                    else {
                        self.gradeResult = result!
                        self.abcgpa = abcgpa!
                        self.performSegueWithIdentifier("ShowGrade", sender: nil)
                    }
                    
                }
                
                
            }
        }

    }
    
}

