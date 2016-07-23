//
//  NKNetworkFetchGrade.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/15/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import Alamofire

/**
 *  获取成绩的代理事件
 */
protocol NKNetworkFetchGradeProtocol {
    func didSuccessToReceiveGradeData(grade grade: [Grade], abcgpa: Double)
    func didFailToReceiveGradeData(error: ErrorHandlerProtocol)
}

/// 提供获取成绩的功能
class NKNetworkFetchGrade: NKNetworkBase {
    
    var delegate: NKNetworkFetchGradeProtocol?
    
    private var finalResult = [Grade]()
    
    private var preResult: NSString!

    /**
     获取成绩
     */
    func fetchGrade() {
        Alamofire.request(.GET, "http://222.30.32.10/xsxk/studiedAction.do").responseString { (response: Response<String, NSError>) -> Void in
            if let html = response.result.value {
                self.preResult = html
                self.loadHtml(html)
            }
            else {
                self.delegate?.didFailToReceiveGradeData(ErrorHandler.NetworkError())
            }
        }
    }

    private func loadHtml(htmlReceived:NSString) {
        
        let loc1 = htmlReceived.rangeOfString("</table>")
        let html1 = htmlReceived.substringFromIndex(loc1.location + loc1.length) as NSString
        
        let loc2 = html1.rangeOfString("<table")
        let loc3 = html1.rangeOfString("</table>")
        let html2 = html1.substringWithRange(NSMakeRange(loc2.location, loc3.location - loc2.location)) as NSString
        
        let loc4  = html2.rangeOfString("</tr>")
        let interceptedHtml = html2.substringFromIndex(loc4.location + loc4.length) as NSString
        
        let regularExpression1 = try! NSRegularExpression(pattern: "<tr", options: .CaseInsensitive)
        let regularExpression2 = try! NSRegularExpression(pattern: "(<td.*?>)(.*?)(\r\n.*?\t)(</td>)", options: .DotMatchesLineSeparators)
        
        let matches = regularExpression1.matchesInString(interceptedHtml as String, options: .ReportProgress, range: NSMakeRange(0, interceptedHtml.length))
        
        for i in 0 ..< matches.count {
            let r1 = matches[i]
            var now:NSString
            if (i < matches.count-1){
                let r2 = matches[i+1]
                now = interceptedHtml.substringWithRange(NSMakeRange(r1.range.location, r2.range.location - r1.range.location))
            }
            else{
                now = interceptedHtml.substringFromIndex(r1.range.location)
            }
            let items = regularExpression2.matchesInString(now as String, options: .ReportProgress, range: NSMakeRange(0, now.length))
            
            let className = now.substringWithRange(items[2].rangeAtIndex(2))
            let classType = now.substringWithRange(items[3].rangeAtIndex(2))
            let grade = now.substringWithRange(items[4].rangeAtIndex(2))
            let credit = now.substringWithRange(items[5].rangeAtIndex(2))
            let retakeGrade = now.substringWithRange(items[6].rangeAtIndex(2))
            
            let courseGrade = Grade(className: className, classType: classType, grade: grade, credit: credit, retakeGrade: retakeGrade)
            
            finalResult.append(courseGrade)
        }

        Alamofire.request(.GET, "http://222.30.32.10/xsxk/studiedPageAction.do?page=next").responseString { (response: Response<String, NSError>) -> Void in
            if let html = response.result.value {
                if html == self.preResult {
                    let regularExpression = try! NSRegularExpression(pattern: "(ABC类课学分绩:)(.*?)(\\(成绩合格课程\\))", options: .CaseInsensitive)
                    let matches = regularExpression.matchesInString(html, options: .ReportProgress, range: NSMakeRange(0, (html as NSString).length))
                    let abcgpa = (html as NSString).substringWithRange(matches[0].rangeAtIndex(2)) as NSString
                    self.delegate?.didSuccessToReceiveGradeData(grade: self.finalResult, abcgpa: abcgpa.doubleValue)
                }
                else {
                    self.preResult = html
                    self.loadHtml(html)
                }
            }
            else {
                self.delegate?.didFailToReceiveGradeData(ErrorHandler.NetworkError())
            }
        }
    }
    
}