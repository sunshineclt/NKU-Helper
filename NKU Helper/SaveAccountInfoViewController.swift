//
//  SaveAccountInfoViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/3.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class SaveAccountInfoViewController: UIViewController, UIAlertViewDelegate, NSURLConnectionDataDelegate {
    
    @IBOutlet var userIDTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var validateCodeTextField: UITextField!
    @IBOutlet var validateCodeImageView: UIImageView!
    
    @IBOutlet var imageLoadActivityIndicator: UIActivityIndicatorView!
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
        
        var userID:String = userIDTextField.text
        var password:String = passwordTextField.text
        
        var loginer:LogIner = LogIner(userID: userID, password: password, validateCode: validateCodeTextField.text)
        loginer.login { (error) -> Void in
            if let temp = error {
                if error == "用户不存在或密码错误" {
                    var alert:UIAlertView = UIAlertView(title: "登录失败", message: "用户不存在或密码错误", delegate: self, cancelButtonTitle: "好，重新设置用户名和密码")
                    alert.show()
                }
                else{
                    var alert:UIAlertView = UIAlertView(title: "登录失败", message: "验证码错误", delegate: self, cancelButtonTitle: "好，重新输入验证码")
                    alert.show()
                }
                self.refreshImage()

            }
            else{
                print("Login Succeed!")
                self.dismissViewControllerAnimated(true, completion: nil)
                self.getAllAccountInfo()
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
        
    }
    
    func getAllAccountInfo() {
        
        var url:NSURL = NSURL(string: "http://222.30.32.10/studymanager/stdbaseinfo/queryAction.do")!
        var req:NSURLRequest = NSURLRequest(URL: url)
        var connection:NSURLConnection? = NSURLConnection(request: req, delegate: self)
        if let temp = connection {
            receivedData = NSMutableData()
        }
        else {
            var alertView:UIAlertView = UIAlertView(title: "网络错误", message: "木有网无法查证身份信息", delegate: nil, cancelButtonTitle: "好，知道了，这就去弄点网")
            alertView.show()
        }
    }
    
    func saveAccountInfo() {
        
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var accountInfo:NSMutableDictionary = NSMutableDictionary()
        accountInfo.setObject(userIDTextField.text, forKey: "userID")
        accountInfo.setObject(passwordTextField.text, forKey: "password")
        accountInfo.setObject(name!, forKey: "name")
        accountInfo.setObject(timeEnteringScohol!, forKey: "timeEnteringSchool")
        accountInfo.setObject(departmentAdmitted!, forKey: "departmentAdmitted")
        accountInfo.setObject(majorAdmitted!, forKey: "majorAdmitted")
        userDefaults.removeObjectForKey("accountInfo")
        userDefaults.setObject(accountInfo, forKey: "accountInfo")
        userDefaults.synchronize()

    }
    
    func refreshImage() {
        
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
    
    func cutUpString(originalString:NSString, specificString1:String, specificString2:String, specificString3:String) -> String {
        
        var location1 = originalString.rangeOfString(specificString1)
        var tempString1 = originalString.substringWithRange(NSMakeRange(location1.location+7, location1.length+70))
        var tempString2 = NSString(string: tempString1)
        var location2 = tempString2.rangeOfString(specificString2)
        var location3 = tempString2.rangeOfString(specificString3)
        var result = tempString2.substringWithRange(NSMakeRange(location2.location+9, location3.location-location2.location-9))
        
        return result
        
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        receivedData?.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        var encoding:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
        var html:NSString = NSString(data: self.receivedData!, encoding: encoding)!
        
        name = cutUpString(html, specificString1: ";名</td>", specificString2: "NavText", specificString3: "</td>")
        timeEnteringScohol = cutUpString(html, specificString1: ">入学时间</td>", specificString2: "NavText", specificString3: "</td>")
        departmentAdmitted = cutUpString(html, specificString1: ">录取院系<", specificString2: "span=", specificString3: "</td>")
        majorAdmitted = cutUpString(html, specificString1: ">录取专业<", specificString2: "span=", specificString3: "</td>")
        
        self.saveAccountInfo()

    }
    
}
