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
    
    var receivedData:NSMutableData? = nil
    var name:String?
    var timeEnteringScohol:String?
    var departmentAdmitted:String?
    var majorAdmitted:String?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        creatWebViewToEncrypt()
    }
    
    func creatWebViewToEncrypt() {
        let webView = UIWebView()
        let filePath = NSBundle.mainBundle().pathForResource("RSA", ofType: "html")
        var htmlString:NSString?
        do {
            try htmlString = NSString(contentsOfFile: filePath!, encoding: NSUTF8StringEncoding)
            webView.loadHTMLString(htmlString! as String, baseURL: nil)
            self.view.addSubview(webView)
            webView.delegate = self
        }
        catch {
            print("RSA.html加载错误！")
        }

    }
    
    func getAllAccountInfo() {

        Alamofire.request(.GET, "http://222.30.32.10/studymanager/stdbaseinfo/queryAction.do").responseString(encoding: CFStringConvertEncodingToNSStringEncoding(0x0632)) { (response:Response<String, NSError>) -> Void in
            if let html = response.result.value {
                self.name = self.cutUpString(html, specificString1: ";名</td>", specificString2: "NavText", specificString3: "</td>")
                self.timeEnteringScohol = self.cutUpString(html, specificString1: ">入学时间</td>", specificString2: "NavText", specificString3: "</td>")
                self.departmentAdmitted = self.cutUpString(html, specificString1: ">录取院系<", specificString2: "span=", specificString3: "</td>")
                self.majorAdmitted = self.cutUpString(html, specificString1: ">录取专业<", specificString2: "span=", specificString3: "</td>")
                
                self.saveAccountInfo()
                self.navigationController?.popViewControllerAnimated(true)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
        }
        /*
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
*/
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
        
        let validateCodeGetter = imageGetter()
        imageLoadActivityIndicator.startAnimating()
        validateCodeGetter.getImageWithBlock { (data, err) -> Void in
            self.imageLoadActivityIndicator.stopAnimating()
            if let _ = err {
                let alert = UIAlertController(title: ErrorHandler.NetworkError.title, message: ErrorHandler.NetworkError.message, preferredStyle: .Alert)
                let cancel = UIAlertAction(title: ErrorHandler.NetworkError.cancelButtonTitle, style: .Cancel, handler: nil)
                alert.addAction(cancel)
                self.presentViewController(alert, animated: true, completion: nil)

            }
            else {
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
    /*
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
    */
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
    
        func encryptPassword() -> String {
            let password = passwordTextField.text ?? ""
            webView.stringByEvaluatingJavaScriptFromString("document.title = \"" + password + "\"")
            webView.stringByEvaluatingJavaScriptFromString("encryption()")
            return webView.stringByEvaluatingJavaScriptFromString("document.body.innerText")!
        }
        
        let content = encryptPassword()
        let loginer = LogIner(userID: userIDTextField.text ?? "", password: content, validateCode: validateCodeTextField.text ?? "")
        loginer.login { (error) -> Void in
            self.progressHud.removeFromSuperview()
            if let _ = error {
                if error == "用户不存在或密码错误" {
                    let alert = UIAlertController(title: ErrorHandler.UserNameOrPasswordWrong.title, message: ErrorHandler.UserNameOrPasswordWrong.message, preferredStyle: .Alert)
                    let cancel = UIAlertAction(title: ErrorHandler.UserNameOrPasswordWrong.cancelButtonTitle, style: .Cancel, handler: nil)
                    alert.addAction(cancel)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else {
                    if error == "验证码错误" {
                        let alert = UIAlertController(title: ErrorHandler.ValidateCodeWrong.title, message: ErrorHandler.ValidateCodeWrong.message, preferredStyle: .Alert)
                        let cancel = UIAlertAction(title: ErrorHandler.ValidateCodeWrong.cancelButtonTitle, style: .Cancel, handler: nil)
                        alert.addAction(cancel)
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        let alert = UIAlertController(title: ErrorHandler.NetworkError.title, message: ErrorHandler.NetworkError.message, preferredStyle: .Alert)
                        let cancel = UIAlertAction(title: ErrorHandler.NetworkError.cancelButtonTitle, style: .Cancel, handler: nil)
                        alert.addAction(cancel)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                self.refreshImage()
                self.validateCodeTextField.text = ""
            } else {
                self.getAllAccountInfo()
            }
        }
    }
    
}
