//
//  NKNetworkTestTimeHandler.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/17.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import Foundation
import Alamofire

/// 查询考试时间的结果
///
/// - success: 成功
/// - fail:    失败
enum NKNetworkFetchTestTimeResult {
    case success(testTime: [ClassTestTime])
    case fail
}

/**
 查询考试时间的网络库
 * * * * *
 
 last modified:
 - date: 2016.10.13
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
@objc(NKNetworkTestTimeHandler)
class NKNetworkTestTimeHandler: NKNetworkBase {
    
    typealias FetchTestTimeBlock = (NKNetworkFetchTestTimeResult) -> Void
    
    /// 查询考试时间
    ///
    /// - parameter completionHandler: 返回闭包
    class func fetchTestTime(withBlock completionHandler: @escaping FetchTestTimeBlock) {
        Alamofire.request("http://222.30.32.10/xxcx/stdexamarrange/listAction.do").responseString { (response) in
            guard let html = response.result.value else {
                completionHandler(.fail)
                return
            }
            let testTime = self.analyze(html: html)
            completionHandler(.success(testTime: testTime))
        }
    }
    
    /// 分析html
    dynamic class private func analyze(html: String) -> [ClassTestTime] {
        var testTime = [ClassTestTime]()
        let regularExpression = try! NSRegularExpression(pattern: "<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?", options: .dotMatchesLineSeparators)
        let matches = regularExpression.matches(in: html, options: .reportCompletion, range: NSMakeRange(0, (html as NSString).length))
        let htmlNSString = html as NSString
        for i in 0..<matches.count {
            let match = matches[i]
            let className = htmlNSString.substring(with: match.rangeAt(1))
            let week = htmlNSString.substring(with: match.rangeAt(3))
            let weekday = htmlNSString.substring(with: match.rangeAt(4))
            let startSection = htmlNSString.substring(with: match.rangeAt(5))
            let endSection = htmlNSString.substring(with: match.rangeAt(6))
            let classroom = htmlNSString.substring(with: match.rangeAt(7))
            let startTime = htmlNSString.substring(with: match.rangeAt(8))
            let endTime = htmlNSString.substring(with: match.rangeAt(9))
            let classTestTime = ClassTestTime(classname: className, week: (week as NSString).integerValue, weekday: (weekday as NSString).integerValue, startSection: (startSection as NSString).integerValue, endSection: (endSection as NSString).integerValue, classroom: classroom, startTime: startTime, endTime: endTime)
            testTime.append(classTestTime)
        }
        return testTime
    }

    
}
