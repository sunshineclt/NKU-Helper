//
//  NKNetworkFetchNoti.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/15/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import Alamofire

/**
 获取通知的结果
 
 - Success: 成功，附获取到的通知数据
 - End:     到达最底端，无法再获取
 - Fail:    获取失败
 */
enum NKNetworkFetchNotiResult {
    case Success(notis:[Notification])
    case End
    case Fail
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
        
        Alamofire.request(.GET, "http://115.28.141.95/CodeIgniter/index.php/Notification/getNoti/\(page+1)").responseJSON { (response:Response<AnyObject, NSError>) -> Void in
            guard let value = response.result.value as? NSDictionary else {
                block(.Fail)
                return
            }
            let code = value.objectForKey("code") as! Int
            switch code {
            case 0:   //正常获取数据
                let data = value.objectForKey("data") as! NSArray
                var notis:[Notification] = []
                for singleData in data {
                    let nowData = singleData as! NSDictionary
                    let title = nowData.objectForKey("title") as! String
                    let time = nowData.objectForKey("time") as! String
                    let url = nowData.objectForKey("url") as! String
                    let text = nowData.objectForKey("text") as! String
                    let readCount = nowData.objectForKey("readcount") as! Int
                    let noti = Notification(title: title, time: time, url: url, text: text, readCount: readCount)
                    notis.append(noti)
                }
                block(.Success(notis: notis))
                
            case 1:  //已经到达数据底端
                block(.End)
            default:
                block(.Fail)
            }
        }
        
    }
    
}