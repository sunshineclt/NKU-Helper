//
//  NKNetworkEvaluate.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/21/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import Alamofire

/**
 *  获取评教列表功能的代理事件
 */
protocol NKNetworkEvaluateProtocol {
    func didNetworkFail()
    func evaluateSystemNotOpen()
    func didGetEvaluateList(lessonsToEvaluate: [ClassToEvaluate])
}

/// 提供评教功能的网络库
@objc(NKNetworkEvaluate)
class NKNetworkEvaluate: NKNetworkBase {

    var delegate: NKNetworkEvaluateProtocol?
    
    /**
     获取评教列表
     */
    func getEvaluateList() {
        Alamofire.request(.GET, "http://222.30.32.10/evaluate/stdevatea/queryCourseAction.do").responseString { (response) -> Void in
            if let html = response.result.value {
                self.loadEvaluateList(html)
            }
            else {
                self.delegate?.didNetworkFail()
            }
            
        }
    }
    
    dynamic private func loadEvaluateList(html: String) {
        //TODO: 在开放时整理
        let loc1 = (html as NSString).rangeOfString("<table bgcolor=\"#CCCCCC\" cellspacing")
        guard loc1.length > 0 else {
            self.delegate?.evaluateSystemNotOpen()
            return
        }
        let mainHtml = (html as NSString).substringFromIndex(loc1.location)
        let regularExpression1 = try! NSRegularExpression(pattern: "(<tr bgcolor=.#FFFFFF.>)(.*?)(</tr>)", options: .DotMatchesLineSeparators)
        let regularExpression2 = try! NSRegularExpression(pattern: "(<td class=\\\"NavText\\\"\\s*>)(.*?)(</td>)", options: .CaseInsensitive)
        let regularExpression3 = try! NSRegularExpression(pattern: "(.*?)(index=)(.)(.*?)", options: .CaseInsensitive)
        let matches = regularExpression1.matchesInString(mainHtml, options: .ReportProgress, range: NSMakeRange(0, (mainHtml as NSString).length))
        var lessonsToEvaluate = [ClassToEvaluate]()
        for i in 0 ..< matches.count {
            let lesson = (mainHtml as NSString).substringWithRange(matches[i].rangeAtIndex(2)) as NSString
            let items = regularExpression2.matchesInString(lesson as String, options: .ReportProgress, range: NSMakeRange(0, (lesson as NSString).length))
            
            let lessonName = lesson.substringWithRange(items[2].rangeAtIndex(2))
            let teacherName = lesson.substringWithRange(items[4].rangeAtIndex(2))
            let hasEvaluated = lesson.substringWithRange(items[5].rangeAtIndex(2))
            
            let indexString = lesson.substringWithRange(items[6].rangeAtIndex(2))
            let indexLocation = regularExpression3.matchesInString(indexString, options: .ReportProgress, range: NSMakeRange(0, (indexString as NSString).length))
            let index = (indexString as NSString).substringWithRange(indexLocation[0].rangeAtIndex(3)) as NSString
            
            let lessonToEvaluate = ClassToEvaluate(className: lessonName, teacherName: teacherName, hasEvaluated: hasEvaluated, index: index.integerValue)
            lessonsToEvaluate.append(lessonToEvaluate)
        }
        self.delegate?.didGetEvaluateList(lessonsToEvaluate)
    }
    
}