//
//  ClassTimeViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/1.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class ClassTimeViewController: UIViewController, NSURLConnectionDataDelegate, UIScrollViewDelegate {
    
    @IBOutlet var shadowView: UIView!
    @IBOutlet var classScrollView: UIScrollView!
    @IBOutlet var refreshBarButton: UIBarButtonItem!
    
    var UALoadView:UAProgressView!
    var overlayView:UIView!
    
    var receivedData:NSMutableData! = nil
    
    let rowHeight:CGFloat = 50
    let columnWidth:CGFloat = UIScreen.mainScreen().bounds.width / 8
    
    let colors:NSArray = [
        UIColor(red: 190/255, green: 150/255, blue: 210/255, alpha: 1),
        UIColor(red: 168/255, green: 239/255, blue: 233/255, alpha: 1),
        UIColor(red: 193/255, green: 233/255, blue: 241/255, alpha: 1),
        UIColor(red: 186/255, green: 241/255, blue: 209/255, alpha: 1),
        UIColor(red: 34/255, green: 202/255, blue: 179/255, alpha: 1),
        UIColor(red: 230/255, green: 225/255, blue: 187/255, alpha: 1),
        UIColor(red: 236/255, green: 206/255, blue: 178/255, alpha: 1),
        UIColor(red: 217/255, green: 189/255, blue: 126/255, alpha: 0.9),
        UIColor(red: 241/255, green: 174/255, blue: 165/255, alpha: 1),
        UIColor(red: 250/255, green: 98/255, blue: 110/255, alpha: 0.8)]
    
    // MARK: MethodsRelatedToGetCourseData
    
    override func viewDidLoad() {

        drawBackground()
        
        var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "refreshClassTimeTable:", name: "loginComplete", object: nil)
        
        classScrollView.delegate = self
        
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var accountInfo:NSDictionary? = userDefaults.objectForKey("accountInfo") as! NSDictionary?
        if let temp = accountInfo {
            
            var courses:NSArray? = userDefaults.objectForKey("courses") as! NSArray?
            if let temp = courses {
                drawClassTimeTable()
            }
            else {
                switch isLogIn() {
                case 1:
                    var req:NSURLRequest = NSURLRequest(URL: NSURL(string: "http://222.30.32.10/xsxk/selectedAction.do?operation=kebiao")!)
                    var connection:NSURLConnection? = NSURLConnection(request: req, delegate: self)
                    if let temp = connection {
                        loadBeginAnimation()
                        receivedData = NSMutableData()
                    }
                    else {
                        var alert:UIAlertView = UIAlertView(title: "错误", message: "没有网络你让我怎么查课表捏？", delegate: nil, cancelButtonTitle: "好吧，那我去弄点网")
                        alert.show()
                    }
                case 0:
                    self.performSegueWithIdentifier("login", sender: nil)
                default:
                    var alertView:UIAlertView = UIAlertView(title: "网络错误", message: "木有网我没法加载课程表诶", delegate: nil, cancelButtonTitle: "知道啦")
                    alertView.show()
                }
            }
        }
            
        else {
            
            var alert:UIAlertView = UIAlertView(title: "请先登录", message: "登陆后方可查看课表，请到设置中登录！", delegate: nil, cancelButtonTitle: "知道了！")
            alert.show()
            
        }
        
      
    }

    func isLogIn() -> Int {
        var req:NSURLRequest = NSURLRequest(URL: NSURL(string: "http://222.30.32.10/xsxk/selectedAction.do?operation=kebiao")!)
        var response:NSHTTPURLResponse = NSHTTPURLResponse()
        var receivedData:NSData? = NSURLConnection.sendSynchronousRequest(req, returningResponse: nil, error: nil)
        if let temp = receivedData {
            var encoding:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
            var html:NSString = NSString(data: receivedData!, encoding: encoding)!
            if html.rangeOfString("星期一").length > 0 {
                return 1
            }
            else{
                return 0
            }
        }
        else {
            return -1
        }
    }
    
    // MARK: 解析html数据以获得课程数据
    
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
        print("\n")
        print("Start Get Course Info")
        var regularExpression1:NSRegularExpression = NSRegularExpression(pattern: "(coursearrangeseq=.*)(&&classroomincode=.*)(&&week=.*)(&&begphase=.*)(&&ifkebiao=yes)", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!
        var matches:NSArray = regularExpression1.matchesInString(html as String, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, html.length))
        var day:Int = 0
        var startSection:Int = 1
        var courses:NSMutableArray = NSMutableArray()
        var courseCount:Int = -1
        var courseStatus:NSMutableArray = NSMutableArray()
        var eachDaySectionCourseStatus:NSMutableArray = NSMutableArray()
        for (var i=0;i<matches.count;i++) {
            var presentRange = matches.objectAtIndex(i) as! NSTextCheckingResult
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
                (classID,classNumber,className,weekOddEven,classroom,teacherName) = self.handleHtml(courseDetailInfoHtml)
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
            var progress:Float = (Float(i + 1)) / Float(matches.count)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.loadAnimation(progress)

            })
            
        }
        
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey("courses")
        userDefaults.removeObjectForKey("courseStatus")
        userDefaults.setObject(courses, forKey: "courses")
        userDefaults.setObject(courseStatus, forKey: "courseStatus")
        userDefaults.synchronize()
        drawClassTimeTable()
    }
    
    // MARK: 绘制课程表
    
    func drawBackground() {
    
        classScrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, 50*12)
        
        for (var i=0;i<=11;i++) {
            var row:UIView = UIView(frame: CGRectMake(0, CGFloat(i) * rowHeight, UIScreen.mainScreen().bounds.width, CGFloat(rowHeight)))
            row.backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1)
            row.layer.borderWidth = 0.5
            row.layer.borderColor = UIColor(red: 216/255, green: 224/255, blue: 226/255, alpha: 1).CGColor
            
            var time:UILabel = UILabel(frame: CGRectMake(5, 5, 30, 20))
            time.adjustsFontSizeToFitWidth = true
            time.textAlignment = NSTextAlignment.Center
            time.textColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1)
            
            var section:UILabel = UILabel(frame: CGRectMake(0, 25, 40, 20))
            section.adjustsFontSizeToFitWidth = true
            section.textAlignment = NSTextAlignment.Center
            section.textColor = UIColor(red: 104/255, green: 102/255, blue: 102/255, alpha: 1)
            
            switch i {
            case 0:
                time.text = "8:00"
                section.text = "1"
            case 1:
                time.text = "8:55"
                section.text = "2"
            case 2:
                time.text = "10:00"
                section.text = "3"
            case 3:
                time.text = "10:55"
                section.text = "4"
            case 4:
                time.text = "14:00"
                section.text = "5"
            case 5:
                time.text = "14:55"
                section.text = "6"
            case 6:
                time.text = "16:00"
                section.text = "7"
            case 7:
                time.text = "16:55"
                section.text = "8"
            case 8:
                time.text = "18:30"
                section.text = "9"
            case 9:
                time.text = "19:25"
                section.text = "10"
            case 10:
                time.text = "20:20"
                section.text = "11"
            default:
                time.text = "21:15"
                section.text = "12"
            }
            
            row.addSubview(time)
            row.addSubview(section)
            
            classScrollView.addSubview(row)
        }
     
        shadowView.layer.shadowColor = UIColor.grayColor().CGColor
        shadowView.layer.shadowOffset = CGSizeMake(0, 2)
        shadowView.layer.shadowOpacity = 0.3
        
    }
    
    func drawClassTimeTable() {
        
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var courses:NSArray = userDefaults.objectForKey("courses") as! NSArray
        for (var i=0;i<courses.count;i++) {
            var current:NSDictionary = courses.objectAtIndex(i) as! NSDictionary
            var day:Int = current.objectForKey("day") as! Int
            var startSection:Int = current.objectForKey("startSection") as! Int
            var sectionNumber:Int = current.objectForKey("sectionNumber") as! Int
            var name:NSString = current.objectForKey("className") as! NSString
            var classroom:NSString = current.objectForKey("classroom") as! NSString
            
            var course:UIView = UIView(frame: CGRectMake(CGFloat(day+1) * columnWidth, CGFloat(startSection - 1) * rowHeight, columnWidth, rowHeight * CGFloat(sectionNumber)))
            course.backgroundColor = colors.objectAtIndex(i % 10) as? UIColor
            
            var courseName:UILabel = UILabel(frame: CGRectMake(5, 5, columnWidth - 10, rowHeight))
            courseName.numberOfLines = 0
            courseName.textAlignment = NSTextAlignment.Center
            courseName.font = UIFont.systemFontOfSize(10)
            courseName.textColor = UIColor.whiteColor()
            courseName.text = name as String
            var size = name.boundingRectWithSize(CGSizeMake(columnWidth - 10, 100), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: NSDictionary(object: courseName.font, forKey: NSFontAttributeName) as [NSObject : AnyObject], context: nil).size
            courseName.frame.size.height = size.height
            course.addSubview(courseName)
            
            var classroomLabel:UILabel = UILabel(frame: CGRectMake(5, courseName.frame.height + 5, columnWidth - 10, rowHeight - 5))
            classroomLabel.numberOfLines = 0
            classroomLabel.textAlignment = NSTextAlignment.Center
            classroomLabel.font = UIFont.systemFontOfSize(10)
            classroomLabel.textColor = UIColor.whiteColor()
            classroomLabel.text = "@" + (classroom as String)
            course.addSubview(classroomLabel)
            
            self.classScrollView.addSubview(course)
        }
        
    }
    
    // MARK: 课程表加载动画
    
    func loadBeginAnimation() {

        overlayView = UIView(frame: CGRectMake(self.view.bounds.width / 2, self.view.bounds.height / 2, 0, 0))
        overlayView.backgroundColor = UIColor.blackColor()
        overlayView.alpha = 0.7
        self.view.addSubview(overlayView)
        
        var overlayViewIn:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewBounds)
        overlayViewIn.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        overlayViewIn.toValue = NSValue(CGRect: CGRectMake(0, 64, self.classScrollView.frame.width, self.classScrollView.frame.height + 30))
        overlayViewIn.duration = 0.5
        overlayView.pop_addAnimation(overlayViewIn, forKey: "overlayViewIn")
        
        UALoadView = UAProgressView(frame: CGRectMake(self.view.bounds.width / 2 - 100, self.view.bounds.height / 2 - 100, 200, 200))
        UALoadView.tintColor = UIColor(red: 34/255, green: 205/255, blue: 198/255, alpha: 1)
        UALoadView.lineWidth = 5
        UALoadView.alpha = 0
        var textLabel:UILabel = UILabel(frame: CGRectMake(20, 0, 160.0, 132.0))
        textLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 40)
        textLabel.textAlignment = NSTextAlignment.Center;
        textLabel.textColor = self.UALoadView.tintColor;
        textLabel.backgroundColor = UIColor.clearColor();
        textLabel.text = "0%"
        self.UALoadView.centralView = textLabel
        self.view.addSubview(UALoadView)
        
        var UALoadViewFadeIn:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        UALoadViewFadeIn.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        UALoadViewFadeIn.toValue = 1
        UALoadViewFadeIn.duration = 0.5
        UALoadView.pop_addAnimation(UALoadViewFadeIn, forKey: "UALoadViewFadeIn")
    }
    
    func loadAnimation(progress:Float) {
        
        UALoadView.setProgress(progress, animated: true)
        var label:UILabel = UALoadView.centralView as! UILabel
        label.text = NSString(format: "%2.0f%%", progress*100) as String
    }
    
    func loadEndAnimation() {
        
        var overlayViewFadeOut:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        overlayViewFadeOut.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        overlayViewFadeOut.duration = 1
        overlayViewFadeOut.toValue = 0
        overlayViewFadeOut.beginTime = CACurrentMediaTime() + 1
        overlayView.pop_addAnimation(overlayViewFadeOut, forKey: "overlayViewFadeOut")
        
        var UALoadViewFadeOut:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        UALoadViewFadeOut.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        UALoadViewFadeOut.duration = 1
        UALoadViewFadeOut.toValue = 0
        UALoadViewFadeOut.beginTime = CACurrentMediaTime() + 1
        
        var UALoadViewUp:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationY)
        UALoadViewUp.duration = 1
        UALoadViewUp.toValue = -100
        UALoadViewUp.beginTime = CACurrentMediaTime() + 1
        UALoadViewUp.completionBlock = { (anim:POPAnimation!, finished:Bool) -> Void in
            if finished {
                self.refreshBarButton.enabled = true
            }
        }
        
        UALoadView.layer.pop_addAnimation(UALoadViewUp, forKey: "UALoadViewUp")
        UALoadView.pop_addAnimation(UALoadViewFadeOut, forKey: "UALoadViewFadeOut")
    }
    
    // MARK: button
    
    @IBAction func refreshClassTimeTable(sender: AnyObject) {
        refreshBarButton.enabled = false
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var accountInfo:NSDictionary? = userDefaults.objectForKey("accountInfo") as! NSDictionary?
        if let temp = accountInfo {
            
            switch isLogIn() {
            case 1:
                var req:NSURLRequest = NSURLRequest(URL: NSURL(string: "http://222.30.32.10/xsxk/selectedAction.do?operation=kebiao")!)
                var connection:NSURLConnection? = NSURLConnection(request: req, delegate: self)
                if let temp = connection {
                    loadBeginAnimation()
                    receivedData = NSMutableData()
                }
                else {
                    var alert:UIAlertView = UIAlertView(title: "错误", message: "没有网络你让我怎么查课表捏？", delegate: nil, cancelButtonTitle: "好吧，那我去弄点网")
                    alert.show()
                    refreshBarButton.enabled = true
                }
            case 0:
                refreshBarButton.enabled = true
                self.performSegueWithIdentifier("login", sender: nil)
            default:
                var alertView:UIAlertView = UIAlertView(title: "网络错误", message: "木有网我没法加载课程表诶", delegate: nil, cancelButtonTitle: "知道啦")
                alertView.show()
                refreshBarButton.enabled = true
            }
            
        }
            
        else {
            var alert:UIAlertView = UIAlertView(title: "请先登录", message: "登陆后方可查看课表，请到设置中登录！", delegate: nil, cancelButtonTitle: "知道了！")
            alert.show()
            refreshBarButton.enabled = true
        }
        
    }
    
    // MARK: NSURLConnectionDelegate
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.receivedData.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        var encoding:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
        var html:NSString = NSString(data: self.receivedData!, encoding: encoding)!
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { () -> Void in
            self.loadAllCourseInfoWithHtml(html)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.loadEndAnimation()
                self.drawClassTimeTable()
            })
        })


        
        //for Debug
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
    
    // MARK: ScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
    }
    
}