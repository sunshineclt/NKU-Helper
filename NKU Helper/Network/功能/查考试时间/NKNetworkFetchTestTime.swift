//
//  NKNetworkFetchTestTime.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/17.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import Foundation
import Alamofire

enum NKNetworkFetchTestTimeResult {
    case Success(testTime: [ClassTestTime])
    case Fail
}

/// 查询考试时间的网络类
@objc(NKNetworkFetchTestTime)
class NKNetworkFetchTestTime: NKNetworkBase {
    
    typealias fetchTestTimeBlock = (NKNetworkFetchTestTimeResult) -> Void
    
    var block:fetchTestTimeBlock?
    
    /**
     查询考试时间
     
     - parameter completionHandler: 返回闭包
     */
    func fetchTestTime(completionHandler: fetchTestTimeBlock) {
        Alamofire.request(.GET, "http://222.30.32.10/xxcx/stdexamarrange/listAction.do").responseString { (response) in
            guard let html = response.result.value else {
                completionHandler(.Fail)
                return
            }
            let testTime = self.loadHtml(html)
            completionHandler(.Success(testTime: testTime))
        }
    }
    
    dynamic private func loadHtml(html: String) -> [ClassTestTime] {
        var testTime = [ClassTestTime]()
        let regularExpression = try! NSRegularExpression(pattern: "<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?", options: .DotMatchesLineSeparators)
        let matches = regularExpression.matchesInString(html, options: .ReportCompletion, range: NSMakeRange(0, (html as NSString).length))
        let htmlNSString = html as NSString
        for i in 0..<matches.count {
            let match = matches[i]
            let className = htmlNSString.substringWithRange(match.rangeAtIndex(1))
            let week = htmlNSString.substringWithRange(match.rangeAtIndex(3))
            let weekday = htmlNSString.substringWithRange(match.rangeAtIndex(4))
            let startSection = htmlNSString.substringWithRange(match.rangeAtIndex(5))
            let endSection = htmlNSString.substringWithRange(match.rangeAtIndex(6))
            let classroom = htmlNSString.substringWithRange(match.rangeAtIndex(7))
            let startTime = htmlNSString.substringWithRange(match.rangeAtIndex(8))
            let endTime = htmlNSString.substringWithRange(match.rangeAtIndex(9))
            let classTestTime = ClassTestTime(classname: className, week: (week as NSString).integerValue, weekday: (weekday as NSString).integerValue, startSection: (startSection as NSString).integerValue, endSection: (endSection as NSString).integerValue, classroom: classroom, startTime: startTime, endTime: endTime)
            testTime.append(classTestTime)
        }
        return testTime
    }

    
}