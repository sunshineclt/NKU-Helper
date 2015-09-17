//
//  SaveAccountInfoViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/3.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit
import WebKit

class SaveAccountInfoViewController: UIViewController, UIAlertViewDelegate, NSURLConnectionDataDelegate, UITextFieldDelegate, UIWebViewDelegate {
    
    @IBOutlet var userIDTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var validateCodeTextField: UITextField!
    @IBOutlet var validateCodeImageView: UIImageView!
    
    @IBOutlet var imageLoadActivityIndicator: UIActivityIndicatorView!
    
    var progressHud:MBProgressHUD!
    
    var receivedData:NSMutableData? = nil
    var name:String?
    var timeEnteringScohol:String?
    var departmentAdmitted:String?
    var majorAdmitted:String?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        imageLoadActivityIndicator.hidesWhenStopped = true
        refreshImage()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        userIDTextField.becomeFirstResponder()
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
    
    func getAllAccountInfo() {
        
        let url:NSURL = NSURL(string: "http://222.30.32.10/studymanager/stdbaseinfo/queryAction.do")!
        let req:NSURLRequest = NSURLRequest(URL: url)
        let connection:NSURLConnection? = NSURLConnection(request: req, delegate: self)
        if let _ = connection {
            receivedData = NSMutableData()
        }
        else {
            let alertView:UIAlertView = UIAlertView(title: "网络错误", message: "木有网无法查证身份信息", delegate: nil, cancelButtonTitle: "好，知道了，这就去弄点网")
            alertView.show()
        }
    }
    
    func saveAccountInfo() {
        
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let accountInfo:NSMutableDictionary = NSMutableDictionary()
        accountInfo.setObject(userIDTextField.text!, forKey: "userID")
        accountInfo.setObject(passwordTextField.text!, forKey: "password")
        accountInfo.setObject(name!, forKey: "name")
        accountInfo.setObject(timeEnteringScohol!, forKey: "timeEnteringSchool")
        accountInfo.setObject(departmentAdmitted!, forKey: "departmentAdmitted")
        accountInfo.setObject(majorAdmitted!, forKey: "majorAdmitted")
        userDefaults.removeObjectForKey("accountInfo")
        userDefaults.removeObjectForKey("courses")
        userDefaults.removeObjectForKey("courseStatus")
        userDefaults.setObject(accountInfo, forKey: "accountInfo")
        userDefaults.synchronize()

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
    
    func cutUpString(originalString:NSString, specificString1:String, specificString2:String, specificString3:String) -> String {
        
        let location1 = originalString.rangeOfString(specificString1)
        let tempString1 = originalString.substringWithRange(NSMakeRange(location1.location+7, location1.length+70))
        let tempString2 = NSString(string: tempString1)
        let location2 = tempString2.rangeOfString(specificString2)
        let location3 = tempString2.rangeOfString(specificString3)
        let result = tempString2.substringWithRange(NSMakeRange(location2.location+9, location3.location-location2.location-9))
        
        return result
        
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        receivedData?.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        let encoding:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
        let html:NSString = NSString(data: self.receivedData!, encoding: encoding)!
        
        name = cutUpString(html, specificString1: ";名</td>", specificString2: "NavText", specificString3: "</td>")
        timeEnteringScohol = cutUpString(html, specificString1: ">入学时间</td>", specificString2: "NavText", specificString3: "</td>")
        departmentAdmitted = cutUpString(html, specificString1: ">录取院系<", specificString2: "span=", specificString3: "</td>")
        majorAdmitted = cutUpString(html, specificString1: ">录取专业<", specificString2: "span=", specificString3: "</td>")
        
        self.saveAccountInfo()
        self.navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
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
    
    func webViewDidFinishLoad(webView: UIWebView) {
        passwordTextField.text = passwordTextField.text ?? ""
        let userPassword = passwordTextField.text ?? ""
        webView.stringByEvaluatingJavaScriptFromString("document.title = " + userPassword)
        webView.stringByEvaluatingJavaScriptFromString("encryption()")
        let content = webView.stringByEvaluatingJavaScriptFromString("document.body.innerHTML")!
        let loginer:LogIner = LogIner(userID: userIDTextField.text ?? "", password: content, validateCode: validateCodeTextField.text ?? "")
        loginer.login { (error) -> Void in
            self.progressHud.removeFromSuperview()
            if let _ = error {
                if error == "用户不存在或密码错误" {
                    self.validateCodeTextField.text = ""
                    let alert:UIAlertView = UIAlertView(title: "登录失败", message: "用户不存在或密码错误", delegate: self, cancelButtonTitle: "好，重新设置用户名和密码")
                    alert.show()
                }
                else{
                    self.validateCodeTextField.text = ""
                    let alert:UIAlertView = UIAlertView(title: "登录失败", message: "验证码错误", delegate: self, cancelButtonTitle: "好，重新输入验证码")
                    alert.show()
                }
                self.refreshImage()
                
            }
            else{
                print("Login Succeed!", terminator: "")
                self.getAllAccountInfo()
                
            }
        }

    }
    
}
