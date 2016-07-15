//
//  NKNetworkBase.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/9/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
//

import Foundation
import Alamofire

/// 网络库的基类
class NKNetworkBase: NSObject {

    static var baseURL: String {
        #if DEBUG
            return "http://pikkacho.cn/api/v1/"
        #else
            return "http://115.28.141.95/api/v1/"
        #endif
    }
    
    class func getURLByAppendingBaseURLWithPath(path: String) -> NSURL {
        return NSURL(string: getURLStringByAppendingBaseURLWithPath(path))!
    }
    
    class func getURLStringByAppendingBaseURLWithPath(path: String) -> String {
        return baseURL + path
    }
    
}