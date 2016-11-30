//
//  NKNetworkUserInfoHandler.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/20/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import Alamofire

/// 获取用户详细信息结果
///
/// - success:      成功
/// - networkError: 网络错误
/// - analyzeError: 解析错误
enum NKNetworkFetchUserInfoResult {
    case success(name:String, timeEnteringSchool:String, departmentAdmitted:String, majorAdmitted:String)
    case networkError
    case analyzeError
}

/**
 获取用户详细数据的网络库
 * * * * *
 
 last modified:
 - date: 2016.10.12
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
@objc(NKNetworkUserInfoHandler)
class NKNetworkUserInfoHandler: NKNetworkBase {
    
    typealias FetchUserInfoResult = (NKNetworkFetchUserInfoResult) -> Void
    
    /// 获取用户详细信息数据
    /// - note: 包括姓名、入学时间、录取院系和录取专业
    ///
    /// - parameter block: 返回闭包
    class func getAllAccountInfo(withBlock block: @escaping FetchUserInfoResult) {
        Alamofire.request("http://222.30.49.10/studymanager/stdbaseinfo/queryAction.do").responseString(encoding: String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0632))) { (response) -> Void in
            guard let html = response.result.value else {
                block(.networkError)
                return
            }
            guard let (name, timeEnteringSchool, departmentAdmitted, majorAdmitted) = self.analyze(html: html) else {
                block(.analyzeError)
                return
            }
            block(.success(name: name, timeEnteringSchool: timeEnteringSchool, departmentAdmitted: departmentAdmitted, majorAdmitted: majorAdmitted))
        }
    }

    /// 分析HTML
    ///
    /// - parameter html: 网络请求得到的html
    ///
    /// - returns: 姓名、入学时间、录取院系和录取专业的元组
    private class func analyze(html: String) -> (name: String, timeEnteringSchool: String, departmentAdmitted: String, majorAdmitted: String)? {
        if let name = findProperty(inHtml: html, WithPara: "姓[^<>]*?名"),
            let timeEnteringSchool = findProperty(inHtml: html, WithPara: "入学时间"),
            let departmentAdmitted = findProperty(inHtml: html, WithPara: "录取院系"),
            let majorAdmitted = findProperty(inHtml: html, WithPara: "录取专业") {
            return (name: name, timeEnteringSchool: timeEnteringSchool, departmentAdmitted: departmentAdmitted, majorAdmitted: majorAdmitted)
        }
        else {
            return nil
        }
    }
    
    /// 在html中寻找property
    ///
    /// - parameter html: 网络请求得到的html
    /// - parameter para: 要寻找的property的正则字符串
    ///
    /// - returns: property的值
    dynamic private class func findProperty(inHtml html: String, WithPara para: String) -> String? {
        do {
            let reg = try NSRegularExpression(pattern: "<td[^>]*?DetailMsg[^>]*?>" + para + "</td>\\s*?<td[^>]*?NavText[^>]*?>([^<>]*?)</td>", options: .caseInsensitive)
            let matches = reg.matches(in: html, options: .reportCompletion, range: NSMakeRange(0, (html as NSString).length))
            guard let match = matches.first else {
                return nil
            }
            let result = (html as NSString).substring(with: match.rangeAt(1))
            return result
        } catch {
            return nil
        }
    }
}
