//
//  NKNetworkValidateCodeGetter.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/14/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import Alamofire

/// 提供获取登陆验证码图片的网络库
class NKNetworkValidateCodeGetter: NKNetworkBase {
    
    typealias ValidateCodeResult = (data:NSData?, err:String?)->Void
    
    var block: ValidateCodeResult?
    
    /**
     获取验证码
     
     - parameter block: 返回闭包
     */
    func getValidateCodeWithBlock(block: ValidateCodeResult) {
        self.block = block
        Alamofire.request(.GET, "http://222.30.32.10/ValidateCode").responseData { (response) -> Void in
            if let data = response.result.value {
                self.block?(data: data, err: nil)
            } else {
                self.block?(data: nil, err: "网络错误")
            }
        }
    }
    
}