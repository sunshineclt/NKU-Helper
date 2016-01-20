//
//  NKNetworkSelectCourse.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/9/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
//

import Foundation
import Alamofire

 /**
 选课返回状态
 
 - Success:          成功
 - LackOfNumber:     选修剩余名额不足
 - InputError:       不在最大最小序号范围内
 - TimeConflict:     所选课与已选课程上课时间冲突
 - NotAssignedGrade: 不在指定的选课年级
 - AlreadySelected:  课号已选
 - Fail:             没有得到正确的数据
 */
enum NKNetworkSelectCourseResult {
    case Success;
    case LackOfNumber
    case InputError
    case TimeConflict
    case NotAssignedGrade
    case AlreadySelected
    case Fail
}

/// 提供选课功能的网络库
class NKNetworkSelectCourse: NKNetworkBase {
    
    /**
     按照选课序号进行选课
     
     - parameter index: 选课序号
     - parameter block: 返回闭包
     */
    func selectCourseWithCourseIndex(index:String, block:((NKNetworkSelectCourseResult) -> Void)) {

        Alamofire.request(.POST, "http://222.30.32.10/xsxk/swichAction.do", parameters: ["operation" : "xuanke", "xkxh1" : index, "xkxh2":"", "xkxh3":"", "xkxh4":"", "departIncode":"924", "courseindex" : "", "index" : ""], headers : ["Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/601.3.9 (KHTML, like Gecko) Version/9.0.2 Safari/601.3.9", "Accept-Language":"en-us", "Accept-Encoding" : "gzip, deflate", "Content-Type":"application/x-www-form-urlencoded", "Origin":"http://222.30.32.10", "Referer":"http://222.30.32.10/xsxk/selectMianInitAction.do"]).responseString{ (response: Response<String, NSError>) -> Void in
            if let result = response.result.value as NSString? {
                let index1 = result.rangeOfString("<font color=\"#333399\" class=\"BlueBigText\">")
                let index2 = result.rangeOfString("</font></p>")
                print(index1.location)
                print("\n")
                print(index1.length)
                print("\n")
                print(index2.location)
                print("\n")
                print(index2.length)
                //let info = result.substringWithRange(NSMakeRange(index1.location + index1.length, index2.location - (index1.location + index1.length)))
                //ErrorHandler.alert(ErrorHandler.SelectCourseFail)
                block(NKNetworkSelectCourseResult.InputError)
            }
            else {
                block(NKNetworkSelectCourseResult.Fail)
            }
        }
    }
    
}