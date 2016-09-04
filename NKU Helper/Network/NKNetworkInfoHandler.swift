//
//  NKNetworkInfoHandler.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/15.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/// 提供一系列信息功能的网络库
class NKNetworkInfoHandler: NKNetworkBase {
    
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
    
    /**
     登记用户
    */
    class func registerUser() {
        do {
            let user = try UserDetailInfoAgent.sharedInstance.getData()
            Alamofire.request(.POST, NKNetworkBase.getURLStringByAppendingBaseURLWithPath("info/user"), parameters: ["UID": user.userID]).responseJSON { (response) in
                switch response.result {
                case .Success(let value):
                    let json = JSON(value)
                    guard json["msg"].stringValue == "OK" else {
                        print("registerUser fail")
                        return
                    }
                    print("registerUser success")
                case .Failure( _):
                    print("registerUser fail")
                }
            }
        } catch {
            print("登记用户时无用户存储")
        }
    }
    
    /**
     上传DeviceToken，以学号和uuid作为标记
     
     - parameter deviceToken: DeviceToken
     */
    class func uploadDeviceToken(deviceToken: String) {
        guard let uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString else {
            print("获取uuid失败")
            return
        }
        do {
            let user = try UserDetailInfoAgent.sharedInstance.getData()
            Alamofire.request(.POST, NKNetworkBase.getURLStringByAppendingBaseURLWithPath("info/deviceToken"), parameters: ["UID": user.userID, "UUID": uuid, "DeviceToken": deviceToken]).responseJSON { (response) in
                switch response.result {
                case .Success(let value):
                    let json = JSON(value)
                    guard json["msg"].stringValue == "OK" else {
                        print("上传device token fail")
                        return
                    }
                    print("上传device token success")
                case .Failure( _):
                    print("上传device token fail")
                }
            }
        }
        catch {
            print("上传DeviceToken无用户存储")
        }
    }
    
}