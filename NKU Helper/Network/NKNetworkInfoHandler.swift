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

/**
 获取服务端提供的信息的网络库
 * * * * *
 
 last modified:
 - date: 2016.10.12
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
class NKNetworkInfoHandler: NKNetworkBase {
    
    /// (缓存)当前周数
    static var nowWeek: Int!
    /// (缓存)当前是否是假期
    static var isVocation: Bool!
    
    /// 获取当前周数（也有可能是假期）
    /// - important: 自带缓存机制
    ///
    /// - parameter completionHandler: 返回闭包
    class func fetchNowWeek(withBlock block: @escaping (_ nowWeek: Int?, _ isVocation: Bool?) -> Void) {
        if (nowWeek != nil) && (isVocation != nil) {
            block(nowWeek, isVocation)
            return
        }
        Alamofire.request(NKNetworkBase.getURLByAppendingBaseURL(withPath: "info/week")).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                guard json["msg"].stringValue == "OK" else {
                    block(nil, nil)
                    return
                }
                nowWeek = json["data"]["nowWeek"].intValue
                isVocation = json["data"]["isVocation"].boolValue
                block(nowWeek, isVocation)
            case .failure( _):
                block(nil, nil)
            }
        }
    }

    /// 登记用户
    class func registerUser() {
        do {
            let user = try UserAgent.sharedInstance.getUserInfo()
            Alamofire.request(NKNetworkBase.getURLByAppendingBaseURL(withPath: "info/user"), method: .post, parameters: ["UID": user.userID]).responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    guard json["msg"].stringValue == "OK" else {
                        print("register user FAIL")
                        return
                    }
                    print("register user SUCCESS")
                case .failure( _):
                    print("register user FAIL")
                }
            }
        } catch {
            print("登记用户时无用户存储")
        }
    }
    
    /// 上传DeviceToken
    /// - important: 以学号和uuid作为标记
    ///
    /// - parameter deviceToken: DeviceToken
    class func uploadDeviceToken(_ deviceToken: String) {
        guard let uuid = UIDevice.current.identifierForVendor?.uuidString else {
            print("获取uuid失败")
            return
        }
        do {
            let user = try UserAgent.sharedInstance.getUserInfo()
            Alamofire.request(NKNetworkBase.getURLByAppendingBaseURL(withPath: "info/deviceToken"), method: .post, parameters: ["UID": user.userID, "UUID": uuid, "DeviceToken": deviceToken]).responseJSON { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    guard json["msg"].stringValue == "OK" else {
                        print("upload device token FAIL")
                        return
                    }
                    print("upload device token SUCCESS")
                case .failure( _):
                    print("upload device token FAIL")
                }
            }
        }
        catch {
            print("上传DeviceToken无用户存储")
        }
    }
    
}
