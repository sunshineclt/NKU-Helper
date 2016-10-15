//
//  NKNetworkIsLogin.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/9/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation

/// 代表当前登录状态
///
/// - loggedin:    已登录
/// - notLoggedin: 未登录
/// - unKnown:     网络错误等原因未知登录状态
enum NKNetworkLoginStatus {
    case loggedin
    case notLoggedin
    case unKnown
}

/**
 判断当前登录状态的网络库
 - important: 此网络库为同步执行，不能在主线程中执行，需加加载动画
 * * * * *
 
 last modified:
 - date: 2016.10.14
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
class NKNetworkIsLogin: NKNetworkBase {
    
    /// 判断是否登陆
    ///
    /// - returns: 登录状态
    class func isLoggedin() -> NKNetworkLoginStatus {
        do {
            let html = try NSString(contentsOf: URL(string: "http://222.30.32.10/xsxk/selectedAction.do?operation=kebiao")!, encoding: CFStringConvertEncodingToNSStringEncoding(0x0632))
            if html.range(of: "星期一").length > 0 {
                return .loggedin
            }
            else{
                return .notLoggedin
            }
        }
        catch {
            return .unKnown
        }
    }
    
}
