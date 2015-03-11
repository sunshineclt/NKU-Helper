//
//  ClassTimeViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/1.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class ClassTimeViewController: UIViewController, NSURLConnectionDataDelegate {
    
    @IBOutlet var classTimeTableWebView: UIWebView!
    var receivedData:NSMutableData! = nil
    
    override func viewDidLoad() {
        
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var accountInfo:NSDictionary? = userDefaults.objectForKey("accountInfo") as NSDictionary?
        if let temp = accountInfo {
            
            var courses:NSArray? = userDefaults.objectForKey("courses") as NSArray?
            if let temp = courses {
                var req:NSURLRequest = NSURLRequest(URL: NSURL(string: "http://222.30.32.10/xsxk/selectedAction.do?operation=kebiao")!)
                classTimeTableWebView.loadRequest(req)
            }
            else {
                if isLogIn() {
                    
                    var req:NSURLRequest = NSURLRequest(URL: NSURL(string: "http://222.30.32.10/xsxk/selectedAction.do?operation=kebiao")!)
                    classTimeTableWebView.loadRequest(req)
                    var connection:NSURLConnection? = NSURLConnection(request: req, delegate: self)
                    if let temp = connection {
                        receivedData = NSMutableData()
                    }
                    else {
                        var alert:UIAlertView = UIAlertView(title: "错误", message: "没有网络你让我怎么查课表捏？", delegate: nil, cancelButtonTitle: "好吧，那我去弄点网")
                    }
                }
                else {
                    self.performSegueWithIdentifier("login", sender: nil)
                }
            }
        }
            
        else {
            
            var alert:UIAlertView = UIAlertView(title: "请先登录", message: "登陆后方可查看课表，请到设置中登录！", delegate: nil, cancelButtonTitle: "知道了！")
            alert.show()
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "refreshClassTimeTable1", name: "loginComplete", object: nil)
    }
    
    func refreshClassTimeTable1() {
        refreshClassTimeTable("")
    }
    
    func isLogIn() -> Bool {
        var req:NSURLRequest = NSURLRequest(URL: NSURL(string: "http://222.30.32.10/xsxk/selectedAction.do?operation=kebiao")!)
        var response:NSHTTPURLResponse = NSHTTPURLResponse()
        var receivedData:NSData = NSURLConnection.sendSynchronousRequest(req, returningResponse: nil, error: nil)!
        var encoding:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
        var html:NSString = NSString(data: receivedData, encoding: encoding)!
        if html.rangeOfString("星期一").length > 0 {
            return true
        }
        else{
            return false
        }
    }
    
    func handleHtml(html:NSString) -> (NSString!, NSString!, NSString!, NSString!, NSString!, NSString!) {
        
        var range = html.rangeOfString("&nbsp;&nbsp;&nbsp;&nbsp;选课序号：")
        var classID = html.substringWithRange(NSMakeRange(range.location + 135, 4))
        
        range = html.rangeOfString(">课程编号：</td>")
        var classNumber = html.substringWithRange(NSMakeRange(range.location + 114, 10))
        
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
        
        return (classID, classNumber, className, weekOddEven, classroom, teacherName)
    }
    
    func loadAllCourseInfoWithHtml(html:NSString) {
        var regularExpression1:NSRegularExpression = NSRegularExpression(pattern: "(coursearrangeseq=.*)(&&classroomincode=.*)(&&week=.*)(&&begphase=.*)(&&ifkebiao=yes)", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!
        var matches:NSArray = regularExpression1.matchesInString(html, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, html.length))
        var day:Int = 1
        var startSection:Int = 1
        var courses:NSMutableArray = NSMutableArray()
        var courseCount:Int = -1
        var courseStatus:NSMutableArray = NSMutableArray()
        var eachDaySectionCourseStatus:NSMutableArray = NSMutableArray()
        for (var i=0;i<matches.count;i++) {
            var presentRange = matches.objectAtIndex(i) as NSTextCheckingResult
            if presentRange.range.length > 67 {
                var urlString = "http://222.30.32.10/xsxk/selectedAllAction.do?" + html.substringWithRange(presentRange.range)
                var url:NSURL = NSURL(string: urlString)!
                var req:NSURLRequest = NSURLRequest(URL: url)
                var receivedData:NSData = NSURLConnection.sendSynchronousRequest(req, returningResponse: nil, error: nil)!
                var encoding:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
                var courseDetailInfoHtml:NSString = NSString(data: receivedData, encoding: encoding)!
                
                var subString:NSString = html.substringWithRange(NSMakeRange(presentRange.range.location - 98, 2))
                var sectionNumber:Int = subString.integerValue / 23
                
                var classID,classNumber,className,weekOddEven,classroom,teacherName:NSString!
                (classID,classNumber,className,weekOddEven,classroom,teacherName) = handleHtml(courseDetailInfoHtml)
                var courseDetailInfo:NSMutableDictionary = NSMutableDictionary()
                courseDetailInfo.setObject(classID, forKey: "classID")
                courseDetailInfo.setObject(classNumber, forKey: "classNumber")
                courseDetailInfo.setObject(className, forKey: "className")
                courseDetailInfo.setObject(weekOddEven, forKey: "weekOddEven")
                courseDetailInfo.setObject(classroom, forKey: "classroom")
                courseDetailInfo.setObject(teacherName, forKey: "teacherName")
                courseDetailInfo.setObject(day, forKey: "day")
                courseDetailInfo.setObject(startSection, forKey: "startSection")
                courseDetailInfo.setObject(sectionNumber, forKey: "sectionNumber")
                
                courses.addObject(courseDetailInfo)
                courseCount++
                for (var j=0;j<sectionNumber;j++) {
                    eachDaySectionCourseStatus.addObject(courseCount)
                }
                startSection = startSection + sectionNumber
                if startSection > 12 {
                    day++
                    startSection = 1
                    courseStatus.addObject(eachDaySectionCourseStatus)
                    eachDaySectionCourseStatus = NSMutableArray()
                }
            }
            else {
                startSection++
                eachDaySectionCourseStatus.addObject(-1)
                if startSection > 12 {
                    day++
                    startSection = 1
                    courseStatus.addObject(eachDaySectionCourseStatus)
                    eachDaySectionCourseStatus = NSMutableArray()
                }
            }
            
            
        }
        
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey("courses")
        userDefaults.removeObjectForKey("courseStatus")
        userDefaults.setObject(courses, forKey: "courses")
        userDefaults.setObject(courseStatus, forKey: "courseStatus")
        userDefaults.synchronize()
        
    }
    
    @IBAction func refreshClassTimeTable(sender: AnyObject) {
        
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var accountInfo:NSDictionary? = userDefaults.objectForKey("accountInfo") as NSDictionary?
        if let temp = accountInfo {
            
            if isLogIn() {
                
                var courses:NSArray? = userDefaults.objectForKey("courses") as NSArray?
                var req:NSURLRequest = NSURLRequest(URL: NSURL(string: "http://222.30.32.10/xsxk/selectedAction.do?operation=kebiao")!)
                classTimeTableWebView.loadRequest(req)
                var connection:NSURLConnection? = NSURLConnection(request: req, delegate: self)
                if let temp = connection {
                    receivedData = NSMutableData()
                }
                else {
                    var alert:UIAlertView = UIAlertView(title: "错误", message: "没有网络你让我怎么查课表捏？", delegate: nil, cancelButtonTitle: "好吧，那我去弄点网")
                }
                
            }
            else {
                self.performSegueWithIdentifier("login", sender: nil)
            }
        }
            
        else {
            //  self.performSegueWithIdentifier("saveAccountInfo", sender: nil)
            var alert:UIAlertView = UIAlertView(title: "请先登录", message: "登陆后方可查看课表，请到设置中登录！", delegate: nil, cancelButtonTitle: "知道了！")
            alert.show()
        }
        
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.receivedData.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        var encoding:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
        var html:NSString = NSString(data: self.receivedData!, encoding: encoding)!
        loadAllCourseInfoWithHtml(html)
        /*    var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var courses:NSMutableArray = userDefaults.objectForKey("courses") as NSMutableArray
        for (var i=0;i<courses.count;i++) {
        var currentCourse:NSDictionary = courses.objectAtIndex(i) as NSDictionary
        var classID = currentCourse.objectForKey("classID") as NSString
        var classNumber = currentCourse.objectForKey("classNumber") as NSString
        var className = currentCourse.objectForKey("className") as NSString
        var weekOddEven = currentCourse.objectForKey("weekOddEven") as NSString
        var classroom = currentCourse.objectForKey("classroom") as NSString
        var teacherName = currentCourse.objectForKey("teacherName") as NSString
        var day = currentCourse.objectForKey("day") as Int
        var startSection = currentCourse.objectForKey("startSection") as Int
        var sectionNumber = currentCourse.objectForKey("sectionNumber") as Int
        print("\nclassID=\(classID) classNumber=\(classNumber) className=\(className) weekOddEven=\(weekOddEven) classroom=\(classroom) teacherName=\(teacherName) 星期\(day)第\(startSection)节--第\(startSection + sectionNumber - 1)节\n")
        }
        */
    }
    
}