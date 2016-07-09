//
//  NKNetworkLogin.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/10/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

/**
 返回的表明登陆结果
 
 - Success:                 登陆成功
 - ValidateCodeWrong:       验证码错误
 - UserNameOrPasswordWrong: 用户名或密码错误
 - NetWorkError:            网络错误
 */
enum LoginResult {
    case Success
    case ValidateCodeWrong
    case UserNameOrPasswordWrong
    case NetWorkError
}

/// 提供登录功能的网络库，使用时注意其生命周期
class NKNetworkLogin: NKNetworkBase, UIWebViewDelegate {
    
    typealias LoginResultBlock = (result: LoginResult)->Void
    
    var block:LoginResultBlock?
    var validateCode:String!
    
    private var userID:String!
    private var password:String!
    
    /**
     使用验证码登陆
     
     - parameter validateCode: 验证码
     - parameter view:         要将加密所使用的webView寄存在某一view上，任一在视图上的view均可
     - parameter block:        返回闭包
     */
    func loginWithValidateCode(validateCode: String, onView view:UIView, andBlock block:LoginResultBlock) {
     
        self.block = block
        self.validateCode = validateCode
        
        do {
            let accountInfo = try UserAgent().getData()
            userID = accountInfo.UserID
            password = accountInfo.Password
        } catch {
            
        }
        
        let webView = UIWebView()
        webView.delegate = self
        view.addSubview(webView)
        let filePath = NSBundle.mainBundle().pathForResource("RSA", ofType: "html")
        webView.loadRequest(NSURLRequest(URL: NSURL(fileURLWithPath: filePath!)))
    }
    
    /**
     使用ID、密码、验证码登陆
     
     - parameter ID:           学生号
     - parameter password:     密码
     - parameter validateCode: 验证码
     - parameter view:         要将加密所使用的webView寄存在某一view上，任一在视图上的view均可
     - parameter block:        返回闭包
     */
    func loginWithID(ID: String, password: String, validateCode: String, onView view: UIView, andBlock block:LoginResultBlock) {
        self.userID = ID
        self.password = password
        loginWithValidateCode(validateCode, onView: view, andBlock: block)
    }
    
    /**
     使用JavaScript加密密码
     
     - parameter webView: login时生成的webView
     */
    @objc internal func webViewDidFinishLoad(webView: UIWebView) {

        
        webView.stringByEvaluatingJavaScriptFromString("document.title = \"" + password + "\"")
        webView.stringByEvaluatingJavaScriptFromString("encryption()")
        let encryptedPassword = webView.stringByEvaluatingJavaScriptFromString("document.body.innerHTML")!
        
        let url:NSURL = NSURL(string: "http://222.30.32.10/stdloginAction.do")!
        let req:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        let data:NSString = NSString(format: "operation=&usercode_text=%@&userpwd_text=%@&checkcode_text=%@&submittype=%%C8%%B7+%%C8%%CF", userID, encryptedPassword, validateCode)
        req.HTTPBody = data.dataUsingEncoding(NSUTF8StringEncoding)
        req.HTTPMethod = "POST"
        
        Alamofire.request(req).responseString { (response: Response<String, NSError>) -> Void in
            guard let html = response.result.value as NSString? else {
                self.block?(result: LoginResult.NetWorkError)
                return
            }
            guard html.rangeOfString("用户不存在或密码错误").length == 0 else {
                self.block?(result: LoginResult.UserNameOrPasswordWrong)
                return
            }
            guard html.rangeOfString("请输入正确的验证码").length == 0 else {
                self.block?(result: LoginResult.ValidateCodeWrong)
                return
            }
            self.block?(result: LoginResult.Success)
        }
    }

}