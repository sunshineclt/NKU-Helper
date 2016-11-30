//
//  NKNetworkLoginHandler.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/10/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import Alamofire
import JavaScriptCore
import UIKit

/// 登陆结果
///
/// - success:                 登陆成功
/// - validateCodeWrong:       验证码错误
/// - userNameOrPasswordWrong: 用户名或密码错误
/// - netWorkError:            网络错误
enum LoginResult {
    case success
    case validateCodeWrong
    case userNameOrPasswordWrong
    case netWorkError
}

/**
 用于登录的网络库
 - important: 使用时请保有对handler实例的引用
 - important: 在闭包中使用unowned self以防止循环引用
 * * * * *
 
 last modified:
 - date: 2016.10.14
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
class NKNetworkLoginHandler: NKNetworkBase, UIWebViewDelegate {
    
    typealias LoginResultBlock = (LoginResult) -> Void
    
    var block: LoginResultBlock?
    private var userID: String
    private var password: String
    var validateCode: String
    
    /// 根据用户名、密码、验证码创建LoginHandler实例
    ///
    /// - parameter ID:           学生号
    /// - parameter password:     密码
    /// - parameter validateCode: 验证码
    ///
    /// - returns: LoginHandler实例
    init(ID: String, password: String, validateCode: String) {
        self.userID = ID
        self.password = password
        self.validateCode = validateCode
    }
    
    /// 根据验证码创建LoginHandler实例
    /// - note: 将自动使用存储中的用户名和密码信息
    ///
    /// - parameter validateCode: 验证码
    ///
    /// - returns: LoginHandler实例，若当前存储中没有用户名密码信息则为nil
    convenience init?(validateCode: String) {
        do {
            let accountInfo = try UserAgent.sharedInstance.getUserInfo()
            let userID = accountInfo.userID
            let password = accountInfo.password
            self.init(ID: userID, password: password, validateCode: validateCode)
        } catch {
            return nil
        }
    }
    
    /// 登陆
    ///
    /// - parameter view:  要将加密所使用的webView寄存在某一view上，任一在视图上的view均可
    /// - parameter block: 返回闭包
    func login(onView view: UIView, andBlock block: @escaping LoginResultBlock) {
        self.block = block
        let webView = UIWebView()
        webView.delegate = self
        view.addSubview(webView)
        let filePath = Bundle.main.path(forResource: "RSA", ofType: "html")
        webView.loadRequest(URLRequest(url: URL(fileURLWithPath: filePath!)))
    }
    
    /// 使用JavaScript加密密码
    ///
    /// - parameter webView: login时深沉的webView
    @objc internal func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.stringByEvaluatingJavaScript(from: "document.title = \"" + password + "\"")
        webView.stringByEvaluatingJavaScript(from: "encryption()")
        let encryptedPassword = webView.stringByEvaluatingJavaScript(from: "document.body.innerHTML")!

        doLogin(withEncryptedPassword: encryptedPassword)
    }

    /// 真正实施登陆，在密码加密好之后
    ///
    /// - parameter encryptedPassword: 加密过后的密码
    @objc private func doLogin(withEncryptedPassword encryptedPassword: String) {
        let url = URL(string: "http://222.30.49.10/stdloginAction.do")!
        var req = URLRequest(url: url)
        let data = NSString(format: "operation=&usercode_text=%@&userpwd_text=%@&checkcode_text=%@&submittype=%%C8%%B7+%%C8%%CF", userID, encryptedPassword, validateCode)
        req.httpBody = data.data(using: String.Encoding.utf8.rawValue)
        req.httpMethod = "POST"
        
        Alamofire.request(req).responseString { (response) -> Void in
            guard let html = response.result.value as NSString? else {
                self.block?(.netWorkError)
                return
            }
            guard html.range(of: "用户不存在或密码错误").length == 0 else {
                self.block?(.userNameOrPasswordWrong)
                return
            }
            guard html.range(of: "请输入正确的验证码").length == 0 else {
                self.block?(.validateCodeWrong)
                return
            }
            self.block?(.success)
        }
    }
    
}
