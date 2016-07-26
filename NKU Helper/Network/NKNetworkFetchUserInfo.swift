//
//  NKNetworkFetchUserInfo.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/20/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import Alamofire

enum NKNetworkFetchUserInfoResult {
    case Success(name:String, timeEnteringSchool:String, departmentAdmitted:String, majorAdmitted:String)
    case NetworkError
    case AnalyzeError
}

/// 提供获取用户详细数据的功能
@objc(NKNetworkFetchUserInfo)
class NKNetworkFetchUserInfo: NKNetworkBase {
    
    typealias FetchUserInfoResult = (NKNetworkFetchUserInfoResult) -> Void
    
    var block: FetchUserInfoResult!
    
    /**
     获取用户信息数据
     
     - parameter block: 返回闭包
     */
    func getAllAccountInfoWithBlock(block: FetchUserInfoResult) {
        self.block = block
        Alamofire.request(.GET, "http://222.30.32.10/studymanager/stdbaseinfo/queryAction.do").responseString(encoding: CFStringConvertEncodingToNSStringEncoding(0x0632)) { (response) -> Void in
            guard let html = response.result.value else {
                block(.NetworkError)
                return
            }
            guard let (name, timeEnteringSchool, departmentAdmitted, majorAdmitted) = self.analyzeHtml(html) else {
                block(.AnalyzeError)
                return
            }
            self.block(NKNetworkFetchUserInfoResult.Success(name: name, timeEnteringSchool: timeEnteringSchool, departmentAdmitted: departmentAdmitted, majorAdmitted: majorAdmitted))
        }
    }

    private func analyzeHtml(html: String) -> (name: String, timeEnteringSchool: String, departmentAdmitted: String, majorAdmitted: String)? {
        if let name = findPropertyInHtml(html, para: "姓[^<>]*?名"),
            timeEnteringSchool = findPropertyInHtml(html, para: "入学时间"),
            departmentAdmitted = findPropertyInHtml(html, para: "录取院系"),
            majorAdmitted = findPropertyInHtml(html, para: "录取专业") {
            return (name: name, timeEnteringSchool: timeEnteringSchool, departmentAdmitted: departmentAdmitted, majorAdmitted: majorAdmitted)
        }
        else {
            return nil
        }
    }
    
    dynamic private func findPropertyInHtml(html: String, para: String) -> String? {
        do {
            let reg = try NSRegularExpression(pattern: "<td[^>]*?DetailMsg[^>]*?>" + para + "</td>\\s*?<td[^>]*?NavText[^>]*?>([^<>]*?)</td>", options: .CaseInsensitive)
            let matches = reg.matchesInString(html, options: .ReportCompletion, range: NSMakeRange(0, (html as NSString).length))
            guard let match = matches.first else {
                return nil
            }
            let result = (html as NSString).substringWithRange(match.rangeAtIndex(1))
            return result
        } catch {
            return nil
        }
    }
}