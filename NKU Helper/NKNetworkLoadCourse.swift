//
//  NKNetworkLoadCourse.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/13/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
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
}

/// 提供获取课程功能的网络库
class NKNetworkLoadCourse: NKNetworkBase {
    
    var delegate:NKNetworkLoadCourseDelegate?
    
    /**
     获取所有课程信息
     */
    func getAllCourse() {
        Alamofire.request(.GET, "http://222.30.32.10/xsxk/selectedAction.do?operation=kebiao").responseString(encoding: CFStringConvertEncodingToNSStringEncoding(0x0632), completionHandler: { (response:Response<String, NSError>) -> Void in
            if let html = response.result.value {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { () -> Void in
                    self.loadAllCourseInfoWithHtml(html)
                    self.delegate?.didSuccessToReceiveCourseData()
                })
            } else {
                self.delegate?.didFailToReceiveCourseData()
            }
        })
    }
    
    private func handleHtml(html:NSString) -> (String, String, String, String, String, String) {
        
        var range = html.rangeOfString("&nbsp;&nbsp;&nbsp;&nbsp;选课序号：")
        let classID = html.substringWithRange(NSMakeRange(range.location + 135, 4))
        
        range = html.rangeOfString(">课程编号：</td>")
        let classNumber = html.substringWithRange(NSMakeRange(range.location + 114, 10))
        
        range = html.rangeOfString("&nbsp;&nbsp;&nbsp;&nbsp;课程名称：")
        var className:NSString = html.substringWithRange(NSMakeRange(range.location + 119, 20))
        while ((className.hasSuffix("\r")) || (className.hasSuffix("\n")) || (className.hasSuffix(" "))) {
            className = className.substringToIndex(className.length - 1)
        }
        
        range = html.rangeOfString("&nbsp;&nbsp;&nbsp;&nbsp;单&nbsp;双&nbsp;周：</td>")
        var weekOddEven:NSString = html.substringWithRange(NSMakeRange(range.location + 130, 20))
        while ((weekOddEven.hasSuffix("\r")) || (weekOddEven.hasSuffix("\n")) || (weekOddEven.hasSuffix(" "))) {
            weekOddEven = weekOddEven.substringToIndex(weekOddEven.length - 1)
        }
        
        range = html.rangeOfString("教&nbsp;&nbsp;&nbsp;&nbsp;室：</td>")
        var classroom:NSString = html.substringWithRange(NSMakeRange(range.location + 120, 15))
        while ((classroom.hasSuffix("\r")) || (classroom.hasSuffix("\n")) || (classroom.hasSuffix(" "))) {
            classroom = classroom.substringToIndex(classroom.length - 1)
        }
        
        range = html.rangeOfString(">教师姓名：</td>")
        var teacherName:NSString = html.substringWithRange(NSMakeRange(range.location + 98, 10))
        while ((teacherName.hasSuffix("\r")) || (teacherName.hasSuffix("\n")) || (teacherName.hasSuffix(" "))) {
            teacherName = teacherName.substringToIndex(teacherName.length - 1)
        }
        
        return (classID as String, classNumber as String, className as String, weekOddEven as String, classroom as String, teacherName as String)
    }
    
    private func loadAllCourseInfoWithHtml(html:NSString) {
        let regularExpression1:NSRegularExpression = try! NSRegularExpression(pattern: "(coursearrangeseq=.*)(&&classroomincode=.*)(&&week=.*)(&&begphase=.*)(&&ifkebiao=yes)", options: NSRegularExpressionOptions.CaseInsensitive)
        let matches:NSArray = regularExpression1.matchesInString(html as String, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, html.length))
        var day:Int = 0
        var startSection:Int = 1
        let courses:NSMutableArray = NSMutableArray()
        var courseCount:Int = -1
        let courseStatus:NSMutableArray = NSMutableArray()
        var eachDaySectionCourseStatus:NSMutableArray = NSMutableArray()
        for (var i=0;i<matches.count;i++) {
            let presentRange = matches.objectAtIndex(i) as! NSTextCheckingResult
            if presentRange.range.length > 67 {
                let urlString = "http://222.30.32.10/xsxk/selectedAllAction.do?" + html.substringWithRange(presentRange.range)
                let url:NSURL = NSURL(string: urlString)!
                let req:NSURLRequest = NSURLRequest(URL: url)
                let receivedData = try! NSURLConnection.sendSynchronousRequest(req, returningResponse: nil)
                let encoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
                let courseDetailInfoHtml = NSString(data: receivedData, encoding: encoding)!
                
                let subString:NSString = html.substringWithRange(NSMakeRange(presentRange.range.location - 98, 2))
                let sectionNumber:Int = subString.integerValue / 15
                
                var classID,classNumber,className,weekOddEven,classroom,teacherName:String
                (classID,classNumber,className,weekOddEven,classroom,teacherName) = self.handleHtml(courseDetailInfoHtml)
                let courseDetailInfo = Course(ID: classID, number: classNumber, name: className, classroom: classroom, weekOddEven: weekOddEven, teacherName: teacherName, day: day, startSection: startSection, sectionNumber: sectionNumber)
                
                let data = NSKeyedArchiver.archivedDataWithRootObject(courseDetailInfo)
                courses.addObject(data)
                courseCount++
                for (var j=0;j<sectionNumber;j++) {
                    eachDaySectionCourseStatus.addObject(courseCount)
                }
                startSection = startSection + sectionNumber
                if startSection > 14 {
                    day++
                    startSection = 1
                    courseStatus.addObject(eachDaySectionCourseStatus)
                    eachDaySectionCourseStatus = NSMutableArray()
                }
                
                
            }
            else {
                startSection++
                eachDaySectionCourseStatus.addObject(-1)
                if startSection > 14 {
                    day++
                    startSection = 1
                    courseStatus.addObject(eachDaySectionCourseStatus)
                    eachDaySectionCourseStatus = NSMutableArray()
                }
            }
            let progress:Float = (Float(i + 1)) / Float(matches.count)
            delegate?.loadProgressUpdate(progress)            
        }
        
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey("courses")
        userDefaults.removeObjectForKey("courseStatus")
        userDefaults.setObject(courses, forKey: "courses")
        userDefaults.setObject(courseStatus, forKey: "courseStatus")
        userDefaults.synchronize()
        //   drawClassTimeTable()
    }
    
}
