//
//  NKNetworkBase.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/9/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import Alamofire

/**
 网络库的基类
 * * * * *
 
 last modified:
 - date: 2016.10.12
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
class NKNetworkBase: NSObject {

    /// 基础URL
    static var baseURL: String {
        #if DEBUG
            return "https://pikkacho.cn/api/v1/"
        #else
            return "https://pikkacho.cn/api/v1/"
        #endif
    }
    
    /// 根据path得到URL
    ///
    /// - parameter path: path
    ///
    /// - returns: path对应的URL
    class func getURLByAppendingBaseURL(withPath path: String) -> URL {
        return URL(string: getURLStringByAppendingBaseURL(withPath: path))!
    }
    
    /// 根据path得到URL String
    ///
    /// - parameter path: path
    ///
    /// - returns: path对应的URL String
    class func getURLStringByAppendingBaseURL(withPath path: String) -> String {
        return baseURL + path
    }
    
}
