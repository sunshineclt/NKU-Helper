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
    func didSuccessToReceiveGradeData(grade grade: [Grade])
    func didFailToReceiveGradeData(error: ErrorHandlerProtocol)
}

/// 提供获取成绩的功能
@objc(NKNetworkFetchGrade)
class NKNetworkFetchGrade: NKNetworkBase {
    
    var delegate: NKNetworkFetchGradeProtocol?
    
    private var finalResult = [Grade]()
    
    private var preResult: String!

    /**
     获取成绩
     */
    func fetchGrade() {
        Alamofire.request(.GET, "http://222.30.32.10/xsxk/studiedAction.do").responseString { (response) -> Void in
            guard let html = response.result.value else {
                self.delegate?.didFailToReceiveGradeData(ErrorHandler.NetworkError())
                return
            }
            self.preResult = html
            self.loadHtml(html)
        }
    }

    dynamic private func loadHtml(htmlReceived: String) {
        
        let regularExpression = try! NSRegularExpression(pattern: "<td[^<>]*?NavText\"[^<>]*?>([^<>]*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>([^<>]*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>([^<>]*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>([^<>]*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>([^<>]*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>([^<>]*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>([^<>]*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>([^<>]*?)\\s*?</td>\\s*?", options: .DotMatchesLineSeparators)
        let matches = regularExpression.matchesInString(htmlReceived, options: .ReportCompletion, range: NSMakeRange(0, (htmlReceived as NSString).length))
        let htmlNSString = htmlReceived as NSString
        for i in 0..<matches.count {
            let match = matches[i]
            
            let className = htmlNSString.substringWithRange(match.rangeAtIndex(3))
            let classType = htmlNSString.substringWithRange(match.rangeAtIndex(4))
            let grade = htmlNSString.substringWithRange(match.rangeAtIndex(5))
            let credit = htmlNSString.substringWithRange(match.rangeAtIndex(6))
            let retakeGrade = htmlNSString.substringWithRange(match.rangeAtIndex(7))
            
            let courseGrade = Grade(className: className, classType: classType, grade: grade, credit: credit, retakeGrade: retakeGrade)
            finalResult.append(courseGrade)
        }
        
        loadNextPage()
        
    }
    
    dynamic private func loadNextPage() {
        Alamofire.request(.GET, "http://222.30.32.10/xsxk/studiedPageAction.do?page=next").responseString { (response) -> Void in
            guard let html = response.result.value else {
                self.delegate?.didFailToReceiveGradeData(ErrorHandler.NetworkError())
                return
            }
            if html == self.preResult {
                self.delegate?.didSuccessToReceiveGradeData(grade: self.finalResult)
            }
            else {
                self.preResult = html
                self.loadHtml(html)
            }
        }
    }
    
}