//
//  NKNetworkFetchInfo.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/15.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/// 提供获取一系列信息功能的网络库
class NKNetworkFetchInfo: NKNetworkBase {
    
    static var nowWeek: Int!
    static var isVocation: Bool!
    
    /**
     获取当前周数（也有可能是假期）（带缓存）
     
     - parameter completionHandler: 返回闭包
     */
    class func fetchNowWeek(completionHandler: (nowWeek: Int?, isVocation: Bool?) -> Void) {
        
        if (nowWeek != nil) && (isVocation != nil) {
            completionHandler(nowWeek: nowWeek, isVocation: isVocation)
            return
        }
        Alamofire.request(.GET, NKNetworkBase.getURLStringByAppendingBaseURLWithPath("info/week")).responseJSON { (response) in
            switch response.result {
            case .Success(let value):
                let json = JSON(value)
                guard json["msg"].stringValue == "OK" else {
                    completionHandler(nowWeek: nil, isVocation: nil)
                    return
                }
                nowWeek = json["data"]["nowWeek"].intValue
                isVocation = json["data"]["isVocation"].boolValue
                
                completionHandler(nowWeek: nowWeek, isVocation: isVocation)
            case .Failure( _):
                completionHandler(nowWeek: nil, isVocation: nil)
            }
        }
        
    }
    
}