//
//  ClassTimeViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/1.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit
import Alamofire

class ClassTimeViewController: UIViewController, UIScrollViewDelegate, WXApiDelegate {
    
    // MARK: Properties
    
    var whichSection:Int!
    
    @IBOutlet var shadowView: UIView!
    @IBOutlet var classScrollView: UIScrollView! {
        didSet {
            classScrollView.delegate = self
        }
    }
    @IBOutlet var headScrollView: UIScrollView! {
        didSet {
            headScrollView.delegate = self
        }
    }
    @IBOutlet var refreshBarButton: UIBarButtonItem!
    @IBOutlet var navigationTitle: UINavigationItem!
    
    var UALoadView:UAProgressView!
    var overlayView:UIView!
    
    var receivedData:NSMutableData! = nil
    var testTimeHtml:NSString!
    
    let rowHeight:CGFloat = 50
    let columnWidth:CGFloat = UIScreen.mainScreen().bounds.width / 6
    var week:Int! {
        didSet {
            if canDrawClassTimeTable() {
                updateClassTimeTableWithWeek()
            }
        }
    }
    
    let colors = Colors()
    
    // MARK: General
    
    override func viewDidLoad() {

        drawBackground()
        
        let nc:NSNotificationCenter = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "refreshClassTimeTable:", name: "loginComplete", object: nil)
        
        if canDrawClassTimeTable() {
            drawClassTimeTable()
        }
        
        Alamofire.request(.GET, "http://115.28.141.95/CodeIgniter/index.php/info/week").responseString { (response:Response<String, NSError>) -> Void in
            if let week = response.result.value {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationTitle.title = "第\(week)周"
                    self.week = (week as NSString).integerValue
                })
            }
        }
      
    }
    
    func handleHtml(html:NSString) -> (String, String, String, String, String, String) {
        
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
    
    func loadAllCourseInfoWithHtml(html:NSString) {
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
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.loadAnimation(progress)
                
            })
            
        }
        
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey("courses")
        userDefaults.removeObjectForKey("courseStatus")
        userDefaults.setObject(courses, forKey: "courses")
        userDefaults.setObject(courseStatus, forKey: "courseStatus")
        userDefaults.synchronize()
        //   drawClassTimeTable()
    }

    func isLogIn() -> Int {
        let req:NSURLRequest = NSURLRequest(URL: NSURL(string: "http://222.30.32.10/xsxk/selectedAction.do?operation=kebiao")!)
        let receivedData:NSData? = try? NSURLConnection.sendSynchronousRequest(req, returningResponse: nil)
        if let _ = receivedData {
            let encoding:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
            let html:NSString = NSString(data: receivedData!, encoding: encoding)!
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
    
    func canDrawClassTimeTable() -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let accountInfo = userDefaults.objectForKey("accountInfo") as? NSDictionary
        if let _ = accountInfo {
            
            let courses:NSArray? = userDefaults.objectForKey("courses") as? NSArray
            if let _ = courses {
                return true
            }
            else {
                switch isLogIn() {
                case 1:
                    loadBeginAnimation()
                    Alamofire.request(.GET, "http://222.30.32.10/xsxk/selectedAction.do?operation=kebiao").responseString(encoding: CFStringConvertEncodingToNSStringEncoding(0x0632), completionHandler: { (response:Response<String, NSError>) -> Void in
                        if let html = response.result.value {
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { () -> Void in
                                self.loadAllCourseInfoWithHtml(html)
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.loadEndAnimation()
                                    self.drawClassTimeTable()
                                })
                            })
                        } else {
                            let alertView = UIAlertController(title: ErrorHandler.NetworkError.title, message: ErrorHandler.NetworkError.message, preferredStyle: .Alert)
                            let cancel = UIAlertAction(title: ErrorHandler.NetworkError.cancelButtonTitle, style: .Cancel, handler: nil)
                            alertView.addAction(cancel)
                            self.presentViewController(alertView, animated: true, completion: nil)
                        }
                    })
                    return false
                case 0:
                    self.performSegueWithIdentifier(SegueIdentifier.Login, sender: nil)
                    return false
                default:
                    let alertView = UIAlertController(title: ErrorHandler.NetworkError.title, message: ErrorHandler.NetworkError.message, preferredStyle: .Alert)
                    let cancel = UIAlertAction(title: ErrorHandler.NetworkError.cancelButtonTitle, style: .Cancel, handler: nil)
                    alertView.addAction(cancel)
                    self.presentViewController(alertView, animated: true, completion: nil)
                    return false
                }
            }
        } else {
            let alertView = UIAlertController(title: ErrorHandler.NotLoggedIn.title, message: ErrorHandler.NotLoggedIn.message, preferredStyle: .Alert)
            let cancel = UIAlertAction(title: ErrorHandler.NotLoggedIn.cancelButtonTitle, style: .Cancel, handler: nil)
            alertView.addAction(cancel)
            self.presentViewController(alertView, animated: true, completion: nil)
            return false
        }
    }
    
    // MARK: 绘制课程表
    
    func drawBackground() {
        
        // 防止多画背景，背景画一次即可
        if !(headScrollView.subviews.isEmpty) {
            return
        }
        
        headScrollView.contentSize = CGSizeMake(columnWidth * 8, 30)
        
        for (var i=1;i<=7;i++) {
            let column = UIView(frame: CGRectMake(columnWidth * CGFloat(i), 0, columnWidth, 30))
            column.backgroundColor = UIColor.whiteColor()
            let weekday = UILabel()
            weekday.font = UIFont(name: "HelveticaNeue-Bold", size: 13)
            weekday.textColor = UIColor.blackColor()
            weekday.textAlignment = NSTextAlignment.Center
            weekday.frame = column.bounds
            switch i {
            case 1:weekday.text = "周一"
            case 2:weekday.text = "周二"
            case 3:weekday.text = "周三"
            case 4:weekday.text = "周四"
            case 5:weekday.text = "周五"
            case 6:weekday.text = "周六"
            case 7:weekday.text = "周日"
            default:break
            }
            column.addSubview(weekday)
            headScrollView.addSubview(column)
        }
        
        classScrollView.contentSize = CGSizeMake(columnWidth * 8, rowHeight*14)
        
        for (var i=0;i<=13;i++) {
            let row:UIView = UIView(frame: CGRectMake(0, CGFloat(i) * rowHeight, columnWidth * 8, CGFloat(rowHeight)))
            row.backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1)
            row.layer.borderWidth = 0.5
            row.layer.borderColor = UIColor(red: 216/255, green: 224/255, blue: 226/255, alpha: 1).CGColor
            
            let time:UILabel = UILabel(frame: CGRectMake(5, 5, 30, 20))
            time.adjustsFontSizeToFitWidth = true
            time.textAlignment = NSTextAlignment.Center
            time.textColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1)
            
            let section:UILabel = UILabel(frame: CGRectMake(0, 25, 40, 20))
            section.adjustsFontSizeToFitWidth = true
            section.textAlignment = NSTextAlignment.Center
            section.textColor = UIColor(red: 104/255, green: 102/255, blue: 102/255, alpha: 1)
            
            switch i {
            case 0:
                time.text = "08:00"
                section.text = "1"
            case 1:
                time.text = "08:55"
                section.text = "2"
            case 2:
                time.text = "10:00"
                section.text = "3"
            case 3:
                time.text = "10:55"
                section.text = "4"
            case 4:
                time.text = "12:00"
                section.text = "5"
            case 5:
                time.text = "12:55"
                section.text = "6"
            case 6:
                time.text = "14:00"
                section.text = "7"
            case 7:
                time.text = "14:55"
                section.text = "8"
            case 8:
                time.text = "16:00"
                section.text = "9"
            case 9:
                time.text = "16:55"
                section.text = "10"
            case 10:
                time.text = "18:30"
                section.text = "11"
            case 11:
                time.text = "19:25"
                section.text = "12"
            case 12:
                time.text = "20:20"
                section.text = "13"
            case 13:
                time.text = "23:15"
                section.text = "14"
            default:break
            }
            
            row.addSubview(time)
            row.addSubview(section)
            row.tag = -1
            
            classScrollView.addSubview(row)
        }
        
        shadowView.layer.shadowColor = UIColor.grayColor().CGColor
        shadowView.layer.shadowOffset = CGSizeMake(0, 2)
        shadowView.layer.shadowOpacity = 0.3
        
    }
    
    func drawClassTimeTable() {
        
        for view in classScrollView.subviews {
            if (view.tag != -1) {               // -1代表是背景中的第几节课及时间等
                view.removeFromSuperview()
            }
        }
        drawBackground()
        
        var usedColor:[Int] = []
        for var i=0;i<Colors.colors.count;i++ {
            usedColor.append(1)
        }
        
        var coloredCourse = Dictionary<String, Int>()
        
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let courses:NSArray = userDefaults.objectForKey("courses") as! NSArray
        for (var i=0;i<courses.count;i++) {
            let currentData = courses.objectAtIndex(i) as! NSData
            let current = NSKeyedUnarchiver.unarchiveObjectWithData(currentData) as! Course
            let day = current.day
            let startSection = current.startSection
            let sectionNumber = current.sectionNumber
            let name = current.name
            let classroom = current.classroom
            let classID = current.ID
            let weekOddEven = current.weekOddEven
            
            let course:UIView = UIView(frame: CGRectMake(CGFloat(day+1) * columnWidth, CGFloat(startSection - 1) * rowHeight, columnWidth, rowHeight * CGFloat(sectionNumber)))
            
            if let _ = week {
                if ((weekOddEven == "单 周") && (week % 2 == 0) || (weekOddEven == "双 周" && (week % 2 == 1))) {
                    course.alpha = 0.5
                }
            }
            
            var isClassHaveHad:Bool = false
            for (key, value) in coloredCourse {
                if key == classID {
                    isClassHaveHad = true
                    course.backgroundColor = Colors.colors[value]
                    break
                }
                if isClassHaveHad {
                    break
                }
            }
            
            if !isClassHaveHad {
                let likedColors = userDefaults.objectForKey("preferredColors") as! NSArray
                var count = 0
                var colorIndex = Int(arc4random_uniform(UInt32(Colors.colors.count)))
                
                while (usedColor[colorIndex] == 0) || (likedColors.objectAtIndex(colorIndex) as! Int == 0) {
                    colorIndex = Int(arc4random_uniform(UInt32(Colors.colors.count)))
                    count++
                    if count>1000 {
                        break
                    }
                }
                coloredCourse[classID as String] = colorIndex
                course.backgroundColor = Colors.colors[colorIndex]
                usedColor[colorIndex] = 0
            }
            
            let courseName = UILabel(frame: CGRectMake(2, 5, columnWidth - 4, rowHeight))
            courseName.numberOfLines = 0
            courseName.textAlignment = NSTextAlignment.Center
            courseName.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
            courseName.textColor = UIColor.whiteColor()
            courseName.text = name as String
            let size = name.boundingRectWithSize(CGSizeMake(columnWidth - 4, 100), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: courseName.font], context: nil).size
            courseName.frame.size.height = size.height
            course.addSubview(courseName)
            
            let classroomLabel:UILabel = UILabel(frame: CGRectMake(5, courseName.frame.height + 10, columnWidth - 10, rowHeight - 5))
            classroomLabel.numberOfLines = 0
            classroomLabel.textAlignment = NSTextAlignment.Center
            classroomLabel.font = UIFont(name: "HelveticaNeue", size: 10)
            classroomLabel.textColor = UIColor.whiteColor()
            classroomLabel.text = "@" + (classroom as String)
            course.addSubview(classroomLabel)
            course.tag = i
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: "showCourseDetail:")
            course.addGestureRecognizer(tapGesture)
            
            self.classScrollView.addSubview(course)
        }
        
    }
    
    func updateClassTimeTableWithWeek() {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let courses:NSArray = userDefaults.objectForKey("courses") as! NSArray
        for (var i=0;i<courses.count;i++) {
            let currentData = courses.objectAtIndex(i) as! NSData
            let current = NSKeyedUnarchiver.unarchiveObjectWithData(currentData) as! Course
            let weekOddEven = current.weekOddEven
            
            let course = self.classScrollView.viewWithTag(i)!
            
            if ((weekOddEven == "单 周") && (week % 2 == 0) || (weekOddEven == "双 周" && (week % 2 == 1))) {
                course.alpha = 0.5
            }
        }
    }
    
    // MARK: Segue
    
    func showCourseDetail(tapGesture:UITapGestureRecognizer) {
        
        whichSection = tapGesture.view?.tag
        self.performSegueWithIdentifier("showCourseDetail", sender: nil)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showCourseDetail" {
            let vc:CourseDetailTableViewController = segue.destinationViewController as! CourseDetailTableViewController
            vc.whichCourse = whichSection
        }
        else if segue.identifier == "showTestTime" {
            let vc:TestTimeTableViewController = segue.destinationViewController as! TestTimeTableViewController
            vc.html = testTimeHtml
        }
    }
    
    // MARK: 课程表加载动画
    
    func loadBeginAnimation() {

        overlayView = UIView(frame: CGRectMake(self.view.frame.width / 2, self.classScrollView.frame.height / 2 - 50, 0, 0))
        overlayView.backgroundColor = UIColor.blackColor()
        overlayView.alpha = 0.7
        self.view.addSubview(overlayView)
        
        let overlayViewIn:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewFrame)
        overlayViewIn.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        overlayViewIn.toValue = NSValue(CGRect: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
        overlayViewIn.duration = 0.5
        overlayView.pop_addAnimation(overlayViewIn, forKey: "overlayViewIn")
        
        UALoadView = UAProgressView(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 2 - 100, UIScreen.mainScreen().bounds.height / 2 - 150, 200, 200))
        UALoadView.tintColor = UIColor(red: 34/255, green: 205/255, blue: 198/255, alpha: 1)
        UALoadView.lineWidth = 5
        UALoadView.alpha = 0
        let textLabel:UILabel = UILabel(frame: CGRectMake(20, 0, 160.0, 132.0))
        textLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 40)
        textLabel.textAlignment = NSTextAlignment.Center;
        textLabel.textColor = self.UALoadView.tintColor;
        textLabel.backgroundColor = UIColor.clearColor();
        textLabel.text = "0%"
        self.UALoadView.centralView = textLabel
        self.view.addSubview(UALoadView)
        
        let UALoadViewFadeIn:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        UALoadViewFadeIn.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        UALoadViewFadeIn.toValue = 1
        UALoadViewFadeIn.duration = 0.5
        UALoadView.pop_addAnimation(UALoadViewFadeIn, forKey: "UALoadViewFadeIn")
    }
    
    func loadAnimation(progress:Float) {
        
        UALoadView.setProgress(CGFloat(progress), animated: true)
        let label:UILabel = UALoadView.centralView as! UILabel
        label.text = NSString(format: "%2.0f%%", progress*100) as String
    }
    
    func loadEndAnimation() {
        
        let overlayViewFadeOut:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        overlayViewFadeOut.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        overlayViewFadeOut.duration = 1
        overlayViewFadeOut.toValue = 0
        overlayViewFadeOut.beginTime = CACurrentMediaTime() + 0.8
        overlayView.pop_addAnimation(overlayViewFadeOut, forKey: "overlayViewFadeOut")
        
        let UALoadViewFadeOut:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        UALoadViewFadeOut.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        UALoadViewFadeOut.duration = 1
        UALoadViewFadeOut.toValue = 0
        UALoadViewFadeOut.beginTime = CACurrentMediaTime() + 0.8
        
        let UALoadViewUp:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationY)
        UALoadViewUp.duration = 1
        UALoadViewUp.toValue = -100
        UALoadViewUp.beginTime = CACurrentMediaTime() + 0.8
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
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let accountInfo:NSDictionary? = userDefaults.objectForKey("accountInfo") as? NSDictionary
        if let _ = accountInfo {
            switch isLogIn() {
            case 1:
                loadBeginAnimation()
                Alamofire.request(.GET, "http://222.30.32.10/xsxk/selectedAction.do?operation=kebiao").responseString(encoding: CFStringConvertEncodingToNSStringEncoding(0x0632), completionHandler: { (response:Response<String, NSError>) -> Void in
                    if let html = response.result.value {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), { () -> Void in
                            self.loadAllCourseInfoWithHtml(html)
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.loadEndAnimation()
                                self.drawClassTimeTable()
                            })
                        })
                    } else {
                        let alertView = UIAlertController(title: ErrorHandler.NetworkError.title, message: ErrorHandler.NetworkError.message, preferredStyle: .Alert)
                        let cancel = UIAlertAction(title: ErrorHandler.NetworkError.cancelButtonTitle, style: .Cancel, handler: nil)
                        alertView.addAction(cancel)
                        self.presentViewController(alertView, animated: true, completion: nil)
                    }
                })
            case 0:
                refreshBarButton.enabled = true
                self.performSegueWithIdentifier(SegueIdentifier.Login, sender: nil)
            default:
                let alertView = UIAlertController(title: ErrorHandler.NetworkError.title, message: ErrorHandler.NetworkError.message, preferredStyle: .Alert)
                let cancel = UIAlertAction(title: ErrorHandler.NetworkError.cancelButtonTitle, style: .Cancel, handler: nil)
                alertView.addAction(cancel)
                self.presentViewController(alertView, animated: true, completion: nil)
            }
            
        }
            
        else {
            let alertView = UIAlertController(title: ErrorHandler.NotLoggedIn.title, message: ErrorHandler.NotLoggedIn.message, preferredStyle: .Alert)
            let cancel = UIAlertAction(title: ErrorHandler.NotLoggedIn.cancelButtonTitle, style: .Cancel, handler: nil)
            alertView.addAction(cancel)
            self.presentViewController(alertView, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func lookUpTestTime(sender: UIBarButtonItem) {
        
        switch isLogIn() {
        case 1:
            let url:NSURL = NSURL(string: "http://222.30.32.10/xxcx/stdexamarrange/listAction.do")!
            let data:NSData? = NSData(contentsOfURL: url)
            if let _ = data {
                let encoding:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
                testTimeHtml = NSString(data: data!, encoding: encoding)!
                self.performSegueWithIdentifier("showTestTime", sender: nil)
            }
            else {
                let alertView = UIAlertController(title: ErrorHandler.NetworkError.title, message: ErrorHandler.NetworkError.message, preferredStyle: .Alert)
                let cancel = UIAlertAction(title: ErrorHandler.NetworkError.cancelButtonTitle, style: .Cancel, handler: nil)
                alertView.addAction(cancel)
                self.presentViewController(alertView, animated: true, completion: nil)
            }
        case 0:
            let nc:NSNotificationCenter = NSNotificationCenter.defaultCenter()
            nc.removeObserver(self)
            nc.addObserver(self, selector: "showTestTime", name: "loginComplete", object: nil)
            self.performSegueWithIdentifier(SegueIdentifier.Login, sender: nil)
        default:
            let alertView = UIAlertController(title: ErrorHandler.NetworkError.title, message: ErrorHandler.NetworkError.message, preferredStyle: .Alert)
            let cancel = UIAlertAction(title: ErrorHandler.NetworkError.cancelButtonTitle, style: .Cancel, handler: nil)
            alertView.addAction(cancel)
            self.presentViewController(alertView, animated: true, completion: nil)
        }

        
    }
    
    func showTestTime() {
        
        let nc:NSNotificationCenter = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self)
        nc.addObserver(self, selector: "refreshClassTimeTable:", name: "loginComplete", object: nil)
        let url:NSURL = NSURL(string: "http://222.30.32.10/xxcx/stdexamarrange/listAction.do")!
        let data:NSData? = NSData(contentsOfURL: url)
        if let _ = data {
            let encoding:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
            testTimeHtml = NSString(data: data!, encoding: encoding)!
            self.performSegueWithIdentifier("showTestTime", sender: nil)
            
        }
        else {
            let alertView:UIAlertView = UIAlertView(title: "网络错误", message: "木有网我没法加载考试信息诶", delegate: nil, cancelButtonTitle: "知道啦")
            alertView.show()
        }
    }
    
    @IBAction func shareClassTable(sender: UIBarButtonItem) {
        
        guard WXApi.isWXAppInstalled() && WXApi.isWXAppSupportApi() else {
            let alert = UIAlertController(title: "分享错误", message: "未安装微信或微信版本过低", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "安装最新版微信", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string: WXApi.getWXAppInstallUrl())!)
            }))
            alert.addAction(UIAlertAction(title: "算了", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        // 获取星期的headView
        UIGraphicsBeginImageContextWithOptions(self.headScrollView.contentSize, false, 0)
        let savedHeadContentOffset = self.headScrollView.contentOffset
        let savedHeadFrame = self.headScrollView.frame
        self.headScrollView.contentOffset = CGPointZero
        self.headScrollView.frame = CGRectMake(0, 0, self.headScrollView.contentSize.width, self.headScrollView.contentSize.height)
        self.headScrollView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let headImage = UIGraphicsGetImageFromCurrentImageContext()
        self.headScrollView.contentOffset = savedHeadContentOffset
        self.headScrollView.frame = savedHeadFrame
        UIGraphicsEndImageContext()
        
        // 获取课程表
        UIGraphicsBeginImageContextWithOptions(self.classScrollView.contentSize, false, 0)
        let savedContentOffset = self.classScrollView.contentOffset
        let savedFrame = self.classScrollView.frame
        self.classScrollView.contentOffset = CGPointZero
        self.classScrollView.frame = CGRectMake(0, 0, self.classScrollView.contentSize.width, self.classScrollView.contentSize.height)
        self.classScrollView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let classTimeTableImage = UIGraphicsGetImageFromCurrentImageContext()
        self.classScrollView.contentOffset = savedContentOffset
        self.classScrollView.frame = savedFrame
        UIGraphicsEndImageContext()
        
        // 合并星期的HeadView和课程表
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.classScrollView.contentSize.width, self.classScrollView.contentSize.height+self.headScrollView.contentSize.height), false, 0)
        headImage.drawAtPoint(CGPointZero)
        classTimeTableImage.drawAtPoint(CGPointMake(0, self.headScrollView.contentSize.height))
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), UIColor.whiteColor().CGColor)
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, columnWidth, 30))
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 绘制缩略图
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.classScrollView.contentSize.width, self.classScrollView.contentSize.height+self.headScrollView.contentSize.height), false, 1)
        headImage.drawAtPoint(CGPointZero)
        classTimeTableImage.drawAtPoint(CGPointMake(0, self.headScrollView.contentSize.height))
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), UIColor.whiteColor().CGColor)
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, columnWidth, 30))
        let thumbImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 制作微信跳转过去的信息
        let message = WXMediaMessage()
        let ext = WXImageObject()
        ext.imageData = UIImagePNGRepresentation(combinedImage)
        message.mediaObject = ext
        message.title = "课表"
        message.description = "课表"
        message.thumbData = UIImageJPEGRepresentation(thumbImage, 0.1)
        let req = SendMessageToWXReq()
        req.bText = false;
        req.message = message
        
        let alert = UIAlertController(title: "选择你想要分享的方式", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "分享给微信好友", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            req.scene = 0  //聊天界面
            WXApi.sendReq(req)
        }))
        alert.addAction(UIAlertAction(title: "分享到朋友圈", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            req.scene = 1  //朋友圈
            WXApi.sendReq(req)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    // MARK: ScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.tag == 1 {
            headScrollView.contentOffset.x = classScrollView.contentOffset.x
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
    }
    
}