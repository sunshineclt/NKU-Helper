//
//  NKNetworkEvaluateSubmitHandler.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/22/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import Alamofire

/// 提交评教的结果
///
/// - success: 成功
/// - fail:    失败
enum NKNetworkSubmitEvaluateResult {
    case success
    case fail
}

/**
 提交评教结果的网络库
 * * * * *
 
 last modified:
 - date: 2016.10.14
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
class NKNetworkEvaluateSubmitHandler: NKNetworkBase {
    
    typealias NKNetworkEvaluateSubmitBlock = (NKNetworkSubmitEvaluateResult) -> Void

    /// 提交评教结果
    ///
    /// - parameter grades:  各项分数
    /// - parameter opinion: 意见
    /// - parameter index:   编号
    /// - parameter block:   返回闭包
    class func submit(grades: [String], opinion: String, index: Int, withBlock block: @escaping NKNetworkEvaluateSubmitBlock) {
        //TODO: 在开放时整理
        let url = URL(string: "http://222.30.32.10/evaluate/stdevatea/queryTargetAction.do")!
        var req = URLRequest(url: url)
        var data = String(format: "operation=Store")
        for i in 0 ..< grades.count {
            let gradeString = "&array[\(i)]=\(grades[i])"
            data = data + gradeString
        }
        data = data + "&opinion=\(opinion)"
        req.httpBody = data.data(using: String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0632)))
        req.addValue("http://222.30.32.10/evaluate/stdevatea/queryTargetAction.do?operation=target&index=\(index)", forHTTPHeaderField: "Referer")
        req.httpMethod = "POST"

        Alamofire.request(req).responseString { (response) -> Void in
            guard let html = response.result.value else {
                block(.fail)
                return
            }
            if (html as NSString).range(of: "成功保存").length > 0 {
                block(.success)
            }
            else {
                block(.fail)
            }
        }
    }
    
}
