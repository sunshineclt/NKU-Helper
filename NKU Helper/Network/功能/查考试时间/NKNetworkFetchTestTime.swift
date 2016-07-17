//
//  NKNetworkFetchTestTime.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/17.
//  Copyright © 2016年 &#38472;&#20048;&#22825;. All rights reserved.
//

import Foundation
import Alamofire

enum NKNetworkFetchTestTimeResult {
    case Success(testTime: testTimeArray)
    case Fail
}

typealias testTimeArray = [[String:String]]

/// 查询考试时间的网络类
class NKNetworkFetchTestTime: NKNetworkBase {
    
    typealias fetchTestTimeBlock = (NKNetworkFetchTestTimeResult) -> Void
    
    var block:fetchTestTimeBlock?
    
    /**
     查询考试时间
     
     - parameter completionHandler: 返回闭包
     */
    func fetchTestTime(completionHandler: fetchTestTimeBlock) {
        Alamofire.request(.GET, "http://222.30.32.10/xxcx/stdexamarrange/listAction.do").responseString { (response) in
            if let html = response.result.value {
                let testTime = self.loadHtml(html)
                completionHandler(.Success(testTime: testTime))
            }
            else {
                completionHandler(.Fail)
            }
        }
    }
    
    private func loadHtml(html: NSString) -> testTimeArray {
        var testTime = testTimeArray()
        do{
            let regularExp1 = try NSRegularExpression(pattern: "<tr bgcolor=\"#FFFFFF\" >", options: NSRegularExpressionOptions.CaseInsensitive)
            var resultExp = regularExp1.matchesInString(html as String, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, html.length))
            for i in 0 ..< resultExp.count {
                let temp:NSString = html.substringWithRange(NSMakeRange(resultExp[i].range.location, 750))
                //       print("\n**********************\n")
                //       print(temp)
                let regularExp2 = try NSRegularExpression(pattern: "(<td align=\"center\" class=\"NavText\">).*?(</td>)", options: NSRegularExpressionOptions.CaseInsensitive)
                var index = regularExp2.matchesInString(temp as String, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, temp.length))
                var dictionary:[String:String] = [:]
                for j in 0 ..< index.count {
                    switch j {
                    case 1,2,4,5:continue
                    case 0,3,6,7,8:
                        let exact:NSString = temp.substringWithRange(index[j].range)
                        let firstRange = exact.rangeOfString("NavText\">")
                        let secondRange = exact.rangeOfString("</td>")
                        let exactNeed:NSString = exact.substringWithRange(NSMakeRange(firstRange.location + 9, secondRange.location - firstRange.location - 9))
                        switch j {
                        case 0:
                            dictionary["className"] = exactNeed as String
                        case 3:
                            switch exactNeed {
                            case "1":dictionary["weekday"] = "星期一"
                            case "2":dictionary["weekday"] = "星期二"
                            case "3":dictionary["weekday"] = "星期三"
                            case "4":dictionary["weekday"] = "星期四"
                            case "5":dictionary["weekday"] = "星期五"
                            case "6":dictionary["weekday"] = "星期六"
                            case "7":dictionary["weekday"] = "星期天"
                            default:continue
                            }
                        case 6:dictionary["classroom"] = exactNeed as String
                        case 7:
                            let exactNeedShort = exactNeed.substringWithRange(NSMakeRange(5, 11))
                            dictionary["startTime"] = exactNeedShort
                        case 8:
                            let exactNeedShort = exactNeed.substringWithRange(NSMakeRange(5, 11))
                            dictionary["endTime"] = exactNeedShort
                        default:continue
                        }
                    default:continue
                    }
                }
                testTime.append(dictionary)
            }
        }
        catch {
            return []
        }
        return testTime
    }

    
}