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
    case Success(testTime: testTimeArray)
    case Fail
}

typealias testTimeArray = [[String:String]]

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
            print(html)
            let testTime = self.loadHtml(html)
            completionHandler(.Success(testTime: testTime))
        }
    }
    
    dynamic private func loadHtml(html: String) -> testTimeArray {
        var testTime = testTimeArray()
        let regularExpression = try! NSRegularExpression(pattern: "<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?<td[^<>]*?NavText\">([^<>]*?)</td>\\s*?", options: .DotMatchesLineSeparators)
        let matches = regularExpression.matchesInString(html, options: .ReportCompletion, range: NSMakeRange(0, (html as NSString).length))
        let htmlNSString = html as NSString
        for i in 0..<matches.count {
            let match = matches[i]
            var dictionary = [String:String]()
            dictionary["className"] = htmlNSString.substringWithRange(match.rangeAtIndex(1))
            dictionary["week"] = htmlNSString.substringWithRange(match.rangeAtIndex(3))
            switch htmlNSString.substringWithRange(match.rangeAtIndex(4)) {
            case "1":dictionary["weekday"] = "星期一"
            case "2":dictionary["weekday"] = "星期二"
            case "3":dictionary["weekday"] = "星期三"
            case "4":dictionary["weekday"] = "星期四"
            case "5":dictionary["weekday"] = "星期五"
            case "6":dictionary["weekday"] = "星期六"
            case "7":dictionary["weekday"] = "星期天"
            default:dictionary["weekday"] = "未知"
            }
            dictionary["startSection"] = htmlNSString.substringWithRange(match.rangeAtIndex(5))
            dictionary["endSection"] = htmlNSString.substringWithRange(match.rangeAtIndex(6))
            dictionary["classroom"] = htmlNSString.substringWithRange(match.rangeAtIndex(7))
            dictionary["startTime"] = htmlNSString.substringWithRange(match.rangeAtIndex(8))
            dictionary["endTime"] = htmlNSString.substringWithRange(match.rangeAtIndex(9))
            testTime.append(dictionary)
        }
        return testTime
    }

    
}