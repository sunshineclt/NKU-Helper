//
//  NKNetworkCourseEvaluateHandler.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/21/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import Alamofire

/// 获取评教列表的结果
///
/// - success:               成功
/// - fail:                  失败
/// - evaluateSystemNotOpen: 评教系统未开
enum NKNetworkFetchCourseEvaluateResult {
    case success(coursesToEvaluate: [CourseToEvaluate])
    case fail
    case evaluateSystemNotOpen
}

/**
 评教的网络库
 * * * * *
 
 last modified:
 - date: 2016.10.13
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
@objc(NKNetworkCourseEvaluateHandler)
class NKNetworkCourseEvaluateHandler: NKNetworkBase {

    typealias FetchCourseEvaluateListBlock = (NKNetworkFetchCourseEvaluateResult) -> Void
    
    var block: FetchCourseEvaluateListBlock!
    
    /// 获取评教列表
    ///
    /// - parameter block: 返回闭包
    class func getEvaluateList(withBlock block: @escaping FetchCourseEvaluateListBlock) {
        Alamofire.request("http://222.30.49.10/evaluate/stdevatea/queryCourseAction.do").responseString { (response) -> Void in
            guard let html = response.result.value else {
                block(.fail)
                return
            }
            if let coursesToEvaluate = self.analyze(html: html) {
                block(.success(coursesToEvaluate: coursesToEvaluate))
            }
            else {
                block(.evaluateSystemNotOpen)
            }
        }
    }
    
    /// 分析html
    ///
    /// - parameter html: html
    private class func analyze(html: String) -> [CourseToEvaluate]? {
        //TODO: 在开放时整理
        let loc1 = (html as NSString).range(of: "<table bgcolor=\"#CCCCCC\" cellspacing")
        guard loc1.length > 0 else {
            return nil
        }
        let mainHtml = (html as NSString).substring(from: loc1.location)
        let regularExpression1 = try! NSRegularExpression(pattern: "(<tr bgcolor=.#FFFFFF.>)(.*?)(</tr>)", options: .dotMatchesLineSeparators)
        let regularExpression2 = try! NSRegularExpression(pattern: "(<td class=\\\"NavText\\\"\\s*>)(.*?)(</td>)", options: .caseInsensitive)
        let regularExpression3 = try! NSRegularExpression(pattern: "(.*?)(index=)(.)(.*?)", options: .caseInsensitive)
        let matches = regularExpression1.matches(in: mainHtml, options: .reportProgress, range: NSMakeRange(0, (mainHtml as NSString).length))
        var coursesToEvaluate = [CourseToEvaluate]()
        for i in 0 ..< matches.count {
            let lesson = (mainHtml as NSString).substring(with: matches[i].rangeAt(2)) as NSString
            let items = regularExpression2.matches(in: lesson as String, options: .reportProgress, range: NSMakeRange(0, (lesson as NSString).length))
            
            let lessonName = lesson.substring(with: items[2].rangeAt(2))
            let teacherName = lesson.substring(with: items[4].rangeAt(2))
            let hasEvaluated = lesson.substring(with: items[5].rangeAt(2))
            
            let indexString = lesson.substring(with: items[6].rangeAt(2))
            let indexLocation = regularExpression3.matches(in: indexString, options: .reportProgress, range: NSMakeRange(0, (indexString as NSString).length))
            let index = (indexString as NSString).substring(with: indexLocation[0].rangeAt(3)) as NSString
            
            let courseToEvaluate = CourseToEvaluate(className: lessonName, teacherName: teacherName, hasEvaluated: hasEvaluated, index: index.integerValue)
            coursesToEvaluate.append(courseToEvaluate)
        }
        return coursesToEvaluate
    }
    
}
