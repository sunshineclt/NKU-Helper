//
//  NKNetworkLoadCourse.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/13/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import Alamofire

/**
 *  课程获取的代理事件
 */
protocol NKNetworkLoadCourseDelegate {
    func didSuccessToReceiveCourseData()
    func didFailToReceiveCourseData()
    func loadProgressUpdate(progress: Float)
    func didFailToSaveCourseData()
}

/// 提供获取课程功能的网络库
@objc(NKNetworkLoadCourse)
class NKNetworkLoadCourse: NKNetworkBase {
    
    var delegate:NKNetworkLoadCourseDelegate?
    
    /**
     获取所有课程信息
     */
    func getAllCourse() {
        let classLoadMethod = CourseLoadMethodAgent.sharedInstance.getData()
        if classLoadMethod == 0 {
            loadCourseFromClassTimeTable()
        }
        else {
            loadCourseFromClassTable()
        }
    }
    
    // 从课程表获取课程
    dynamic func loadCourseFromClassTimeTable() {
        Alamofire.request(.GET, "http://222.30.32.10/xsxk/selectedAction.do?operation=kebiao").responseString { (response) in
            guard let html = response.result.value else {
                self.delegate?.didFailToReceiveCourseData()
                return
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let saveOK = self.analyzeClassTimeTableHtml(html)
                saveOK ? self.delegate?.didSuccessToReceiveCourseData() : self.delegate?.didFailToSaveCourseData()
            })
        }
    }
    
    // 分析课程表html
    dynamic private func analyzeClassTimeTableHtml(html: String) -> Bool {
        let htmlNSString = html as NSString
        let regularExpression1 = try! NSRegularExpression(pattern: "<td[^<>]*?height=\"(\\d*?)\"[^<>]*?>\\s*?.*?(coursearrangeseq=.*?&&classroomincode=.*?&&week=.*?&&begphase=.*?&&ifkebiao=yes)", options: .CaseInsensitive)
        let matches = regularExpression1.matchesInString(html, options: .ReportProgress, range: NSMakeRange(0, htmlNSString.length))
        do {
            try Task.deleteCourseTasks()
            try CourseTime.deleteAll()
            try Course.deleteAllCourses()
            var day = 0
            var startSection = 1
            for i in 0 ..< matches.count {
                let match = matches[i]
                if match.range.length > 190 {
                    let urlString = "http://222.30.32.10/xsxk/selectedAllAction.do?" + htmlNSString.substringWithRange(match.rangeAtIndex(2))
                    let url = NSURL(string: urlString)!
                    
                    let subString = htmlNSString.substringWithRange(match.rangeAtIndex(1)) as NSString
                    let sectionNumber = subString.integerValue / 15
                    
                    if let course = loadDetailClassInfo(url, startSection: startSection, sectionNumber: sectionNumber, index: i) {
                        try Course.saveCourses([course])
                    }
                    startSection = startSection + sectionNumber
                    if startSection > 14 {
                        day += 1
                        startSection = 1
                    }
                }
                else {
                    startSection += 1
                    if startSection > 14 {
                        day += 1
                        startSection = 1
                    }
                }
                let progress = (Float(i + 1)) / Float(matches.count)
                delegate?.loadProgressUpdate(progress)            
            }
            CourseAgent.sharedInstance.signCourseToLoaded()
            return true
        } catch {
            CourseAgent.sharedInstance.signCourseToUnloaded()
            return false
        }
    }
    
    // 从课程列表加载课程
    dynamic private func loadCourseFromClassTable() {
        Alamofire.request(.GET, "http://222.30.32.10/xsxk/selectedAction.do").responseString { (response) in
            guard let html = response.result.value else {
                self.delegate?.didFailToReceiveCourseData()
                return
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                let saveOK = self.analyzeClassListHtml(html)
                saveOK ? self.delegate?.didSuccessToReceiveCourseData() : self.delegate?.didFailToSaveCourseData()
            })
        }
    }
    
    dynamic private func analyzeClassListHtml(html: String) -> Bool {
        let htmlNSString = html as NSString
        let regularExpression1 = try! NSRegularExpression(pattern: "<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>\\s*?<a[^<>]*?href=\".*?&amp;(.*?)\".*?</a>\\s*?</td>", options: .CaseInsensitive)
        let matches = regularExpression1.matchesInString(html, options: .ReportProgress, range: NSMakeRange(0, htmlNSString.length))
        do {
            try Task.deleteCourseTasks()
            try CourseTime.deleteAll()
            try Course.deleteAllCourses()
            for i in 0..<matches.count {
                let match = matches[i]
                let index = (htmlNSString.substringWithRange(match.rangeAtIndex(1)) as NSString).integerValue
                let startSection = (htmlNSString.substringWithRange(match.rangeAtIndex(6)) as NSString).integerValue
                let endSection = (htmlNSString.substringWithRange(match.rangeAtIndex(7)) as NSString).integerValue
                let url = NSURL(string: "http://222.30.32.10/xsxk/selectedAllAction.do?ifkebiao=no&" + htmlNSString.substringWithRange(match.rangeAtIndex(13)))!
                if let course = loadDetailClassInfo(url, startSection: startSection, sectionNumber: endSection - startSection + 1, index: index) {
                    try Course.saveCourses([course])
                }
                let progress = (Float(i + 1)) / Float(matches.count)
                delegate?.loadProgressUpdate(progress)
            }
            CourseAgent.sharedInstance.signCourseToLoaded()
            return true
        } catch {
            CourseAgent.sharedInstance.signCourseToUnloaded()
            return false
        }
    }
    
    // 加载并分析课程详细信息
    dynamic private func loadDetailClassInfo(url: NSURL, startSection: Int, sectionNumber: Int, index: Int) -> Course? {
        let receivedData = NSData(contentsOfURL: url)!
        let encoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
        let courseDetailInfoHtml = NSString(data: receivedData, encoding: encoding) as! String

        let classID = getProperty(courseDetailInfoHtml, para: "选课序号")
        let classNumber = getProperty(courseDetailInfoHtml, para: "课程编号")
        let className = getProperty(courseDetailInfoHtml, para: "课程名称")
        let weekday = (getProperty(courseDetailInfoHtml, para: "期") as NSString).integerValue
        let weekOddEven = getProperty(courseDetailInfoHtml, para: "单.*?双.*?周")
        let classroom = getProperty(courseDetailInfoHtml, para: "室")
        let teacherName = getProperty(courseDetailInfoHtml, para: "教师姓名")
        let startWeek = (getProperty(courseDetailInfoHtml, para: "开始周次") as NSString).integerValue
        let endWeek = (getProperty(courseDetailInfoHtml, para: "结束周次") as NSString).integerValue
        let course = Course.addCourseTime(key: index, ID: classID, number: classNumber, name: className, classroom: classroom, weekOddEven: weekOddEven, teacherName: teacherName, weekday: weekday, startSection: startSection, sectionNumber: sectionNumber, startWeek: startWeek, endWeek: endWeek)
        return course
    }
    
    // 用于提取课程详细信息中的内容
    dynamic private func getProperty(html: String, para: String) -> String {
        let regularExpression = try! NSRegularExpression(pattern: para + ".*?</td>\\s*?<td[^<>]*?NavText[^<>]*?>\\s*(.*?)\\s*</td>", options: .CaseInsensitive)
        let matches = regularExpression.matchesInString(html, options: .ReportCompletion, range: NSMakeRange(0, (html as NSString).length))
        guard let match = matches.first else {
            return "未知"
        }
        return (html as NSString).substringWithRange(match.rangeAtIndex(1))
    }
    
}
