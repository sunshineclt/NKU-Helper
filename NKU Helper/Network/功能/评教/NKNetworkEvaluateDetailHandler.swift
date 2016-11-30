//
//  NKNetworkEvaluateDetailHandler.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/21/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import Alamofire

/// 评教详细列表的获取结果
///
/// - success: 成功
/// - fail:    失败
enum NKNetworkFetchEvaluateDetailResult {
    case success(detailEvaluateList: [DetailEvaluateSection])
    case fail
}

/**
 获取每门课详细评教信息的网络库
 * * * * *
 
 last modified:
 - date: 2016.10.14
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
@objc(NKNetworkEvaluateDetailHandler)
class NKNetworkEvaluateDetailHandler: NKNetworkBase {

    typealias FetchEvaluateDetailBlock = (NKNetworkFetchEvaluateDetailResult) -> Void
    
    /// 获取评教详细内容
    ///
    /// - parameter index: 编号
    /// - parameter block: 返回闭包
    class func getDetailEvaluateInfo(forIndex index: Int, withBlock block: @escaping FetchEvaluateDetailBlock) {
        Alamofire.request("http://222.30.49.10/evaluate/stdevatea/queryTargetAction.do?operation=target&index=\(index)").responseString { (response) -> Void in
            guard let html = response.result.value else {
                block(.fail)
                return
            }
            let detailEvaluateList = self.analyze(html: html)
            block(.success(detailEvaluateList: detailEvaluateList))
        }
    }
    
    private class func analyze(html: String) -> [DetailEvaluateSection] {
        //TODO: 在开放时整理
        let regularExpression1 = try! NSRegularExpression(pattern: "(<table bgcolor=.#CCCCCC.*?>)(.*?)(</table>)", options: .dotMatchesLineSeparators)
        let matches = regularExpression1.matches(in: html, options: .reportProgress, range: NSMakeRange(0, (html as NSString).length))
        
        let header = (html as NSString).substring(with: matches[0].rangeAt(2))
        let regularExpression2 = try! NSRegularExpression(pattern: "(<td valign.*?height=)(.*?)( width.*?>\\s*)(.*?)(\\s*</td>)", options: .dotMatchesLineSeparators)
        let headerMatches = regularExpression2.matches(in: header, options: .reportProgress, range: NSMakeRange(0, (header as NSString).length))
        
        let regularExpression3 = try! NSRegularExpression(pattern: "(<td.*?class=.NavText.>\\s*)(.*?)(（)(.*?)(）\\s*)(</td>)", options: .dotMatchesLineSeparators)
        let questionMatches = regularExpression3.matches(in: html, options: .reportProgress, range: NSMakeRange(0, (html as NSString).length))
        var questionIndex = 0
        
        var detailEvaluateList = [DetailEvaluateSection]()
        for i in 0 ..< headerMatches.count {
            let questionAmount = ((header as NSString).substring(with: headerMatches[i].rangeAt(2)) as NSString).integerValue / 30
            let title = (header as NSString).substring(with: headerMatches[i].rangeAt(4))
            
            var questions = [Question]()
            for _ in 0 ..< questionAmount {
                if questionIndex >= questionMatches.count {
                    questionIndex += 1
                    questions.append(Question(content: "该教师给你的总体印象", grade: 10))
                }
                else {
                    let content = (html as NSString).substring(with: questionMatches[questionIndex].rangeAt(2))
                    let grade = ((html as NSString).substring(with: questionMatches[questionIndex].rangeAt(4)) as NSString).integerValue
                    questionIndex += 1
                    questions.append(Question(content: content, grade: grade))
                }
            }
            detailEvaluateList.append(DetailEvaluateSection(title: title, question: questions))
        }
        return detailEvaluateList
    }
    
}
