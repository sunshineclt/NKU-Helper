//
//  NKNetworkIsLogin.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/9/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation

/**
 代表当前登录状态
 
 - Loggedin:    已登陆
 - NotLoggedin: 未登录
 - UnKnown:     网络错误等原因未知
 */
enum NKNetworkLoginStatus {
    case Loggedin
    case NotLoggedin
    case UnKnown
}

/// 提供判断当前登录状态的网络库，注意：此网络库为同步执行，不能在主线程中执行，需加加载动画
class NKNetworkIsLogin: NKNetworkBase {
    
    /**
     判断是否登陆
     
     - returns: 登录状态
     */
    class func isLoggedin() -> NKNetworkLoginStatus {
        let receivedData = NSData(contentsOfURL: NSURL(string: "http://222.30.32.10/xsxk/selectedAction.do?operation=kebiao")!)
        guard let _ = receivedData else {
            return .UnKnown
        }
        let encoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
        let html = NSString(data: receivedData!, encoding: encoding)!
        if html.rangeOfString("星期一").length > 0 {
            return .Loggedin
        }
        else{
            return .NotLoggedin
        }
        
    }
    
}