//
//  TodayViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/10.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class TodayViewController: UIViewController {
    
    @IBOutlet var tapperOnCurrentCourse: UITapGestureRecognizer!
    
    @IBOutlet var currentCourseView: UIView!
    @IBOutlet var dateView: UIView!
    @IBOutlet var weatherConditionView: UIView!

    
    @IBOutlet var weatherImageView: UIImageView!
    
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var currentCourseNameLabel: UILabel!
    @IBOutlet var currentCourseClassroomLabel: UILabel!
    @IBOutlet var currentCourseTeacherNameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var weekdayLabel: UILabel!
    @IBOutlet var hourLabel: UILabel!
    @IBOutlet var pm25Label: UILabel!
    
    @IBOutlet var progressIndicator: UIProgressView!
    
    var timer:NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var account:NSDictionary? = userDefaults.objectForKey("accountInfo") as NSDictionary?
        if let temp = account {
            
        }
        else {
            var alert:UIAlertView = UIAlertView(title: "您尚未登录", message: "登录后方可使用NKU Helper\n登录选项位于设置选项卡中", delegate: nil, cancelButtonTitle: "好的")
            alert.show()
        }
        
        statusLabel.adjustsFontSizeToFitWidth = true
        currentCourseNameLabel.adjustsFontSizeToFitWidth = true
        currentCourseClassroomLabel.adjustsFontSizeToFitWidth = true
        currentCourseTeacherNameLabel.adjustsFontSizeToFitWidth = true
        hourLabel.adjustsFontSizeToFitWidth = true
        /*
        
        //  currentCourseView.layer.cornerRadius = 10
        currentCourseView.layer.borderWidth = 0.27
        currentCourseView.layer.borderColor = UIColor.grayColor().CGColor
        dateView.layer.borderWidth = 0.27
        dateView.layer.borderColor = UIColor.grayColor().CGColor
        hourView.layer.borderWidth = 0.27
        hourView.layer.borderColor = UIColor.grayColor().CGColor
        pm25View.layer.borderWidth = 0.27
        pm25View.layer.borderColor = UIColor.grayColor().CGColor
        
        */
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var account:NSDictionary? = userDefaults.objectForKey("accountInfo") as NSDictionary?
        if let temp = account {
            handleStatus()
            timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "handleStatus", userInfo: nil, repeats: true)
        }
        else {
            
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let temp = timer {
            timer.invalidate()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleStatus() {
        
        var date = NSDate()
        var calender:NSCalendar = NSCalendar(identifier: NSGregorianCalendar)!
        var unitFlags:NSCalendarUnit = NSCalendarUnit.WeekdayCalendarUnit | NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit | NSCalendarUnit.SecondCalendarUnit
        var components:NSDateComponents = calender.components(unitFlags, fromDate: date)
        var year:String = "\(components.year)"
        var month:String = "\(components.month)"
        var day:String = "\(components.day)"
        var hour:NSString = "\(components.hour)"
        var minute:NSString = "\(components.minute)"
        var second:String = "\(components.second)"
        var weekday:String
        var weekdayInt:Int = -1
        switch (components.weekday) {
        case 1:
            weekday = "星期天"
            weekdayInt = 6
        case 2:
            weekday = "星期一"
            weekdayInt = 0
        case 3:
            weekday = "星期二"
            weekdayInt = 1
        case 4:
            weekday = "星期三"
            weekdayInt = 2
        case 5:
            weekday = "星期四"
            weekdayInt = 3
        case 6:
            weekday = "星期五"
            weekdayInt = 4
        case 7:
            weekday = "星期六"
            weekdayInt = 5
        default:weekday = "哈？星期N"
        }
        if hour.length < 2 {
            hour = "0" + hour
        }
        if minute.length < 2 {
            minute = "0" + minute
        }

        dateLabel.text = month + "月" + day + "日"
        weekdayLabel.text = weekday
        hourLabel.text = hour + ":" + minute
        
        //sectionNumber=13意思是太早了，sectionNumber=14意思是下课了，sectionNumber=15意思是太晚了
        var hourInt:Double = Double(components.hour) + Double(components.minute)/60
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var courseStatus:NSArray = userDefaults.objectForKey("courseStatus") as NSArray
        var todayCourseStatus:NSArray = courseStatus.objectAtIndex(weekdayInt) as NSArray
        var courses:NSArray = userDefaults.objectForKey("courses") as NSArray
        switch (hourInt) {
        case 0..<7:
            statusLabel.text = "充足的睡眠是美好一天的开始！"
            currentCourseNameLabel.text = "Have a neat sleep!"
            currentCourseClassroomLabel.text = "At 寝室"
            currentCourseTeacherNameLabel.text = ""
            var progress:Float = Float(hourInt+2)/9
            progressIndicator.setProgress(progress, animated: true)
        case 7..<8:
            statusLabel.text = "早上好，第一节课是"
            showCourseInfo(weekdayInt, whichSection: 0)
            var progress:Float = Float(hourInt-7)
            progressIndicator.setProgress(progress, animated: true)
        case 8..<35/4:
            statusLabel.text = "第一节课进行中"
            showCourseInfo(weekdayInt, whichSection: 0)
            var progress:Float = Float(hourInt-8)*4/3
            progressIndicator.setProgress(progress, animated: true)
        case 35/4..<107/12:
            statusLabel.text = "下课中，即将开始第二节课"
            showCourseInfo(weekdayInt, whichSection: 1)
            var progress:Float = Float(hourInt-35/4)*6
            progressIndicator.setProgress(progress, animated: true)
        case 107/12..<29/3:
            statusLabel.text = "第二节课进行中"
            showCourseInfo(weekdayInt, whichSection: 1)
            var progress:Float = Float(hourInt-107/12)*4/3
            progressIndicator.setProgress(progress, animated: true)
        case 29/3..<10:
            statusLabel.text = "下课中，即将开始第三节课"
            showCourseInfo(weekdayInt, whichSection: 2)
            var progress:Float = Float(hourInt-29/3)*3
            progressIndicator.setProgress(progress, animated: true)
        case 10..<43/4:
            statusLabel.text = "第三节课进行中"
            showCourseInfo(weekdayInt, whichSection: 2)
            var progress:Float = Float(hourInt-10)*4/3
            progressIndicator.setProgress(progress, animated: true)
        case 43/4..<131/12:
            statusLabel.text = "下课中，即将开始第四节课"
            showCourseInfo(weekdayInt, whichSection: 3)
            var progress:Float = Float(hourInt-43/4)*6
            progressIndicator.setProgress(progress, animated: true)
        case 131/12..<35/3:
            statusLabel.text = "第四节课进行中"
            showCourseInfo(weekdayInt, whichSection: 3)
            var progress:Float = Float(hourInt-131/12)*4/3
            progressIndicator.setProgress(progress, animated: true)
        case 35/3..<13:
            statusLabel.text = "午饭及午休时间"
            currentCourseNameLabel.text = "Have a nice lunch and sleep!"
            currentCourseClassroomLabel.text = "At 食堂&寝室"
            currentCourseTeacherNameLabel.text = "木有老师~"
            var progress:Float = Float(hourInt-35/3)*3/4
            progressIndicator.setProgress(progress, animated: true)
        case 13..<14:
            statusLabel.text = "下午好，第五节课是"
            showCourseInfo(weekdayInt, whichSection: 4)
            var progress:Float = Float(hourInt-13)
            progressIndicator.setProgress(progress, animated: true)
        case 14..<59/4:
            statusLabel.text = "第五节课进行中"
            showCourseInfo(weekdayInt, whichSection: 4)
            var progress:Float = Float(hourInt-14)*4/3
            progressIndicator.setProgress(progress, animated: true)
        case 59/4..<179/12:
            statusLabel.text = "下课中，即将开始第六节课"
            showCourseInfo(weekdayInt, whichSection: 5)
            var progress:Float = Float(hourInt-59/4)*6
            progressIndicator.setProgress(progress, animated: true)
        case 179/12..<47/3:
            statusLabel.text = "第六节课进行中"
            showCourseInfo(weekdayInt, whichSection: 5)
            var progress:Float = Float(hourInt-179/12)*4/3
            progressIndicator.setProgress(progress, animated: true)
        case 47/3..<16:
            statusLabel.text = "下课中，即将开始第七节课"
            showCourseInfo(weekdayInt, whichSection: 6)
            var progress:Float = Float(hourInt-47/3)*3
            progressIndicator.setProgress(progress, animated: true)
        case 16..<67/4:
            statusLabel.text = "第七节课进行中"
            showCourseInfo(weekdayInt, whichSection: 6)
            var progress:Float = Float(hourInt-16)*4/3
            progressIndicator.setProgress(progress, animated: true)
        case 67/4..<203/12:
            statusLabel.text = "下课中，即将开始第八节课"
            showCourseInfo(weekdayInt, whichSection: 7)
            var progress:Float = Float(hourInt-67/4)*6
            progressIndicator.setProgress(progress, animated: true)
        case 203/12..<53/3:
            statusLabel.text = "第八节课进行中"
            showCourseInfo(weekdayInt, whichSection: 7)
            var progress:Float = Float(hourInt-203/12)*4/3
            progressIndicator.setProgress(progress, animated: true)
        case 53/3..<18:
            statusLabel.text = "晚餐时间"
            currentCourseNameLabel.text = "Have a nice dinner!"
            currentCourseClassroomLabel.text = "At 食堂"
            currentCourseTeacherNameLabel.text = "木有老师~"
            var progress:Float = Float(hourInt-53/3)*3
            progressIndicator.setProgress(progress, animated: true)
        case 18..<18.5:
            statusLabel.text = "晚上好，第九节课是"
            showCourseInfo(weekdayInt, whichSection: 8)
            var progress:Float = Float(hourInt-18)*2
            progressIndicator.setProgress(progress, animated: true)
        case 18.5..<77/4:
            statusLabel.text = "第九节课进行中"
            showCourseInfo(weekdayInt, whichSection: 8)
            var progress:Float = Float(hourInt-18.5)*4/3
            progressIndicator.setProgress(progress, animated: true)
        case 77/4..<233/12:
            statusLabel.text = "下课中，即将开始第十节课"
            showCourseInfo(weekdayInt, whichSection: 9)
            var progress:Float = Float(hourInt-77/4)*6
            progressIndicator.setProgress(progress, animated: true)
        case 233/12..<121/6:
            statusLabel.text = "第十节课进行中"
            showCourseInfo(weekdayInt, whichSection: 9)
            var progress:Float = Float(hourInt-233/12)*4/3
            progressIndicator.setProgress(progress, animated: true)
        case 121/6..<61/3:
            statusLabel.text = "下课中，即将开始第十一节课"
            showCourseInfo(weekdayInt, whichSection: 10)
            var progress:Float = Float(hourInt-121/6)*6
            progressIndicator.setProgress(progress, animated: true)
        case 61/3..<253/12:
            statusLabel.text = "第十一节课进行中"
            showCourseInfo(weekdayInt, whichSection: 10)
            var progress:Float = Float(hourInt-61/3)*4/3
            progressIndicator.setProgress(progress, animated: true)
        case 253/12..<85/4:
            statusLabel.text = "下课中，即将开始第十二节课"
            showCourseInfo(weekdayInt, whichSection: 11)
            var progress:Float = Float(hourInt-253/12)*6
            progressIndicator.setProgress(progress, animated: true)
        case 85/4..<22:
            statusLabel.text = "第十二节课进行中"
            showCourseInfo(weekdayInt, whichSection: 11)
            var progress:Float = Float(hourInt-85/4)*4/3
            progressIndicator.setProgress(progress, animated: true)
        default:
            statusLabel.text = "忙碌的一天结束啦"
            currentCourseNameLabel.text = "Have a neat sleep!"
            currentCourseClassroomLabel.text = "At 寝室"
            currentCourseTeacherNameLabel.text = ""
            var progress:Float = Float(hourInt-22)/9
            progressIndicator.setProgress(progress, animated: true)
        }
        
    }
    
    func showCourseInfo(weekdayInt:Int, whichSection:Int) {
        
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var courseStatus:NSArray = userDefaults.objectForKey("courseStatus") as NSArray
        var todayCourseStatus:NSArray = courseStatus.objectAtIndex(weekdayInt) as NSArray
        var courses:NSArray = userDefaults.objectForKey("courses") as NSArray
        
        var status = todayCourseStatus.objectAtIndex(whichSection) as Int
        if status == -1 {
            currentCourseNameLabel.text = "无课"
            currentCourseClassroomLabel.text = "Wherever"
            currentCourseTeacherNameLabel.text = "木有老师~"
        }
        else {
            var course:NSDictionary = courses.objectAtIndex(status) as NSDictionary
            currentCourseNameLabel.text = course.objectForKey("className") as? String
            currentCourseClassroomLabel.text = course.objectForKey("classroom") as? String
            currentCourseClassroomLabel.text = "At" + currentCourseClassroomLabel.text!
            currentCourseTeacherNameLabel.text = course.objectForKey("teacherName") as? String
        }

        
    }
    
    @IBAction func tapOnCurrentCourse(sender: UITapGestureRecognizer) {
        
        
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
