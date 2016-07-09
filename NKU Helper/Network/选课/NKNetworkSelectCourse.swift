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
 - LackOfNumber:     选修剩余名额不足或不在指定的选课年级
 - InputError:       不在最大最小序号范围内
 - TimeConflict:     所选课与已选课程上课时间冲突或不在指定的选课年级
 - AlreadySelected:  课号已选或不在指定的选课年级ß
 - Fail:             没有得到正确的数据
 */
enum NKNetworkSelectCourseResult {
    case Success
    case LackOfNumberOrNotAssignedGrade
    case InputError
    case TimeConflictOrNotAssignedGrade
    case AlreadySelectedOrNotAssignedGrade
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

        doPrepareWorkThenDoBlock { () -> Void in
            
            Alamofire.request(.POST, "http://222.30.32.10/xsxk/swichAction.do", parameters: ["operation" : "xuanke", "xkxh1" : index, "xkxh2":"", "xkxh3":"", "xkxh4":"", "departIncode":"924", "courseindex" : "", "index" : ""]).responseString{ (response: Response<String, NSError>) -> Void in
                guard let result = response.result.value as NSString? else {
                    block(NKNetworkSelectCourseResult.Fail)
                    return
                }
                guard result.rangeOfString("最大最小序号范围内").length > 0 else {
                    block(NKNetworkSelectCourseResult.InputError)
                    return
                }
                guard result.rangeOfString("选课操作失败").length > 0 else {
                    block(NKNetworkSelectCourseResult.Success)
                    return
                }
                guard result.rangeOfString("剩余名额不足").length > 0 else {
                    block(NKNetworkSelectCourseResult.LackOfNumberOrNotAssignedGrade)
                    return
                }
                guard result.rangeOfString("所选课与已选课程上课时间冲突").length > 0 else {
                    block(NKNetworkSelectCourseResult.TimeConflictOrNotAssignedGrade)
                    return
                }
                guard result.rangeOfString("课号已选").length > 0 else {
                    block(NKNetworkSelectCourseResult.AlreadySelectedOrNotAssignedGrade)
                    return
                }
                block(NKNetworkSelectCourseResult.Fail)
            }
        }
    }
    
    func deleteCourseWithCourseIndex(index: String, block:(NKNetworkSelectCourseResult) -> Void) {
        doPrepareWorkThenDoBlock { () -> Void in
            Alamofire.request(.POST, "http://222.30.32.10/xsxk/swichAction.do", parameters: ["operation" : "tuike", "xkxh1" : index, "xkxh2":"", "xkxh3":"", "xkxh4":"", "departIncode":"924", "courseindex" : "", "index" : ""]).responseString{ (response: Response<String, NSError>) -> Void in
                guard let result = response.result.value as NSString? else {
                    block(NKNetworkSelectCourseResult.Fail)
                    return
                }
                guard result.rangeOfString("最大最小序号范围内").length > 0 else {
                    block(NKNetworkSelectCourseResult.InputError)
                    return
                }
                guard result.rangeOfString("选课操作失败").length > 0 else {
                    block(NKNetworkSelectCourseResult.Success)
                    return
                }
                guard result.rangeOfString("剩余名额不足").length > 0 else {
                    block(NKNetworkSelectCourseResult.LackOfNumberOrNotAssignedGrade)
                    return
                }
                guard result.rangeOfString("所选课与已选课程上课时间冲突").length > 0 else {
                    block(NKNetworkSelectCourseResult.TimeConflictOrNotAssignedGrade)
                    return
                }
                guard result.rangeOfString("课号已选").length > 0 else {
                    block(NKNetworkSelectCourseResult.AlreadySelectedOrNotAssignedGrade)
                    return
                }
                block(NKNetworkSelectCourseResult.Fail)
            }

        }
    }
    
    // 一定要先访问这两个网址发选课请求才有用 http://222.30.32.10/xsxk/sub_xsxk.jsp http://222.30.32.10/xsxk/selectMianInitAction.do
    private func doPrepareWorkThenDoBlock(block: () -> Void) {
        Alamofire.request(.GET, "http://222.30.32.10/xsxk/sub_xsxk.jsp").responseString { (response: Response<String, NSError>) -> Void in
            Alamofire.request(.GET, "http://222.30.32.10/xsxk/selectMianInitAction.do").responseString { (response: Response<String, NSError>) -> Void in
                block()
            }
        }
    }
    
    
}