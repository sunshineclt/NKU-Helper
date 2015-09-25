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
    var block:((error:String?)->Void)!
    
    init(userID:String, password:String, validateCode:String) {
        self.userID = userID
        self.password = password
        self.validateCode = validateCode
        self.receivedData = nil
        self.block = nil
    }
    
    func login(block:((error:String?)->Void)) {
        self.block = block
        let url:NSURL = NSURL(string: "http://222.30.32.10/stdloginAction.do")!
        let req:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        let data:NSString = NSString(format: "operation=&usercode_text=%@&userpwd_text=%@&checkcode_text=%@&submittype=%%C8%%B7+%%C8%%CF", userID, password, validateCode)
        req.HTTPBody = data.dataUsingEncoding(NSUTF8StringEncoding)
        req.HTTPMethod = "POST"
        receivedData = NSMutableData()
        let connection = NSURLConnection(request: req, delegate: self)
        connection?.start()
        if let _ = connection {
        }
        else {
            block(error: "没有网")
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.receivedData?.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        let encoding:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
        let html:NSString = NSString(data: self.receivedData!, encoding: encoding)!
        if html.rangeOfString("用户不存在或密码错误").length > 0 {
            block!(error: "用户不存在或密码错误")
        }
        else
            if html.rangeOfString("请输入正确的验证码").length > 0 {
              block!(error: "验证码错误")
        }
        else{
            print("Login Succeed!", terminator: "")
            block(error: nil)
        }

    }
    
}