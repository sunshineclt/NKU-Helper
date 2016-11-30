//
//  NKNetworkValidateCodeGetter.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/14/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import Alamofire

/**
 获取登陆验证码图片的网络库
 * * * * *
 
 last modified:
 - date: 2016.10.14
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
class NKNetworkValidateCodeGetter: NKNetworkBase {
    
    typealias ValidateCodeResult = (_ data:Data?, _ err:String?)->Void
    
    /// 获取验证码
    ///
    /// - parameter block: 返回闭包
    class func getValidateCode(withBlock block: @escaping ValidateCodeResult) {
        Alamofire.request("http://222.30.49.10/ValidateCode").responseData { (response) -> Void in
            if let data = response.result.value {
                block(data, nil)
            } else {
                block(nil, "网络错误")
            }
        }
    }
    
}
