//
//  NKNetworkEvaluateDetail.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/21/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import Alamofire

protocol NKNetworkEvaluateDetailProtocol {
    func didNetworkFail()
    func didSuccess(detailEvaluateList: [DetailEvaluateSection])
}

/// 提供获取每门课详细评教信息的网络库
@objc(NKNetworkEvaluateDetail)
class NKNetworkEvaluateDetail: NKNetworkBase {
    
    var delegate: NKNetworkEvaluateDetailProtocol?
    
    /**
     获取具体评教内容
     */
    func getDetailEvaluateItem(index: Int) {
        Alamofire.request(.GET, "http://222.30.32.10/evaluate/stdevatea/queryTargetAction.do?operation=target&index=\(index)").responseString { (response) -> Void in
            if let html = response.result.value {
                self.loadDetailEvaluateItem(html)
            }
            else {
                self.delegate?.didNetworkFail()
            }
        }
    }
    
    dynamic private func loadDetailEvaluateItem(html: String) {
        //TODO: 在开放时整理
        let regularExpression1 = try! NSRegularExpression(pattern: "(<table bgcolor=.#CCCCCC.*?>)(.*?)(</table>)", options: .DotMatchesLineSeparators)
        let matches = regularExpression1.matchesInString(html, options: .ReportProgress, range: NSMakeRange(0, (html as NSString).length))
        
        let header = (html as NSString).substringWithRange(matches[0].rangeAtIndex(2))
        let regularExpression2 = try! NSRegularExpression(pattern: "(<td valign.*?height=)(.*?)( width.*?>\\s*)(.*?)(\\s*</td>)", options: .DotMatchesLineSeparators)
        let headerMatches = regularExpression2.matchesInString(header, options: .ReportProgress, range: NSMakeRange(0, (header as NSString).length))
        
        let regularExpression3 = try! NSRegularExpression(pattern: "(<td.*?class=.NavText.>\\s*)(.*?)(（)(.*?)(）\\s*)(</td>)", options: .DotMatchesLineSeparators)
        let questionMatches = regularExpression3.matchesInString(html, options: .ReportProgress, range: NSMakeRange(0, (html as NSString).length))
        var questionIndex = 0
        
        var detailEvaluateList = [DetailEvaluateSection]()
        for i in 0 ..< headerMatches.count {
            let questionAmount = ((header as NSString).substringWithRange(headerMatches[i].rangeAtIndex(2)) as NSString).integerValue / 30
            let title = (header as NSString).substringWithRange(headerMatches[i].rangeAtIndex(4))
            
            var questions = [Question]()
            for _ in 0 ..< questionAmount {
                if questionIndex >= questionMatches.count {
                    questionIndex += 1
                    questions.append(Question(content: "该教师给你的总体印象", grade: 10))
                }
                else {
                    let content = (html as NSString).substringWithRange(questionMatches[questionIndex].rangeAtIndex(2))
                    let grade = ((html as NSString).substringWithRange(questionMatches[questionIndex].rangeAtIndex(4)) as NSString).integerValue
                    questionIndex += 1
                    questions.append(Question(content: content, grade: grade))
                }
            }
            detailEvaluateList.append(DetailEvaluateSection(title: title, question: questions))
        }
        self.delegate?.didSuccess(detailEvaluateList)
    }
    
}