//
//  TodayTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/16.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class TodayTableViewController: UITableViewController, UIScrollViewDelegate {

    var storeHouseRefreshControl:CBStoreHouseRefreshControl!
    
    var timer:NSTimer!
    var receivedWeatherData:NSMutableData?
    
    let weatherEncodeToWeatherCondition:NSDictionary = ["00":"晴", "01":"多云", "02":"阴", "03":"阵雨", "04":"雷阵雨", "05":"雷阵雨伴有冰雹", "06":"雨夹雪", "07":"小雨", "08":"中雨", "09":"大雨", "10":"暴雨", "11":"大暴雨", "12":"特大暴雨", "13":"阵雪", "14":"小雪", "15":"中雪", "16":"大雪", "17":"暴雪", "18":"雾", "19":"冻雨", "20":"沙尘暴", "21":"小到中雨", "22":"中到大雨", "23":"大到暴雨", "24":"暴雨到大暴雨", "25":"大暴雨到特大暴雨", "26":"小到中雪", "27":"中到大雪", "28":"大到暴雪", "29":"浮尘", "30":"扬沙", "31":"强沙尘暴", "53":"霾", "99":"无"]
    
    // MARK: LifeLoopFunction
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.alwaysBounceVertical = true
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "backgroundImage.jpg"))
        self.storeHouseRefreshControl = CBStoreHouseRefreshControl.attachToScrollView(self.tableView, target: self, refreshAction: "refreshTriggered", plist: "NKU", color: UIColor.whiteColor(), lineWidth: 1.5, dropHeight: 75, scale: 1, horizontalRandomness: 150, reverseLoadingAnimation: false, internalAnimationFactor: 0.5)
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
    
    func reload() {
        self.tableView.reloadData()
    }
    
    // MARK: tableView Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.row) {
        case 0:
            var cell:time_weatherTableViewCell = tableView.dequeueReusableCellWithIdentifier("time_weather") as time_weatherTableViewCell
            
            var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var account:NSDictionary? = userDefaults.objectForKey("accountInfo") as NSDictionary?
            if let temp = account {
                handleDate(cell)
                refreshWeatherCondition(cell)
            }
            else {
                var alert:UIAlertView = UIAlertView(title: "您尚未登录", message: "登录后方可使用NKU Helper\n登录选项位于设置选项卡中", delegate: nil, cancelButtonTitle: "好的")
                alert.show()
            }
            return cell
        case 1:
            var cell:courseCurrentTableViewCell = tableView.dequeueReusableCellWithIdentifier("courseCurrent") as courseCurrentTableViewCell
            
            var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var account:NSDictionary? = userDefaults.objectForKey("accountInfo") as NSDictionary?
            if let temp = account {
                handleStatus(cell)
                timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "reload", userInfo: nil, repeats: true)
            }
            else {
                cell.currentCourseClassroomLabel.text = "N/A"
                cell.currentCourseNameLabel.text = "N/A"
                cell.currentCourseTeacherNameLabel.text = "N/A"
                cell.statusLabel.text = "N/A"
            }
            
            return cell
        default:
            var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("???") as UITableViewCell
            return cell
        }
    }
    
    // MARK: handle Date、Course、Weather to be presented on view
    
    func handleDate(cell: time_weatherTableViewCell) {
        
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
        switch (components.weekday) {
        case 1:
            weekday = "星期天"
        case 2:
            weekday = "星期一"
        case 3:
            weekday = "星期二"
        case 4:
            weekday = "星期三"
        case 5:
            weekday = "星期四"
        case 6:
            weekday = "星期五"
        case 7:
            weekday = "星期六"
        default:weekday = "哈？星期N"
        }
        if hour.length < 2 {
            hour = "0" + hour
        }
        if minute.length < 2 {
            minute = "0" + minute
        }
        
        cell.dateLabel.text = month + "月" + day + "日"
        cell.weekdayLabel.text = weekday
        cell.hourLabel.text = hour + ":" + minute
        
    }
    
    func handleStatus(cell: courseCurrentTableViewCell) {
        
        var date = NSDate()
        var calender:NSCalendar = NSCalendar(identifier: NSGregorianCalendar)!
        var unitFlags:NSCalendarUnit = NSCalendarUnit.WeekdayCalendarUnit | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit
        var components:NSDateComponents = calender.components(unitFlags, fromDate: date)
        var hour:NSString = "\(components.hour)"
        var minute:NSString = "\(components.minute)"
        var weekdayInt:Int = -1
        switch (components.weekday) {
        case 1:
            weekdayInt = 6
        case 2:
            weekdayInt = 0
        case 3:
            weekdayInt = 1
        case 4:
            weekdayInt = 2
        case 5:
            weekdayInt = 3
        case 6:
            weekdayInt = 4
        case 7:
            weekdayInt = 5
        default:weekdayInt = -1
        }
        if hour.length < 2 {
            hour = "0" + hour
        }
        if minute.length < 2 {
            minute = "0" + minute
        }

        var hourInt:Double = Double(components.hour) + Double(components.minute)/60
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var courses:NSArray? = userDefaults.objectForKey("courses") as? NSArray
        
        if let temp = courses {
            
            var courseStatus:NSArray = userDefaults.objectForKey("courseStatus") as NSArray
            var todayCourseStatus:NSArray = courseStatus.objectAtIndex(weekdayInt) as NSArray
            var todayCourses:NSArray = handleTodayCourses(weekdayInt)
            
            switch (hourInt) {
            case 0..<7:
                cell.statusLabel.text = "充足的睡眠是美好一天的开始！"
                cell.currentCourseNameLabel.text = "Have a neat sleep!"
                cell.currentCourseClassroomLabel.text = "@ 寝室"
                cell.currentCourseTeacherNameLabel.text = ""
                var progress:Float = Float(hourInt+2)/9
                cell.progressIndicator.setProgress(progress, animated: true)
            case 7..<8:
                cell.statusLabel.text = "早上好，第一节课是"
                showCourseInfo(weekdayInt, whichSection: 0, cell: cell)
                var progress:Float = Float(hourInt-7)
                cell.progressIndicator.setProgress(progress, animated: true)
            case 8..<35/4:
                cell.statusLabel.text = "第一节课进行中"
                showCourseInfo(weekdayInt, whichSection: 0, cell: cell)
                var progress:Float = Float(hourInt-8)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 35/4..<107/12:
                cell.statusLabel.text = "下课中，即将开始第二节课"
                showCourseInfo(weekdayInt, whichSection: 1, cell: cell)
                var progress:Float = Float(hourInt-35/4)*6
                cell.progressIndicator.setProgress(progress, animated: true)
            case 107/12..<29/3:
                cell.statusLabel.text = "第二节课进行中"
                showCourseInfo(weekdayInt, whichSection: 1, cell: cell)
                var progress:Float = Float(hourInt-107/12)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 29/3..<10:
                cell.statusLabel.text = "下课中，即将开始第三节课"
                showCourseInfo(weekdayInt, whichSection: 2, cell: cell)
                var progress:Float = Float(hourInt-29/3)*3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 10..<43/4:
                cell.statusLabel.text = "第三节课进行中"
                showCourseInfo(weekdayInt, whichSection: 2, cell: cell)
                var progress:Float = Float(hourInt-10)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 43/4..<131/12:
                cell.statusLabel.text = "下课中，即将开始第四节课"
                showCourseInfo(weekdayInt, whichSection: 3, cell: cell)
                var progress:Float = Float(hourInt-43/4)*6
                cell.progressIndicator.setProgress(progress, animated: true)
            case 131/12..<35/3:
                cell.statusLabel.text = "第四节课进行中"
                showCourseInfo(weekdayInt, whichSection: 3, cell: cell)
                var progress:Float = Float(hourInt-131/12)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 35/3..<13:
                cell.statusLabel.text = "午饭及午休时间"
                cell.currentCourseNameLabel.text = "Have a nice lunch and sleep!"
                cell.currentCourseClassroomLabel.text = "@ 食堂&寝室"
                cell.currentCourseTeacherNameLabel.text = "木有老师~"
                var progress:Float = Float(hourInt-35/3)*3/4
                cell.progressIndicator.setProgress(progress, animated: true)
            case 13..<14:
                cell.statusLabel.text = "下午好，第五节课是"
                showCourseInfo(weekdayInt, whichSection: 4, cell: cell)
                var progress:Float = Float(hourInt-13)
                cell.progressIndicator.setProgress(progress, animated: true)
            case 14..<59/4:
                cell.statusLabel.text = "第五节课进行中"
                showCourseInfo(weekdayInt, whichSection: 4, cell: cell)
                var progress:Float = Float(hourInt-14)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 59/4..<179/12:
                cell.statusLabel.text = "下课中，即将开始第六节课"
                showCourseInfo(weekdayInt, whichSection: 5, cell: cell)
                var progress:Float = Float(hourInt-59/4)*6
                cell.progressIndicator.setProgress(progress, animated: true)
            case 179/12..<47/3:
                cell.statusLabel.text = "第六节课进行中"
                showCourseInfo(weekdayInt, whichSection: 5, cell: cell)
                var progress:Float = Float(hourInt-179/12)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 47/3..<16:
                cell.statusLabel.text = "下课中，即将开始第七节课"
                showCourseInfo(weekdayInt, whichSection: 6, cell: cell)
                var progress:Float = Float(hourInt-47/3)*3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 16..<67/4:
                cell.statusLabel.text = "第七节课进行中"
                showCourseInfo(weekdayInt, whichSection: 6, cell: cell)
                var progress:Float = Float(hourInt-16)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 67/4..<203/12:
                cell.statusLabel.text = "下课中，即将开始第八节课"
                showCourseInfo(weekdayInt, whichSection: 7, cell: cell)
                var progress:Float = Float(hourInt-67/4)*6
                cell.progressIndicator.setProgress(progress, animated: true)
            case 203/12..<53/3:
                cell.statusLabel.text = "第八节课进行中"
                showCourseInfo(weekdayInt, whichSection: 7, cell: cell)
                var progress:Float = Float(hourInt-203/12)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 53/3..<18:
                cell.statusLabel.text = "晚餐时间"
                cell.currentCourseNameLabel.text = "Have a nice dinner!"
                cell.currentCourseClassroomLabel.text = "@ 食堂"
                cell.currentCourseTeacherNameLabel.text = "木有老师~"
                var progress:Float = Float(hourInt-53/3)*3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 18..<18.5:
                cell.statusLabel.text = "晚上好，第九节课是"
                showCourseInfo(weekdayInt, whichSection: 8, cell: cell)
                var progress:Float = Float(hourInt-18)*2
                cell.progressIndicator.setProgress(progress, animated: true)
            case 18.5..<77/4:
                cell.statusLabel.text = "第九节课进行中"
                showCourseInfo(weekdayInt, whichSection: 8, cell: cell)
                var progress:Float = Float(hourInt-18.5)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 77/4..<233/12:
                cell.statusLabel.text = "下课中，即将开始第十节课"
                showCourseInfo(weekdayInt, whichSection: 9, cell: cell)
                var progress:Float = Float(hourInt-77/4)*6
                cell.progressIndicator.setProgress(progress, animated: true)
            case 233/12..<121/6:
                cell.statusLabel.text = "第十节课进行中"
                showCourseInfo(weekdayInt, whichSection: 9, cell: cell)
                var progress:Float = Float(hourInt-233/12)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 121/6..<61/3:
                cell.statusLabel.text = "下课中，即将开始第十一节课"
                showCourseInfo(weekdayInt, whichSection: 10, cell: cell)
                var progress:Float = Float(hourInt-121/6)*6
                cell.progressIndicator.setProgress(progress, animated: true)
            case 61/3..<253/12:
                cell.statusLabel.text = "第十一节课进行中"
                showCourseInfo(weekdayInt, whichSection: 10, cell: cell)
                var progress:Float = Float(hourInt-61/3)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 253/12..<85/4:
                cell.statusLabel.text = "下课中，即将开始第十二节课"
                showCourseInfo(weekdayInt, whichSection: 11, cell: cell)
                var progress:Float = Float(hourInt-253/12)*6
                cell.progressIndicator.setProgress(progress, animated: true)
            case 85/4..<22:
                cell.statusLabel.text = "第十二节课进行中"
                showCourseInfo(weekdayInt, whichSection: 11, cell: cell)
                var progress:Float = Float(hourInt-85/4)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            default:
                cell.statusLabel.text = "忙碌的一天结束啦"
                cell.currentCourseNameLabel.text = "Have a neat sleep!"
                cell.currentCourseClassroomLabel.text = "@ 寝室"
                cell.currentCourseTeacherNameLabel.text = ""
                var progress:Float = Float(hourInt-22)/9
                cell.progressIndicator.setProgress(progress, animated: true)
            }
        }
        else {
            
            //没有course信息
            cell.statusLabel.text = "不知道诶！"
            cell.currentCourseNameLabel.text = "不知道诶!"
            cell.currentCourseClassroomLabel.text = "@ 不知道诶！"
            cell.currentCourseTeacherNameLabel.text = "不知道诶！"
            var alert:UIAlertView = UIAlertView(title: "数据错误", message: "还未加载课程数据\n请先到课程表页面加载课程数据", delegate: nil, cancelButtonTitle: "好的，马上去！")
            alert.show()
        }
    }
    
    func handleTodayCourses(weekday:Int) -> NSArray {
        
        var todayCourses:NSMutableArray = NSMutableArray()
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var courses:NSArray = userDefaults.objectForKey("courses") as NSArray
        var i:Int = 0
        var course:NSDictionary = courses.objectAtIndex(i) as NSDictionary
        var courseDay:Int = course.objectForKey("day") as Int
        while (courseDay != weekday) {
            i++
            if i>=courses.count - 1 {
                break;
            }
            course = courses.objectAtIndex(i) as NSDictionary
            courseDay = course.objectForKey("day") as Int
        }
        while courseDay == weekday {
            todayCourses.addObject(i)
            i++
            if (i<courses.count-1) {
                course = courses.objectAtIndex(i) as NSDictionary
                courseDay = course.objectForKey("day") as Int
            }
            else {
                break
            }
        }
        
        return todayCourses
    }
    
    func showCourseInfo(weekdayInt:Int, whichSection:Int, cell: courseCurrentTableViewCell) {
        
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var courseStatus:NSArray = userDefaults.objectForKey("courseStatus") as NSArray
        var todayCourseStatus:NSArray = courseStatus.objectAtIndex(weekdayInt) as NSArray
        var courses:NSArray = userDefaults.objectForKey("courses") as NSArray
        
        var status = todayCourseStatus.objectAtIndex(whichSection) as Int
        if status == -1 {
            cell.currentCourseNameLabel.text = "无课"
            cell.currentCourseClassroomLabel.text = "Wherever"
            cell.currentCourseTeacherNameLabel.text = "木有老师~"
        }
        else {
            var course:NSDictionary = courses.objectAtIndex(status) as NSDictionary
            cell.currentCourseNameLabel.text = course.objectForKey("className") as? String
            cell.currentCourseClassroomLabel.text = course.objectForKey("classroom") as? String
            cell.currentCourseClassroomLabel.text = "@ " + cell.currentCourseClassroomLabel.text!
            cell.currentCourseTeacherNameLabel.text = course.objectForKey("teacherName") as? String
        }
        
    }
    
    func refreshWeatherCondition(cell: time_weatherTableViewCell) {
        
        var weatherGetter:WeatherConditionGetter = WeatherConditionGetter()
        var API:NSString = weatherGetter.getAPI()
        var url:NSURL = NSURL(string: API)!
        var req:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        req.HTTPMethod = "GET"
        req.timeoutInterval = 10
        
        var returnData:NSData? = NSData(contentsOfURL: url)
        if let temp = returnData {
            
            //For Debug
            /*
            var returnString:NSString = NSString(data: returnData!, encoding: NSUTF8StringEncoding)!
            print(returnString)
            print("\n**********************\n")
            */
            
            let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(returnData!, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            let temp:NSDictionary = jsonData.objectForKey("f") as NSDictionary
            let forecastAll = temp.objectForKey("f1") as NSArray
            var theFirstDayForecast:NSDictionary = forecastAll.objectAtIndex(0) as NSDictionary
            
            var date = NSDate()
            var calender:NSCalendar = NSCalendar(identifier: NSGregorianCalendar)!
            var unitFlags:NSCalendarUnit = NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit
            var components:NSDateComponents = calender.components(unitFlags, fromDate: date)
            var hour:NSString = "\(components.hour)"
            var minute:NSString = "\(components.minute)"
            var time:Double = Double(components.hour) + Double(components.minute)/60
            if (time<18) && (time>8) {
                
                var weather = theFirstDayForecast.objectForKey("fa") as NSString
                var temperature = theFirstDayForecast.objectForKey("fc") as NSString
                var windDirection = theFirstDayForecast.objectForKey("fe") as NSString
                var windStrenth = theFirstDayForecast.objectForKey("fg") as NSString
                
                var weatherImage = "day" + weather + ".png"
                cell.weatherImageView.image = UIImage(named: weatherImage)
                cell.temperatureLabel.text = temperature + "℃"
                cell.weatherConditionLabel.text = weatherEncodeToWeatherCondition.objectForKey(weather) as NSString
                
            }
            else {
                
                var weather = theFirstDayForecast.objectForKey("fb") as NSString
                var temperature = theFirstDayForecast.objectForKey("fd") as NSString
                var windDirection = theFirstDayForecast.objectForKey("ff") as NSString
                var windStrenth = theFirstDayForecast.objectForKey("fh") as NSString
                
                var weatherImage = "night" + weather + ".png"
                cell.weatherImageView.image = UIImage(named: weatherImage)
                cell.temperatureLabel.text = temperature + "℃"
                cell.weatherConditionLabel.text = weatherEncodeToWeatherCondition.objectForKey(weather) as NSString
                
            }
        }
        else {
            
            var alertView:UIAlertView = UIAlertView(title: "获取天气数据错误！", message: "网络错误\n我小小NKU Helper也没法知道天气喽\no(╯□╰)o", delegate: nil, cancelButtonTitle: "有道理，不难为你了~")
            alertView.show()
            cell.weatherConditionLabel.text = "N/A"
            cell.temperatureLabel.text = "N/A"
            cell.PM25Label.text = "N/A"
            cell.weatherImageView.image = nil
        }
        
    }
    
    // MARK: seguesInsideTheView
    
    @IBAction func tapOnCurrentCourse(sender: UITapGestureRecognizer) {
        
        
    }
    
    // MARK: storeHouseRefreshControl
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        self.storeHouseRefreshControl.scrollViewDidScroll()
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.storeHouseRefreshControl.scrollViewDidEndDragging()
    }
    
    func refreshTriggered() {
        tableView.reloadData()
        NSTimer.scheduledTimerWithTimeInterval(2.43, target: self, selector: "finishRefreshControl", userInfo: nil, repeats: false)
    }
    
    func finishRefreshControl() {
        self.storeHouseRefreshControl.finishingLoading()
    }
    
}
