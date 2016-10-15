//
//  NKNetworkNotiHandler.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/15/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/// 获取通知的结果
///
/// - success: 成功，附获取到的通知数据及总页数
/// - fail:    获取失败
enum NKNetworkFetchNotiResult {
    case success(notis:[Notification], totalPages: Int)
    case fail(msg: String)
}

/**
 获取通知的网络库
 * * * * *
 
 last modified:
 - date: 2016.10.14
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
class NKNetworkNotiHandler: NKNetworkBase {
    
    typealias fetchNotiBlock = (NKNetworkFetchNotiResult) -> Void
    
    /// 获取通知
    ///
    /// - parameter page:  第几页
    /// - parameter block: 返回闭包
    class func fetchNoti(onPage page: Int, WithBlock block:@escaping fetchNotiBlock) {
        Alamofire.request(NKNetworkBase.getURLByAppendingBaseURL(withPath: "notis"), parameters: ["page": page, "page_size": 10]).responseJSON { (response) -> Void in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let msg = json["msg"].stringValue
                guard msg == "OK" else {
                    block(.fail(msg: msg))
                    return
                }
                var notis = [Notification]()
                let data = json["data"].arrayValue
                for singleData in data {
                    let title = singleData["title"].stringValue
                    let time = singleData["time"].stringValue
                    let url = singleData["url"].stringValue
                    let text = singleData["text"].stringValue
                    let readCount = singleData["readcount"].intValue
                    let noti = Notification(title: title, time: time, url: url, text: text, readCount: readCount)
                    notis.append(noti)
                }
                let totalPages = json["total_pages"].intValue
                block(.success(notis: notis, totalPages: totalPages))
            case .failure:
                block(.fail(msg: "网络请求失败"))
            }
        }
        
    }
    
}
