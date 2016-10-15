//
//  NKNetworkGradeHandler.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/15/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import Alamofire

/// 获取成绩的结果
///
/// - success: 成功
/// - fail:    失败
enum NKNetworkFetchGradeResult {
    case success(grade: [Grade])
    case fail(error: ErrorHandlerProtocol)
}

/**
 获取成绩的网络库
 * * * * *
 
 last modified:
 - date: 2016.10.12
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
@objc(NKNetworkGradeHandler)
class NKNetworkGradeHandler: NKNetworkBase {
    
    typealias FetchGradeResult = (NKNetworkFetchGradeResult) -> Void
    
    /// 返回闭包
    var block: FetchGradeResult!
    /// 最终结果
    private var finalResult = [Grade]()
    /// 上次请求所取得的response，用于判断是否到达成绩最后一页
    private var previousResponse: String!

    /// 获取成绩
    ///
    /// - parameter block: 返回闭包
    func fetchGrade(withBlock block: @escaping FetchGradeResult) {
        self.block = block
        Alamofire.request("http://222.30.32.10/xsxk/studiedAction.do").responseString { (response) -> Void in
            guard let html = response.result.value else {
                block(.fail(error: ErrorHandler.NetworkError()))
                return
            }
            self.previousResponse = html
            self.analyze(html: html)
        }
    }

    /// 分析html
    ///
    /// - parameter html: 需要分析的html
    dynamic private func analyze(html: String) {
        let regularExpression = try! NSRegularExpression(pattern: "<td[^<>]*?NavText\"[^<>]*?>([^<>]*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>([^<>]*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>([^<>]*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>([^<>]*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>([^<>]*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>([^<>]*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>([^<>]*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>([^<>]*?)\\s*?</td>\\s*?", options: .dotMatchesLineSeparators)
        let matches = regularExpression.matches(in: html, options: .reportCompletion, range: NSMakeRange(0, (html as NSString).length))
        let htmlNSString = html as NSString
        for i in 0..<matches.count {
            let match = matches[i]
            
            let className = htmlNSString.substring(with: match.rangeAt(3))
            let classType = htmlNSString.substring(with: match.rangeAt(4))
            let grade = htmlNSString.substring(with: match.rangeAt(5))
            let credit = htmlNSString.substring(with: match.rangeAt(6))
            let retakeGrade = htmlNSString.substring(with: match.rangeAt(7))
            
            let courseGrade = Grade(className: className, classType: classType, grade: grade, credit: credit, retakeGrade: retakeGrade)
            finalResult.append(courseGrade)
        }
        loadNextPage()
    }
    
    /// 加载下一页
    dynamic private func loadNextPage() {
        Alamofire.request("http://222.30.32.10/xsxk/studiedPageAction.do?page=next").responseString { (response) -> Void in
            guard let html = response.result.value else {
                self.block(.fail(error: ErrorHandler.NetworkError()))
                return
            }
            if html == self.previousResponse {
                self.block(.success(grade: self.finalResult))
            }
            else {
                self.previousResponse = html
                self.analyze(html: html)
            }
        }
    }
    
}
