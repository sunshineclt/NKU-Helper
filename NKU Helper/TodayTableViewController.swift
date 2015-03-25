//
//  TodayTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/16.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class TodayTableViewController: UITableViewController, UIScrollViewDelegate, UIApplicationDelegate {
    
    // MARK: 下拉刷新的property
    
    @IBOutlet var segmentedController: UISegmentedControl!
    var storeHouseRefreshControl:CBStoreHouseRefreshControl!
    
    // MARK: 渲染Overview Class的颜色
    
    var usedColor:NSMutableArray!
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
    
    
    // MARK: 与weather有关
    
    var recentRefreshWeather:NSDate!
    var timer:NSTimer!
    var receivedWeatherData:NSMutableData?
    let weatherEncodeToWeatherCondition:NSDictionary = ["00":"晴", "01":"多云", "02":"阴", "03":"阵雨", "04":"雷阵雨", "05":"雷阵雨伴有冰雹", "06":"雨夹雪", "07":"小雨", "08":"中雨", "09":"大雨", "10":"暴雨", "11":"大暴雨", "12":"特大暴雨", "13":"阵雪", "14":"小雪", "15":"中雪", "16":"大雪", "17":"暴雪", "18":"雾", "19":"冻雨", "20":"沙尘暴", "21":"小到中雨", "22":"中到大雨", "23":"大到暴雨", "24":"暴雨到大暴雨", "25":"大暴雨到特大暴雨", "26":"小到中雪", "27":"中到大雪", "28":"大到暴雪", "29":"浮尘", "30":"扬沙", "31":"强沙尘暴", "53":"霾", "99":"无"]
    var recentRefreshLifeIndex:NSDate!
    
    // MARK: LifeLoopFunction
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.alwaysBounceVertical = true
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "backgroundImage.jpg"))
        self.storeHouseRefreshControl = CBStoreHouseRefreshControl.attachToScrollView(self.tableView, target: self, refreshAction: "refreshTriggered", plist: "NKU", color: UIColor.whiteColor(), lineWidth: 1.5, dropHeight: 75, scale: 1, horizontalRandomness: 150, reverseLoadingAnimation: false, internalAnimationFactor: 0.5)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resignActive", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enterForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "becomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
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
    
    func resignActive() {
        if let temp = timer {
            timer.invalidate()
        }
    }
    
    func enterForeground() {
        self.tableView.reloadData()
    }
    
    func becomeActive() {
        timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "reload", userInfo: nil, repeats: true)
    }
    
    // MARK: tableView Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        usedColor = NSMutableArray()
        for var i=0;i<12;i++ {
            usedColor.addObject(1)
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedController.selectedSegmentIndex == 0 {
            return 3
        }
        else {
            var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var courses:NSArray? = userDefaults.objectForKey("courses") as? NSArray
            if let temp = courses {
                
                var date = NSDate()
                var calender:NSCalendar = NSCalendar(identifier: NSGregorianCalendar)!
                var unitFlags:NSCalendarUnit = NSCalendarUnit.WeekdayCalendarUnit
                var components:NSDateComponents = calender.components(unitFlags, fromDate: date)
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
                
                var course:NSArray = handleTodayCourses(weekdayInt)
                return course.count
            }
            else {
                
                return 0
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if segmentedController.selectedSegmentIndex == 0 {
            switch (indexPath.row) {
            case 0:
                var cell:time_weatherTableViewCell = tableView.dequeueReusableCellWithIdentifier("time_weather") as time_weatherTableViewCell
                
                var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var account:NSDictionary? = userDefaults.objectForKey("accountInfo") as NSDictionary?
                if let temp = account {
                    handleDate(cell)
                    if let temp = recentRefreshWeather {
                        
                        var date = NSDate()
                        var calender:NSCalendar = NSCalendar(identifier: NSGregorianCalendar)!
                        var unitFlags:NSCalendarUnit = NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.HourCalendarUnit
                        
                        var components:NSDateComponents = calender.components(unitFlags, fromDate: date)
                        var hourNow:Int = components.hour
                        var dayNow:Int = components.day
                        
                        components = calender.components(unitFlags, fromDate: recentRefreshWeather)
                        var hourRecent:Int = components.hour
                        var dayRecent:Int = components.day
                        
                        if (dayNow != dayRecent) || ((hourRecent < 6) && (hourNow >= 6)) || ((hourRecent >= 6) && (hourRecent < 8) && (hourNow >= 8)) || ((hourRecent >= 8) && (hourRecent < 11) && (hourNow >= 11)) || ((hourRecent >= 11) && (hourRecent < 18) && (hourNow >= 18)) {
                            recentRefreshWeather = date
                            refreshWeatherCondition(cell)
                            refreshPM25(cell)
                        }
                    }
                    else {
                        recentRefreshWeather = NSDate()
                        refreshWeatherCondition(cell)
                        refreshPM25(cell)
                    }
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
                }
                else {
                    cell.currentCourseClassroomLabel.text = "N/A"
                    cell.currentCourseNameLabel.text = "N/A"
                    cell.currentCourseTeacherNameLabel.text = "N/A"
                    cell.statusLabel.text = "N/A"
                }
                
                return cell
            default:
                //lifeIndexCell
                
                var cell:LifeIndexTableViewCell = tableView.dequeueReusableCellWithIdentifier("lifeIndex") as LifeIndexTableViewCell
                cell.mainScrollView.delegate = self
                cell.mainScrollView.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width * 3, 100)
                var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var account:NSDictionary? = userDefaults.objectForKey("accountInfo") as NSDictionary?
                if let temp = account {
                    if let temp = recentRefreshLifeIndex {
                        
                        var date = NSDate()
                        var calender:NSCalendar = NSCalendar(identifier: NSGregorianCalendar)!
                        var unitFlags:NSCalendarUnit = NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.HourCalendarUnit
                        
                        var components:NSDateComponents = calender.components(unitFlags, fromDate: date)
                        var hourNow:Int = components.hour
                        var dayNow:Int = components.day
                        
                        components = calender.components(unitFlags, fromDate: recentRefreshLifeIndex)
                        var hourRecent:Int = components.hour
                        var dayRecent:Int = components.day
                        
                        if (dayNow != dayRecent) || ((hourRecent < 6) && (hourNow >= 6)) || ((hourRecent >= 6) && (hourRecent < 8) && (hourNow >= 8)) || ((hourRecent >= 8) && (hourRecent < 11) && (hourNow >= 11)) || ((hourRecent >= 11) && (hourRecent < 18) && (hourNow >= 18)) {
                            recentRefreshLifeIndex = NSDate()
                            refreshLifeIndex(cell)
                        }
                    }
                    else {
                        recentRefreshLifeIndex = NSDate()
                        refreshLifeIndex(cell)
                    }
                }
                
                
                
                return cell
            }
        }
        else {
            var cell:coursesOverViewTableViewCell = tableView.dequeueReusableCellWithIdentifier("coursesOverview") as coursesOverViewTableViewCell
            
            var date = NSDate()
            var calender:NSCalendar = NSCalendar(identifier: NSGregorianCalendar)!
            var unitFlags:NSCalendarUnit = NSCalendarUnit.WeekdayCalendarUnit
            var components:NSDateComponents = calender.components(unitFlags, fromDate: date)
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
            
            var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var todayCourses:NSArray = handleTodayCourses(weekdayInt)
            var courseIndex:Int = todayCourses.objectAtIndex(indexPath.row) as Int
            var courses:NSArray = userDefaults.objectForKey("courses") as NSArray
            var course:NSDictionary = courses.objectAtIndex(courseIndex) as NSDictionary
            cell.classNameLabel.text = course.objectForKey("className") as? NSString
            cell.classroomLabel.text = course.objectForKey("classroom") as? NSString
            cell.teacherNameLabel.text = course.objectForKey("teacherName") as? NSString
            var startSection:Int = course.objectForKey("startSection") as Int
            var sectionNumber:Int = course.objectForKey("sectionNumber") as Int
            cell.startSectionLabel.text = "第\(startSection)节"
            cell.endSectionLabel.text = "第\(startSection + sectionNumber - 1)节"
            
            var imageView:UIImageView = UIImageView(frame: CGRectMake(16, 16, UIScreen.mainScreen().bounds.width - 32, 126))
            var likedColors:NSArray = userDefaults.objectForKey("preferredColors") as NSArray
            var count:Int = 0
            var colorIndex = Int(arc4random_uniform(10))
            
            while (usedColor.objectAtIndex(colorIndex) as Int == 0) || (likedColors.objectAtIndex(colorIndex) as Int == 0) {
                colorIndex = Int(arc4random_uniform(10))
                count++
                if count>1000 {
                    break
                }
                
            }
            imageView.backgroundColor = colors.objectAtIndex(colorIndex) as? UIColor
            imageView.alpha = 1
            imageView.layer.cornerRadius = 8
            cell.backgroundView?.addSubview(imageView)
            usedColor.replaceObjectAtIndex(colorIndex, withObject: 0)
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if segmentedController.selectedSegmentIndex == 0 {
            switch indexPath.row {
            case 0:return 110
            case 1:return 140
            default:return 120
            }
        }
        else {
            
            return 150
            
        }
    }
    
    // MARK: handle Date、Course、Weather、AQI to be presented on view
    
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
            
            switch (hourInt) {
            case 0..<7:
                cell.statusLabel.text = "充足的睡眠是美好一天的开始！"
                cell.currentCourseNameLabel.text = "Have a neat sleep!"
                cell.currentCourseClassroomLabel.text = "@ 寝室"
                cell.currentCourseTeacherNameLabel.text = ""
                var progress:Float = Float(hourInt+2)/9
                cell.progressIndicator.setProgress(progress, animated: true)
            case 7..<8:
                cell.statusLabel.text = "早上好，"
                showCourseInfo(weekdayInt, whichSection: 0, cell: cell)
                var progress:Float = Float(hourInt-7)
                cell.progressIndicator.setProgress(progress, animated: true)
            case 8..<35/4:
                cell.statusLabel.text = "第一节课进行中，"
                showCourseInfo(weekdayInt, whichSection: 0, cell: cell)
                var progress:Float = Float(hourInt-8)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 35/4..<107/12:
                cell.statusLabel.text = "第一节课下课中，"
                showCourseInfo(weekdayInt, whichSection: 1, cell: cell)
                var progress:Float = Float(hourInt-35/4)*6
                cell.progressIndicator.setProgress(progress, animated: true)
            case 107/12..<29/3:
                cell.statusLabel.text = "第二节课进行中，"
                showCourseInfo(weekdayInt, whichSection: 1, cell: cell)
                var progress:Float = Float(hourInt-107/12)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 29/3..<10:
                cell.statusLabel.text = "第二节课下课中，"
                showCourseInfo(weekdayInt, whichSection: 2, cell: cell)
                var progress:Float = Float(hourInt-29/3)*3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 10..<43/4:
                cell.statusLabel.text = "第三节课进行中，"
                showCourseInfo(weekdayInt, whichSection: 2, cell: cell)
                var progress:Float = Float(hourInt-10)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 43/4..<131/12:
                cell.statusLabel.text = "第三节课下课中，"
                showCourseInfo(weekdayInt, whichSection: 3, cell: cell)
                var progress:Float = Float(hourInt-43/4)*6
                cell.progressIndicator.setProgress(progress, animated: true)
            case 131/12..<35/3:
                cell.statusLabel.text = "第四节课进行中，"
                showCourseInfo(weekdayInt, whichSection: 3, cell: cell)
                var progress:Float = Float(hourInt-131/12)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 35/3..<12.5:
                cell.statusLabel.text = "午饭及午休时间"
                cell.currentCourseNameLabel.text = "Have a nice lunch and sleep!"
                cell.currentCourseClassroomLabel.text = "@ 食堂&寝室"
                cell.currentCourseTeacherNameLabel.text = "木有老师~"
                var progress:Float = Float(hourInt-35/3)*6/5
                cell.progressIndicator.setProgress(progress, animated: true)
            case 12.5..<14:
                cell.statusLabel.text = "下午好，"
                showCourseInfo(weekdayInt, whichSection: 4, cell: cell)
                var progress:Float = Float(hourInt-12.5)*2/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 14..<59/4:
                cell.statusLabel.text = "第五节课进行中，"
                showCourseInfo(weekdayInt, whichSection: 4, cell: cell)
                var progress:Float = Float(hourInt-14)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 59/4..<179/12:
                cell.statusLabel.text = "第五节课下课中，"
                showCourseInfo(weekdayInt, whichSection: 5, cell: cell)
                var progress:Float = Float(hourInt-59/4)*6
                cell.progressIndicator.setProgress(progress, animated: true)
            case 179/12..<47/3:
                cell.statusLabel.text = "第六节课进行中，"
                showCourseInfo(weekdayInt, whichSection: 5, cell: cell)
                var progress:Float = Float(hourInt-179/12)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 47/3..<16:
                cell.statusLabel.text = "第六节课下课中，"
                showCourseInfo(weekdayInt, whichSection: 6, cell: cell)
                var progress:Float = Float(hourInt-47/3)*3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 16..<67/4:
                cell.statusLabel.text = "第七节课进行中，"
                showCourseInfo(weekdayInt, whichSection: 6, cell: cell)
                var progress:Float = Float(hourInt-16)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 67/4..<203/12:
                cell.statusLabel.text = "第七节课下课中，"
                showCourseInfo(weekdayInt, whichSection: 7, cell: cell)
                var progress:Float = Float(hourInt-67/4)*6
                cell.progressIndicator.setProgress(progress, animated: true)
            case 203/12..<53/3:
                cell.statusLabel.text = "第八节课进行中，"
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
                cell.statusLabel.text = "晚上好，"
                showCourseInfo(weekdayInt, whichSection: 8, cell: cell)
                var progress:Float = Float(hourInt-18)*2
                cell.progressIndicator.setProgress(progress, animated: true)
            case 18.5..<77/4:
                cell.statusLabel.text = "第九节课进行中，"
                showCourseInfo(weekdayInt, whichSection: 8, cell: cell)
                var progress:Float = Float(hourInt-18.5)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 77/4..<233/12:
                cell.statusLabel.text = "第九节课下课中，"
                showCourseInfo(weekdayInt, whichSection: 9, cell: cell)
                var progress:Float = Float(hourInt-77/4)*6
                cell.progressIndicator.setProgress(progress, animated: true)
            case 233/12..<121/6:
                cell.statusLabel.text = "第十节课进行中，"
                showCourseInfo(weekdayInt, whichSection: 9, cell: cell)
                var progress:Float = Float(hourInt-233/12)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 121/6..<61/3:
                cell.statusLabel.text = "第十节课下课中，"
                showCourseInfo(weekdayInt, whichSection: 10, cell: cell)
                var progress:Float = Float(hourInt-121/6)*6
                cell.progressIndicator.setProgress(progress, animated: true)
            case 61/3..<253/12:
                cell.statusLabel.text = "第十一节课进行中，"
                showCourseInfo(weekdayInt, whichSection: 10, cell: cell)
                var progress:Float = Float(hourInt-61/3)*4/3
                cell.progressIndicator.setProgress(progress, animated: true)
            case 253/12..<85/4:
                cell.statusLabel.text = "第十一节课下课中，"
                showCourseInfo(weekdayInt, whichSection: 11, cell: cell)
                var progress:Float = Float(hourInt-253/12)*6
                cell.progressIndicator.setProgress(progress, animated: true)
            case 85/4..<22:
                cell.statusLabel.text = "第十二节课进行中，"
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
            if i>=courses.count {
                break;
            }
            course = courses.objectAtIndex(i) as NSDictionary
            courseDay = course.objectForKey("day") as Int
        }
        while courseDay == weekday {
            todayCourses.addObject(i)
            i++
            if (i<=courses.count-1) {
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
        var section = whichSection
        var status = todayCourseStatus.objectAtIndex(section) as Int
        while status == -1 {
            section++
            if section == 12 {
                break
            }
            else {
                status = todayCourseStatus.objectAtIndex(section) as Int
            }
        }
        if (section == 12) {
            cell.statusLabel.text = "今天已经木有课啦~"
            cell.currentCourseNameLabel.text = "无课"
            cell.currentCourseClassroomLabel.text = ""
            cell.currentCourseTeacherNameLabel.text = ""
        }
        else {
            var course:NSDictionary = courses.objectAtIndex(status) as NSDictionary
            cell.currentCourseNameLabel.text = course.objectForKey("className") as? String
            cell.currentCourseClassroomLabel.text = course.objectForKey("classroom") as? String
            cell.currentCourseClassroomLabel.text = "@ " + cell.currentCourseClassroomLabel.text!
            cell.currentCourseTeacherNameLabel.text = course.objectForKey("teacherName") as? String
            var startSection:Int = course.objectForKey("startSection") as Int
            var sectionNumber:Int = course.objectForKey("sectionNumber") as Int
            cell.statusLabel.text = cell.statusLabel.text! + "最近一节课是\(startSection)至\(startSection + sectionNumber - 1)节课"
        }
    }
    
    func refreshWeatherCondition(cell: time_weatherTableViewCell) {
        
        var weatherGetter:WeatherConditionGetter = WeatherConditionGetter()
        var API:NSString = weatherGetter.getAPI()
        var url:NSURL = NSURL(string: API)!
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
            
            var date = NSDate()
            var calender:NSCalendar = NSCalendar(identifier: NSGregorianCalendar)!
            var unitFlags:NSCalendarUnit = NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit
            var components:NSDateComponents = calender.components(unitFlags, fromDate: date)
            var hour:NSString = "\(components.hour)"
            var minute:NSString = "\(components.minute)"
            var time:Double = Double(components.hour) + Double(components.minute)/60
            
            if (time < 6) || (time > 8) {
                
                let forecastAll = temp.objectForKey("f1") as NSArray
                var theFirstDayForecast:NSDictionary = forecastAll.objectAtIndex(0) as NSDictionary
                
                
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
                let forecastAll = temp.objectForKey("f1") as NSArray
                var theFirstDayForecast:NSDictionary = forecastAll.objectAtIndex(1) as NSDictionary
                
                var weather = theFirstDayForecast.objectForKey("fa") as NSString
                var temperature = theFirstDayForecast.objectForKey("fc") as NSString
                var windDirection = theFirstDayForecast.objectForKey("fe") as NSString
                var windStrenth = theFirstDayForecast.objectForKey("fg") as NSString
                
                var weatherImage = "day" + weather + ".png"
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
            
            recentRefreshWeather = nil
        }
        
    }
    
    func refreshPM25(cell: time_weatherTableViewCell) {
        
        var urlString:NSString = "http://www.pm25.in/api/querys/only_aqi.json?city=tianjin&token=5j1znBVAsnSf5xQyNQyq&stations=no"
        var url:NSURL = NSURL(string: urlString)!
        var returnData:NSData? = NSData(contentsOfURL: url)
        if let temp = returnData {
            let jsonData:NSArray = NSJSONSerialization.JSONObjectWithData(returnData!, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSArray
            let aqiData:NSDictionary = jsonData.objectAtIndex(0) as NSDictionary
            let aqi:Int = aqiData.objectForKey("aqi") as Int
            let quality:NSString = aqiData.objectForKey("quality") as NSString
            cell.PM25Label.text = "AQI:\(aqi)"
            cell.airQualityLabel.text = quality
        }
        else {
            cell.PM25Label.text = "N/A"
            cell.airQualityLabel.text = "N/A"
        }
    }
    
    func refreshLifeIndex(cell: LifeIndexTableViewCell) {
        
        var weatherGetter:WeatherConditionGetter = WeatherConditionGetter(type: "index_v")
        var API:NSString = weatherGetter.getAPI()
        var url:NSURL = NSURL(string: API)!
        var returnData:NSData? = NSData(contentsOfURL: url)
        if let temp = returnData {
            let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(returnData!, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            let indexData:NSArray = jsonData.objectForKey("i") as NSArray
            
            for (var i=0;i<3;i++) {
                
                var indexDataNow:NSDictionary = indexData.objectAtIndex(i) as NSDictionary
                var indexName:NSString = indexDataNow.objectForKey("i2") as NSString
                var indexBrief:NSString = indexDataNow.objectForKey("i4") as NSString
                var indexDetail:NSString = indexDataNow.objectForKey("i5") as NSString
                
                /*
                print(indexDataNow.objectForKey("i2"))
                print("\n")
                print(indexDataNow.objectForKey("i4"))
                print("\n")
                print(indexDataNow.objectForKey("i5"))
                print("\n")
                */
                
                var offset:CGFloat = UIScreen.mainScreen().bounds.width * CGFloat(i)
                
                var imageView:UIImageView = UIImageView(frame: CGRectMake(offset, 10, 100, 100))
                switch i {
                case 0:imageView.image = UIImage(named: "晨练.png")
                case 1:imageView.image = UIImage(named: "舒适.png")
                default:imageView.image = UIImage(named: "穿衣.png")
                }
                cell.mainScrollView.addSubview(imageView)
                
                var briefLabel:UILabel = UILabel(frame: CGRectMake(offset+100, 5, UIScreen.mainScreen().bounds.width - 110, 30))
                briefLabel.font = UIFont.systemFontOfSize(22)
                briefLabel.text = indexName + "：" + indexBrief
                briefLabel.textColor = UIColor.whiteColor()
                cell.mainScrollView.addSubview(briefLabel)
                
                var detailLabel:UILabel = UILabel(frame: CGRectMake(offset+100, 30, UIScreen.mainScreen().bounds.width - 110, 80))
                detailLabel.numberOfLines = 0
                detailLabel.font = UIFont.systemFontOfSize(13)
                detailLabel.text = indexDetail
                detailLabel.textColor = UIColor.lightTextColor()
                cell.mainScrollView.addSubview(detailLabel)
                
            }
        }
        else {
            recentRefreshLifeIndex = nil
        }
    }
    
    // MARK: seguesInsideTheView
    
    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        
        self.tableView.reloadData()
        if segmentedController.selectedSegmentIndex == 0 {
            self.tableView.backgroundColor = nil
            self.tableView.backgroundView = UIImageView(image: UIImage(named: "backgroundImage.jpg"))
            self.storeHouseRefreshControl = CBStoreHouseRefreshControl.attachToScrollView(self.tableView, target: self, refreshAction: "refreshTriggered", plist: "NKU", color: UIColor.whiteColor(), lineWidth: 1.5, dropHeight: 75, scale: 1, horizontalRandomness: 150, reverseLoadingAnimation: false, internalAnimationFactor: 0.5)
            timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "reload", userInfo: nil, repeats: true)
        }
        else {
            timer.invalidate()
            self.tableView.backgroundView = nil
            self.tableView.backgroundColor = UIColor.whiteColor()
            self.storeHouseRefreshControl = CBStoreHouseRefreshControl.attachToScrollView(self.tableView, target: self, refreshAction: "refreshTriggered", plist: "NKU", color: UIColor.blackColor(), lineWidth: 1.5, dropHeight: 75, scale: 1, horizontalRandomness: 150, reverseLoadingAnimation: false, internalAnimationFactor: 0.5)
        }
        
    }
    
    // MARK: storeHouseRefreshControl
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.tag == 0 {
            self.storeHouseRefreshControl.scrollViewDidScroll()
        }
        else {
            //           print("scrollView 1 scrolled")
        }
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.tag == 0 {
            self.storeHouseRefreshControl.scrollViewDidEndDragging()
        }
        else {
            
        }
    }
    
    func refreshTriggered() {
        
        if segmentedController.selectedSegmentIndex == 0 {
            NSTimer.scheduledTimerWithTimeInterval(2.43, target: self, selector: "finishRefreshControl", userInfo: nil, repeats: false)
            tableView.reloadData()
            
        }
        else {
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "finishRefreshControl", userInfo: nil, repeats: false)
            tableView.reloadData()
            
        }
        
    }
    
    func finishRefreshControl() {
        self.storeHouseRefreshControl.finishingLoading()
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.tag == 1{
            var current = scrollView.contentOffset.x / UIScreen.mainScreen().bounds.size.width
            
            var page:UIPageControl = self.view.viewWithTag(Int(300)) as UIPageControl
            page.currentPage = Int(current)
        }
    }
    
}
