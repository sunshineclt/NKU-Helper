//
//  NKNetworkFetchInfo.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/15.
//  Copyright © 2016年 &#38472;&#20048;&#22825;. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/// 提供获取一系列信息功能的网络库
class NKNetworkFetchInfo: NKNetworkBase {
    
    class func fetchNowWeek(completionHandler: (nowWeek: Int?) -> Void) {
        
        Alamofire.request(.GET, NKNetworkBase.getURLStringByAppendingBaseURLWithPath("info/week")).responseJSON { (response: Response<AnyObject, NSError>) in
            switch response.result {
            case .Success(let value):
                let json = JSON(value)
                guard json["msg"].stringValue == "OK" else {
                    completionHandler(nowWeek: nil)
                    return
                }
                let nowWeek = json["data"]["nowWeek"].intValue
                completionHandler(nowWeek: nowWeek)
            case .Failure( _):
                completionHandler(nowWeek: nil)
            }
        }
        
    }
    
}