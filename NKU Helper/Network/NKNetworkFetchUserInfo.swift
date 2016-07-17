//
//  NKNetworkFetchUserInfo.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/20/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
//

import Foundation
import Alamofire

enum NKNetworkFetchUserInfoResult {
    case Success(name:String, timeEnteringSchool:String, departmentAdmitted:String, majorAdmitted:String)
    case NetworkError
}

/// 提供获取用户详细数据的功能
class NKNetworkFetchUserInfo: NKNetworkBase {
    
    typealias FetchUserInfoResult = (NKNetworkFetchUserInfoResult) -> Void
    
    var block: FetchUserInfoResult!
    
    /**
     获取用户信息数据
     
     - parameter block: 返回闭包
     */
    func getAllAccountInfoWithBlock(block: FetchUserInfoResult) {
        self.block = block
        Alamofire.request(.GET, "http://222.30.32.10/studymanager/stdbaseinfo/queryAction.do").responseString(encoding: CFStringConvertEncodingToNSStringEncoding(0x0632)) { (response:Response<String, NSError>) -> Void in
            if let html = response.result.value {
                let name = self.cutUpString(html, specificString1: ";名</td>", specificString2: "NavText", specificString3: "</td>")
                let timeEnteringScohol = self.cutUpString(html, specificString1: ">入学时间</td>", specificString2: "NavText", specificString3: "</td>")
                let departmentAdmitted = self.cutUpString(html, specificString1: ">录取院系<", specificString2: "span=", specificString3: "</td>")
                let majorAdmitted = self.cutUpString(html, specificString1: ">录取专业<", specificString2: "span=", specificString3: "</td>")
                self.block(NKNetworkFetchUserInfoResult.Success(name: name, timeEnteringSchool: timeEnteringScohol, departmentAdmitted: departmentAdmitted, majorAdmitted: majorAdmitted))
            } else {
                block(NKNetworkFetchUserInfoResult.NetworkError)
            }
        }

    }

    private func cutUpString(originalString:NSString, specificString1:String, specificString2:String, specificString3:String) -> String {
        let location1 = originalString.rangeOfString(specificString1)
        let tempString1 = originalString.substringWithRange(NSMakeRange(location1.location+7, location1.length+70))
        let tempString2 = NSString(string: tempString1)
        let location2 = tempString2.rangeOfString(specificString2)
        let location3 = tempString2.rangeOfString(specificString3)
        let result = tempString2.substringWithRange(NSMakeRange(location2.location+9, location3.location-location2.location-9))
        
        return result
    }
}