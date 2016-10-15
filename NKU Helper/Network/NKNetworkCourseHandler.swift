//
//  NKNetworkCourseLoadHandler.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/13/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import Alamofire

/// 课程获取的代理事件
protocol NKNetworkLoadCourseDelegate {
    /// 成功导入课程数据
    func didSuccessToReceiveCourseData()
    /// 接收课程数据失败
    func didFailToReceiveCourseData()
    /// 更新加载进度
    ///
    /// - parameter progress: 进度
    func updateLoadProgress(_ progress: Float)
    /// 存储课程数据失败
    func didFailToSaveCourseData()
}

/**
 获取课程的网络库
 * * * * *
 
 last modified:
 - date: 2016.10.12
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
@objc(NKNetworkCourseHandler)
class NKNetworkCourseHandler: NKNetworkBase {
    
    /// 代理
    var delegate: NKNetworkLoadCourseDelegate?
    
    /// 获取所有课程信息
    /// - note: 会根据存储的加载方式加载课程信息
    func getAllCourses() {
        let classLoadMethod = CourseLoadMethodAgent.sharedInstance.getData()
        classLoadMethod == 0 ? loadCourseFromClassTimeTable() : loadCourseFromClassTable()
    }
    
    /// 从课程表页面获取课程信息
    dynamic func loadCourseFromClassTimeTable() {
        Alamofire.request("http://222.30.32.10/xsxk/selectedAction.do?operation=kebiao").responseString { (response) in
            guard let html = response.result.value else {
                self.delegate?.didFailToReceiveCourseData()
                return
            }
            DispatchQueue.global().async {
                let saveOK = self.analyzeClassTimeTableHtml(html)
                if saveOK {
                    self.delegate?.didSuccessToReceiveCourseData()
                }
                else {
                    self.delegate?.didFailToSaveCourseData()
                }
            }
        }
    }
    
    /// 分析课程表html
    ///
    /// - parameter html: html
    ///
    /// - returns: 是否分析成功
    dynamic private func analyzeClassTimeTableHtml(_ html: String) -> Bool {
        let htmlNSString = html as NSString
        let regularExpression1 = try! NSRegularExpression(pattern: "<td[^<>]*?height=\"(\\d*?)\"[^<>]*?>\\s*?.*?(coursearrangeseq=.*?&&classroomincode=.*?&&week=.*?&&begphase=.*?&&ifkebiao=yes)", options: .caseInsensitive)
        let matches = regularExpression1.matches(in: html, options: .reportProgress, range: NSMakeRange(0, htmlNSString.length))
        do {
            try Task.deleteCourseTasks()
            try CourseTime.deleteAllCourseTimes()
            try Course.deleteAllCourses()
            var day = 0
            var startSection = 1
            for i in 0 ..< matches.count {
                let match = matches[i]
                if match.range.length > 190 {
                    // 说明是一个课程方格
                    let urlString = "http://222.30.32.10/xsxk/selectedAllAction.do?" + htmlNSString.substring(with: match.rangeAt(2))
                    let url = URL(string: urlString)!
                    
                    let subString = htmlNSString.substring(with: match.rangeAt(1)) as NSString
                    let sectionNumber = subString.integerValue / 15
                    
                    do {
                        try saveDetailClassInfoWith(URL: url, startSection: startSection, sectionNumber: sectionNumber, index: i)
                    }
                    catch {
                        CourseLoadedAgent.sharedInstance.signCourseToUnloaded()
                        return false
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
                delegate?.updateLoadProgress(progress)
            }
            CourseLoadedAgent.sharedInstance.signCourseToLoaded()
            return true
        } catch {
            CourseLoadedAgent.sharedInstance.signCourseToUnloaded()
            return false
        }
    }
    
    /// 从课程列表加载课程
    dynamic private func loadCourseFromClassTable() {
        Alamofire.request("http://222.30.32.10/xsxk/selectedAction.do").responseString { (response) in
            guard let html = response.result.value else {
                self.delegate?.didFailToReceiveCourseData()
                return
            }
            DispatchQueue.global().async {
                let pageExtractor = try! NSRegularExpression(pattern: "共 (\\d) 页,第 (\\d) 页 ", options: .caseInsensitive)
                let match = pageExtractor.matches(in: html, options: .reportProgress, range: NSMakeRange(0, (html as NSString).length))[0]
                self.nowPage = ((html as NSString).substring(with: match.rangeAt(2)) as NSString).integerValue
                self.totalPage = ((html as NSString).substring(with: match.rangeAt(1)) as NSString).integerValue
                // 清空之前的课表数据
                do {
                    try Task.deleteCourseTasks()
                    try CourseTime.deleteAllCourseTimes()
                    try Course.deleteAllCourses()
                } catch {
                    CourseLoadedAgent.sharedInstance.signCourseToUnloaded()
                    self.delegate?.didFailToSaveCourseData()
                }
                let saveOK = self.analyzeClassListHtml(html)
                if saveOK {
                    if self.nowPage == self.totalPage {
                        self.delegate?.didSuccessToReceiveCourseData()
                    }
                    else {
                        self.loadNextPageClassTable()
                    }
                }
                else {
                    self.delegate?.didFailToSaveCourseData()
                }
            }
        }
    }

    /// 加载课程列表下一页
    dynamic private func loadNextPageClassTable() {
        Alamofire.request("http://222.30.32.10/xsxk/selectedPageAction.do?page=next").responseString { (response) in
            guard let html = response.result.value else {
                self.delegate?.didFailToReceiveCourseData()
                return
            }
            DispatchQueue.global().async {
                let pageExtractor = try! NSRegularExpression(pattern: "共 (\\d) 页,第 (\\d) 页 ", options: .caseInsensitive)
                let match = pageExtractor.matches(in: html, options: .reportProgress, range: NSMakeRange(0, (html as NSString).length))[0]
                self.nowPage = ((html as NSString).substring(with: match.rangeAt(2)) as NSString).integerValue
                self.totalPage = ((html as NSString).substring(with: match.rangeAt(1)) as NSString).integerValue
                let saveOK = self.analyzeClassListHtml(html)
                if saveOK {
                    if self.nowPage == self.totalPage {
                        self.delegate?.didSuccessToReceiveCourseData()
                    }
                    else {
                        self.loadNextPageClassTable()
                    }
                }
                else {
                    self.delegate?.didFailToSaveCourseData()
                }
            }
        }
    }
    
    /// 现在加载到课程列表第几页
    private var nowPage = 0
    /// 课程列表一共有几页
    private var totalPage = 0
    
    /// 分析课程列表html
    ///
    /// - parameter html: html
    ///
    /// - returns: 是否分析成功
    dynamic private func analyzeClassListHtml(_ html: String) -> Bool {
        let htmlNSString = html as NSString
        let regularExpression1 = try! NSRegularExpression(pattern: "<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>(\\S*?)\\s*?</td>\\s*?<td[^<>]*?NavText\"[^<>]*?>\\s*?<a[^<>]*?href=\".*?&amp;(.*?)\".*?</a>\\s*?</td>", options: .caseInsensitive)
        let matches = regularExpression1.matches(in: html, options: .reportProgress, range: NSMakeRange(0, htmlNSString.length))
        for i in 0..<matches.count {
            let match = matches[i]
            let index = (htmlNSString.substring(with: match.rangeAt(1)) as NSString).integerValue
            let startSection = (htmlNSString.substring(with: match.rangeAt(6)) as NSString).integerValue
            let endSection = (htmlNSString.substring(with: match.rangeAt(7)) as NSString).integerValue
            let url = URL(string: "http://222.30.32.10/xsxk/selectedAllAction.do?ifkebiao=no&" + htmlNSString.substring(with: match.rangeAt(13)))!
            do {
                try saveDetailClassInfoWith(URL: url, startSection: startSection, sectionNumber: endSection - startSection + 1, index: index)
            }
            catch {
                CourseLoadedAgent.sharedInstance.signCourseToUnloaded()
                return false
            }
            let progress = (Float(i + 1)) / Float(matches.count) * Float(nowPage) / Float(totalPage)
            delegate?.updateLoadProgress(progress)
        }
        CourseLoadedAgent.sharedInstance.signCourseToLoaded()
        return true
    }

    /// 加载、分析并保存课程详细信息
    ///
    /// - parameter url:           要加载的url
    /// - parameter startSection:  开始的节数
    /// - parameter sectionNumber: 持续的节数
    /// - parameter index:         唯一标识符
    ///
    /// - throws: StoragedDataError.realmError
    ///
    /// - returns: 带有详细信息的课程实例
    dynamic private func saveDetailClassInfoWith(URL url: URL, startSection: Int, sectionNumber: Int, index: Int) throws {
        let receivedData = try! Data(contentsOf: url)
        let encoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
        let courseDetailInfoHtml = NSString(data: receivedData, encoding: encoding) as! String

        let classID = getProperty(inHtml: courseDetailInfoHtml, para: "选课序号")
        let classNumber = getProperty(inHtml: courseDetailInfoHtml, para: "课程编号")
        let className = getProperty(inHtml: courseDetailInfoHtml, para: "课程名称")
        let weekday = (getProperty(inHtml: courseDetailInfoHtml, para: "期") as NSString).integerValue
        let weekOddEven = getProperty(inHtml: courseDetailInfoHtml, para: "单.*?双.*?周")
        let classroom = getProperty(inHtml: courseDetailInfoHtml, para: "室")
        let teacherName = getProperty(inHtml: courseDetailInfoHtml, para: "教师姓名")
        let startWeek = (getProperty(inHtml: courseDetailInfoHtml, para: "开始周次") as NSString).integerValue
        let endWeek = (getProperty(inHtml: courseDetailInfoHtml, para: "结束周次") as NSString).integerValue
        try Course.saveCourseTimeWith(key: index, ID: classID, number: classNumber, name: className, classroom: classroom, weekOddEven: weekOddEven, teacherName: teacherName, weekday: weekday, startSection: startSection, sectionNumber: sectionNumber, startWeek: startWeek, endWeek: endWeek)
    }
    
    /// 提取课程详细信息中的内容
    ///
    /// - parameter html: html
    /// - parameter para: 需要提取的参数
    ///
    /// - returns: 参数对应的内容
    dynamic private func getProperty(inHtml html: String, para: String) -> String {
        let regularExpression = try! NSRegularExpression(pattern: para + ".*?</td>\\s*?<td[^<>]*?NavText[^<>]*?>\\s*(.*?)\\s*</td>", options: .caseInsensitive)
        let matches = regularExpression.matches(in: html, options: .reportCompletion, range: NSMakeRange(0, (html as NSString).length))
        guard let match = matches.first else {
            return "未知"
        }
        return (html as NSString).substring(with: match.rangeAt(1))
    }
    
}
