//
//  LogIner.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/3.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import Foundation
class LogIner:NSObject, NSURLConnectionDataDelegate{
    
    var userID:String
    var password:String
    var validateCode:String
    var receivedData:NSMutableData?
    var succeedOrNot:Bool
    var block:((error:String?)->Void)?
    
    init(userID:String, password:String, validateCode:String) {
        self.userID = userID
        self.password = password
        self.validateCode = validateCode
        self.receivedData = nil
        self.succeedOrNot = false
        self.block = nil
    }
    
    func login(block:((error:String?)->Void)) {
        self.block = block
        var url:NSURL = NSURL(string: "http://222.30.32.10/stdloginAction.do")!
        var req:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        var data:NSString = NSString(format: "operation=&usercode_text=%@&userpwd_text=%@&checkcode_text=%@&submittype=%%C8%%B7+%%C8%%CF", userID, password, validateCode)
        req.HTTPBody = data.dataUsingEncoding(NSUTF8StringEncoding)
        req.HTTPMethod = "POST"
        var connection:NSURLConnection? = NSURLConnection(request: req, delegate: self)
        receivedData = NSMutableData()
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.receivedData?.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        var encoding:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
        var html:NSString = NSString(data: self.receivedData!, encoding: encoding)!
        if html.rangeOfString("用户不存在或密码错误").length > 0 {
            block!(error: "用户不存在或密码错误")
        }
        else
            if html.rangeOfString("请输入正确的验证码").length > 0 {
              block!(error: "验证码错误")
        }
        else{
            print("Login Succeed!")
            succeedOrNot = true
            block!(error: nil)
        }

    }
    
}