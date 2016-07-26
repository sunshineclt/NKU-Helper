//
//  NKNetworkFetchNoti.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/15/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/**
 获取通知的结果
 
 - Success: 成功，附获取到的通知数据及总页数
 - Fail:    获取失败
 */
enum NKNetworkFetchNotiResult {
    case Success(notis:[Notification], totalPages: Int)
    case Fail(msg: String)
}

/// 提供获取通知的功能
class NKNetworkFetchNoti: NKNetworkBase {
    
    typealias fetchNotiBlock = (NKNetworkFetchNotiResult) -> Void
    
    var block:fetchNotiBlock?
    
    /**
     获取通知
     
     - parameter page:  第几页
     - parameter block: 返回闭包
     */
    func fetchNotiOnPage(page: Int,WithBlock block:fetchNotiBlock) {
        
        self.block = block
        
        Alamofire.request(.GET, NKNetworkBase.getURLStringByAppendingBaseURLWithPath("notis"), parameters: ["page": page, "page_size": 10]).responseJSON { (response) -> Void in
            switch response.result {
            case .Success(let value):
                let json = JSON(value)
                let msg = json["msg"].stringValue
                guard msg == "OK" else {
                    block(.Fail(msg: msg))
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
                block(.Success(notis: notis, totalPages: totalPages))
            case .Failure:
                block(.Fail(msg: "网络请求失败"))
            }
        }
        
    }
    
}