//
//  TodayTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/16.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class TodayTableViewController: UITableViewController, UIScrollViewDelegate, UIApplicationDelegate {
    
    let courseCurrentViewHeight:CGFloat = 260
    
    // MARK: 下拉刷新的property
    
    @IBOutlet var segmentedController: UISegmentedControl!
    var storeHouseRefreshControl:CBStoreHouseRefreshControl!
  //  var isRefreshControllerAnimating:Bool = false
    
    // MARK: 渲染Overview Class的颜色
    
    var usedColor:[Int]!
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
    
    var timer:NSTimer!
    var receivedWeatherData:NSMutableData?
    let weatherEncodeToWeatherCondition:Dictionary<String, String> = ["00":"晴", "01":"多云", "02":"阴", "03":"阵雨", "04":"雷阵雨", "05":"雷阵雨伴有冰雹", "06":"雨夹雪", "07":"小雨", "08":"中雨", "09":"大雨", "10":"暴雨", "11":"大暴雨", "12":"特大暴雨", "13":"阵雪", "14":"小雪", "15":"中雪", "16":"大雪", "17":"暴雪", "18":"雾", "19":"冻雨", "20":"沙尘暴", "21":"小到中雨", "22":"中到大雨", "23":"大到暴雨", "24":"暴雨到大暴雨", "25":"大暴雨到特大暴雨", "26":"小到中雪", "27":"中到大雪", "28":"大到暴雪", "29":"浮尘", "30":"扬沙", "31":"强沙尘暴", "53":"霾", "99":"无"]
    
    //
    
    var currentCourse:Int!
    
    // MARK: View LifeCycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.alwaysBounceVertical = true
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "backgroundImage.jpg"))
        self.storeHouseRefreshControl = CBStoreHouseRefreshControl.attachToScrollView(self.tableView, target: self, refreshAction: "refreshTriggered", plist: "NKU", color: UIColor.whiteColor(), lineWidth: 1.5, dropHeight: 75, scale: 1, horizontalRandomness: 150, reverseLoadingAnimation: false, internalAnimationFactor: 0.5)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resignActive", name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enterForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "becomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        self.tableView.contentOffset = CGPointMake(0, -100)
        self.storeHouseRefreshControl.scrollViewDidEndDragging()

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
        usedColor = []
        for var i=0;i<12;i++ {
            usedColor.append(1)
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedController.selectedSegmentIndex == 0 {
            return 2
        }
        else {
            var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var courses:NSArray? = userDefaults.objectForKey("courses") as? NSArray
            if let temp = courses {
                
                var date = NSDate()
                var calender:NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
                var unitFlags:NSCalendarUnit = NSCalendarUnit.CalendarUnitWeekday
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
            // Now页面
            
            switch (indexPath.row) {
            case 0:
                // 显示天气、日期、状态条
                var cell:TimeWeatherStatusTableViewCell = tableView.dequeueReusableCellWithIdentifier("time_weather") as! TimeWeatherStatusTableViewCell
                
                handleDate(cell)
                refreshWeatherCondition(cell)
                refreshPM25(cell)
                
                return cell
            case 1:
                // 显示当前课程
                
                var cell:courseCurrentTableViewCell = tableView.dequeueReusableCellWithIdentifier("courseCurrent") as! courseCurrentTableViewCell
                
                var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var account:NSDictionary? = userDefaults.objectForKey("accountInfo") as? NSDictionary
                if let temp = account {

                    var toValue:Float! = handleStatus(cell)
                    if let valueTemp = toValue {
                        var anim:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPShapeLayerStrokeEnd)
                        anim.duration = 1
                        anim.toValue = toValue
                        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                        let layers = cell.animateView.layer.sublayers
                        for i in layers {
                            if i.isKindOfClass(CAShapeLayer) {
                                let layer = i as! CAShapeLayer
                                layer.pop_addAnimation(anim, forKey: "show")
                            }
                        }
                    }
                    
                }
                else {
                    
                    var alert:UIAlertView = UIAlertView(title: "您尚未登录", message: "登录后方可使用NKU Helper\n登录选项位于设置选项卡中", delegate: nil, cancelButtonTitle: "好的")
                    alert.show()
                    
                    cell.currentCourseClassroomLabel.text = "不知道诶！"
                    cell.currentCourseNameLabel.text = "不知道诶！"
                    cell.currentCourseTeacherNameLabel.text = "不知道诶！"
                    cell.statusLabel.text = "不知道诶！"
                }
                
                return cell
            default:
                var 💩:UITableViewCell? = self.tableView.dequeueReusableCellWithIdentifier("miaomiao") as? UITableViewCell
                return 💩!
            }
        }
        else {
            // courseOverView
            
            var cell:coursesOverViewTableViewCell = tableView.dequeueReusableCellWithIdentifier("coursesOverview") as! coursesOverViewTableViewCell
            
            var date = NSDate()
            var calender:NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
            var unitFlags:NSCalendarUnit = NSCalendarUnit.CalendarUnitWeekday
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
            var courseIndex:Int = todayCourses.objectAtIndex(indexPath.row) as! Int
            var courses:NSArray = userDefaults.objectForKey("courses") as! NSArray
            var course:NSDictionary = courses.objectAtIndex(courseIndex) as! NSDictionary
            cell.classNameLabel.text = course.objectForKey("className") as? String
            cell.classroomLabel.text = course.objectForKey("classroom") as? String
            cell.teacherNameLabel.text = course.objectForKey("teacherName") as? String
            var startSection:Int = course.objectForKey("startSection") as! Int
            var sectionNumber:Int = course.objectForKey("sectionNumber") as! Int
            cell.startSectionLabel.text = "第\(startSection)节"
            cell.endSectionLabel.text = "第\(startSection + sectionNumber - 1)节"
            
            var imageView:UIImageView = UIImageView(frame: CGRectMake(16, 16, UIScreen.mainScreen().bounds.width - 32, 126))
            var likedColors:NSArray = userDefaults.objectForKey("preferredColors") as! NSArray
            var count:Int = 0
            var colorIndex = Int(arc4random_uniform(10))
            
            while (usedColor[colorIndex] == 0) || (likedColors.objectAtIndex(colorIndex) as! Int == 0) {
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
            usedColor[colorIndex] = 0
            
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if segmentedController.selectedSegmentIndex == 0 {
            switch indexPath.row {
            case 0:return 100
            case 1:return courseCurrentViewHeight
            default:return 120
            }
        }
        else {
            
            return 150
            
        }
    }
    
    // MARK: handle Date、Course、Weather、AQI to be presented on view
    
    func handleDate(cell: TimeWeatherStatusTableViewCell) {
        
        var date = NSDate()
        var calender:NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        var unitFlags:NSCalendarUnit = NSCalendarUnit.CalendarUnitWeekday | NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond
        var components:NSDateComponents = calender.components(unitFlags, fromDate: date)
        var year:String = "\(components.year)"
        var month:String = "\(components.month)"
        var day:String = "\(components.day)"
        var hour:String = "\(components.hour)"
        var minute:String = "\(components.minute)"
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
        default:weekday = "星期N"
        }
        if count(hour) < 2 {
            hour = "0" + hour
        }
        if count(minute) < 2 {
            minute = "0" + minute
        }
        
        cell.dateLabel.text = month + "月" + day + "日"
        cell.weekdayLabel.text = weekday
        
    }
    
    func handleStatus(cell: courseCurrentTableViewCell) -> Float! {
        
        var date = NSDate()
        var calender:NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        var unitFlags:NSCalendarUnit = NSCalendarUnit.CalendarUnitWeekday | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute
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
        
        var hourInt:Double = Double(components.hour) + Double(components.minute)/60
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var courses:NSArray? = userDefaults.objectForKey("courses") as? NSArray
        
        if let temp = courses {
            
            var courseStatus:NSArray = userDefaults.objectForKey("courseStatus") as! NSArray
            var todayCourseStatus:NSArray = courseStatus.objectAtIndex(weekdayInt) as! NSArray
            
            switch (hourInt) {
            case 0..<7:
//                cell.statusLabel.text = "充足的睡眠是美好一天的开始！"
                cell.currentCourseNameLabel.text = "充足的睡眠是美好一天的开始!"
                cell.currentCourseClassroomLabel.text = "@ 寝室"
                cell.currentCourseTeacherNameLabel.text = ""
                var progress:Float = Float(hourInt+2)/10
                currentCourse = -1
                return progress
            case 7..<8:
                cell.statusLabel.text = "早上好"
                showCourseInfo(weekdayInt, whichSection: 0, cell: cell)
                currentCourse = 0
                var progress:Float = Float(hourInt+2)/10
                return progress
            case 8..<35/4:
                cell.statusLabel.text = "第一节课进行中"
                showCourseInfo(weekdayInt, whichSection: 0, cell: cell)
                currentCourse = 0
                var progress:Float = Float(hourInt-8)*4/3
                return progress
            case 35/4..<107/12:
                cell.statusLabel.text = "第一节课下课中"
                showCourseInfo(weekdayInt, whichSection: 1, cell: cell)
                currentCourse = 1
                var progress:Float = Float(hourInt-35/4)*6
                return progress
            case 107/12..<29/3:
                cell.statusLabel.text = "第二节课进行中"
                showCourseInfo(weekdayInt, whichSection: 1, cell: cell)
                currentCourse = 1
                var progress:Float = Float(hourInt-107/12)*4/3
                return progress
            case 29/3..<10:
                cell.statusLabel.text = "第二节课下课中"
                showCourseInfo(weekdayInt, whichSection: 2, cell: cell)
                currentCourse = 2
                var progress:Float = Float(hourInt-29/3)*3
                return progress
            case 10..<43/4:
                cell.statusLabel.text = "第三节课进行中"
                showCourseInfo(weekdayInt, whichSection: 2, cell: cell)
                currentCourse = 2
                var progress:Float = Float(hourInt-10)*4/3
                return progress
            case 43/4..<131/12:
                cell.statusLabel.text = "第三节课下课中"
                showCourseInfo(weekdayInt, whichSection: 3, cell: cell)
                currentCourse = 3
                var progress:Float = Float(hourInt-43/4)*6
                return progress
            case 131/12..<35/3:
                cell.statusLabel.text = "第四节课进行中"
                showCourseInfo(weekdayInt, whichSection: 3, cell: cell)
                currentCourse = 3
                var progress:Float = Float(hourInt-131/12)*4/3
                return progress
            case 35/3..<12.5:
                cell.statusLabel.text = "午饭及午休时间"
                cell.currentCourseNameLabel.text = "Have a nice lunch and sleep!"
                cell.currentCourseClassroomLabel.text = "@ 食堂&寝室"
                cell.currentCourseTeacherNameLabel.text = "木有老师~"
                currentCourse = -1
                var progress:Float = Float(hourInt-35/3)*3/7
                return progress
            case 12.5..<14:
                cell.statusLabel.text = "下午好"
                showCourseInfo(weekdayInt, whichSection: 4, cell: cell)
                currentCourse = 4
                var progress:Float = Float(hourInt-35/3)*3/7
                return progress
            case 14..<59/4:
                cell.statusLabel.text = "第五节课进行中"
                showCourseInfo(weekdayInt, whichSection: 4, cell: cell)
                currentCourse = 4
                var progress:Float = Float(hourInt-14)*4/3
                return progress
            case 59/4..<179/12:
                cell.statusLabel.text = "第五节课下课中"
                showCourseInfo(weekdayInt, whichSection: 5, cell: cell)
                currentCourse = 5
                var progress:Float = Float(hourInt-59/4)*6
                return progress
            case 179/12..<47/3:
                cell.statusLabel.text = "第六节课进行中"
                showCourseInfo(weekdayInt, whichSection: 5, cell: cell)
                currentCourse = 5
                var progress:Float = Float(hourInt-179/12)*4/3
                return progress
            case 47/3..<16:
                cell.statusLabel.text = "第六节课下课中"
                showCourseInfo(weekdayInt, whichSection: 6, cell: cell)
                currentCourse = 6
                var progress:Float = Float(hourInt-47/3)*3
                return progress
            case 16..<67/4:
                cell.statusLabel.text = "第七节课进行中"
                showCourseInfo(weekdayInt, whichSection: 6, cell: cell)
                currentCourse = 6
                var progress:Float = Float(hourInt-16)*4/3
                return progress
            case 67/4..<203/12:
                cell.statusLabel.text = "第七节课下课中"
                showCourseInfo(weekdayInt, whichSection: 7, cell: cell)
                currentCourse = 7
                var progress:Float = Float(hourInt-67/4)*6
                return progress
            case 203/12..<53/3:
                cell.statusLabel.text = "第八节课进行中"
                showCourseInfo(weekdayInt, whichSection: 7, cell: cell)
                currentCourse = 7
                var progress:Float = Float(hourInt-203/12)*4/3
                return progress
            case 53/3..<18:
                cell.statusLabel.text = "晚餐时间"
                cell.currentCourseNameLabel.text = "Have a nice dinner!"
                cell.currentCourseClassroomLabel.text = "@ 食堂"
                cell.currentCourseTeacherNameLabel.text = "木有老师~"
                currentCourse = -1
                var progress:Float = Float(hourInt-53/3)*6/5
                return progress
            case 18..<18.5:
                cell.statusLabel.text = "晚上好"
                showCourseInfo(weekdayInt, whichSection: 8, cell: cell)
                currentCourse = 8
                var progress:Float = Float(hourInt-53/3)*6/5
                return progress
            case 18.5..<77/4:
                cell.statusLabel.text = "第九节课进行中"
                showCourseInfo(weekdayInt, whichSection: 8, cell: cell)
                currentCourse = 8
                var progress:Float = Float(hourInt-18.5)*4/3
                return progress
            case 77/4..<233/12:
                cell.statusLabel.text = "第九节课下课中"
                showCourseInfo(weekdayInt, whichSection: 9, cell: cell)
                currentCourse = 9
                var progress:Float = Float(hourInt-77/4)*6
                return progress
            case 233/12..<121/6:
                cell.statusLabel.text = "第十节课进行中"
                showCourseInfo(weekdayInt, whichSection: 9, cell: cell)
                currentCourse = 9
                var progress:Float = Float(hourInt-233/12)*4/3
                return progress
            case 121/6..<61/3:
                cell.statusLabel.text = "第十节课下课中"
                showCourseInfo(weekdayInt, whichSection: 10, cell: cell)
                currentCourse = 10
                var progress:Float = Float(hourInt-121/6)*6
                return progress
            case 61/3..<253/12:
                cell.statusLabel.text = "第十一节课进行中"
                showCourseInfo(weekdayInt, whichSection: 10, cell: cell)
                currentCourse = 10
                var progress:Float = Float(hourInt-61/3)*4/3
                return progress
            case 253/12..<85/4:
                cell.statusLabel.text = "第十一节课下课中"
                showCourseInfo(weekdayInt, whichSection: 11, cell: cell)
                currentCourse = 11
                var progress:Float = Float(hourInt-253/12)*6
                return progress
            case 85/4..<22:
                cell.statusLabel.text = "第十二节课进行中"
                showCourseInfo(weekdayInt, whichSection: 11, cell: cell)
                currentCourse = 11
                var progress:Float = Float(hourInt-85/4)*4/3
                return progress
            default:
                cell.statusLabel.text = "忙碌的一天结束啦"
                cell.currentCourseNameLabel.text = "Have a neat sleep!"
                cell.currentCourseClassroomLabel.text = "@ 寝室"
                cell.currentCourseTeacherNameLabel.text = ""
                currentCourse = -1
                var progress:Float = Float(hourInt-22)/10
                return progress
            }
        }
        else {
            
            //没有course信息
            cell.statusLabel.text = "不知道诶！"
            cell.currentCourseNameLabel.text = "不知道诶!"
            cell.currentCourseClassroomLabel.text = "@ 不知道诶！"
            cell.currentCourseTeacherNameLabel.text = "不知道诶！"
            var alert:UIAlertView = UIAlertView(title: "数据错误", message: "还未加载课程数据\n请先到课程表页面加载课程数据", delegate: nil, cancelButtonTitle: "好的，马上去！")
            currentCourse = -1
            alert.show()
            return nil
        }
    }
    
    func handleTodayCourses(weekday:Int) -> NSArray {
        
        var todayCourses:NSMutableArray = NSMutableArray()
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var courses:NSArray = userDefaults.objectForKey("courses") as! NSArray
        var i:Int = 0
        var course:NSDictionary = courses.objectAtIndex(i) as! NSDictionary
        var courseDay:Int = course.objectForKey("day") as! Int
        while (courseDay != weekday) {
            i++
            if i>=courses.count {
                break;
            }
            course = courses.objectAtIndex(i) as! NSDictionary
            courseDay = course.objectForKey("day") as! Int
        }
        while courseDay == weekday {
            todayCourses.addObject(i)
            i++
            if (i<=courses.count-1) {
                course = courses.objectAtIndex(i) as! NSDictionary
                courseDay = course.objectForKey("day") as! Int
            }
            else {
                break
            }
        }
        
        return todayCourses
    }
    
    func showCourseInfo(weekdayInt:Int, whichSection:Int, cell: courseCurrentTableViewCell) {
        
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var courseStatus:NSArray = userDefaults.objectForKey("courseStatus") as! NSArray
        var todayCourseStatus:NSArray = courseStatus.objectAtIndex(weekdayInt) as! NSArray
        var courses:NSArray = userDefaults.objectForKey("courses") as! NSArray
        var section = whichSection
        var status = todayCourseStatus.objectAtIndex(section) as! Int
        var isPresentCourse = true
        while status == -1 {
            isPresentCourse = true
            section++
            if section == 12 {
                break
            }
            else {
                status = todayCourseStatus.objectAtIndex(section) as! Int
            }
        }
        if (section == 12) {
            cell.statusLabel.text = "今天已经木有课啦~"
            cell.currentCourseNameLabel.text = "无课"
            cell.currentCourseClassroomLabel.text = ""
            cell.currentCourseTeacherNameLabel.text = ""
        }
        else {
            var course:NSDictionary = courses.objectAtIndex(status) as! NSDictionary
            cell.currentCourseNameLabel.text = course.objectForKey("className") as? String
            cell.currentCourseClassroomLabel.text = course.objectForKey("classroom") as? String
            cell.currentCourseClassroomLabel.text = "@ " + cell.currentCourseClassroomLabel.text!
            cell.currentCourseTeacherNameLabel.text = course.objectForKey("teacherName") as? String
            var startSection:Int = course.objectForKey("startSection") as! Int
            var sectionNumber:Int = course.objectForKey("sectionNumber") as! Int
            if !isPresentCourse {
                cell.statusLabel.text = "最近一节课是\(startSection)至\(startSection + sectionNumber - 1)节课"
            }
        }
    }
    
    func refreshWeatherCondition(cell: TimeWeatherStatusTableViewCell) {
        
        var date = NSDate()
        var calender:NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        var unitFlags:NSCalendarUnit = NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute
        var components:NSDateComponents = calender.components(unitFlags, fromDate: date)
        var hour:NSString = "\(components.hour)"
        var minute:NSString = "\(components.minute)"
        var time:Double = Double(components.hour) + Double(components.minute)/60
        
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var weather:NSDictionary? = userDefaults.objectForKey("weather") as? NSDictionary
        
        if let temp = weather {
            
            var firstDay:NSDictionary = temp.objectForKey("firstDay") as! NSDictionary
            var secondDay:NSDictionary = temp.objectForKey("secondDay") as! NSDictionary
            
            switch time {
            case 0...6:
                fallthrough
            case 18...24:
                var weatherCondition = firstDay.objectForKey("nightWeather") as! String
                var weatherImage = "night" + weatherCondition + ".png"
                cell.weatherImageView.image = UIImage(named: weatherImage)
                cell.temperatureLabel.text = "温度：" + (firstDay.objectForKey("nightTemperature") as! String) + "℃"
                cell.weatherConditionLabel.text = weatherEncodeToWeatherCondition[weatherCondition]
            case 6...8:
                var weatherCondition = secondDay.objectForKey("dayWeather") as! String
                var weatherImage = "day" + weatherCondition + ".png"
                cell.weatherImageView.image = UIImage(named: weatherImage)
                cell.temperatureLabel.text = "温度：" + (firstDay.objectForKey("dayTemperature") as! String) + "℃"
                cell.weatherConditionLabel.text = weatherEncodeToWeatherCondition[weatherCondition]
            case 8...18:
                var weatherCondition = firstDay.objectForKey("dayWeather") as! String
                var weatherImage = "day" + weatherCondition + ".png"
                cell.weatherImageView.image = UIImage(named: weatherImage)
                cell.temperatureLabel.text = "温度：" + (firstDay.objectForKey("dayTemperature") as! String) + "℃"
                cell.weatherConditionLabel.text = weatherEncodeToWeatherCondition[weatherCondition]
            default:
                cell.weatherConditionLabel.text = "???"
            }
        }
        else {
            cell.weatherImageView.image = UIImage(named: "day00.png")
            cell.temperatureLabel.text = "不知道"
            cell.weatherConditionLabel.text = "不知道"
        }
    }
    
    func refreshPM25(cell: TimeWeatherStatusTableViewCell) {
        
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var weather:NSDictionary? = userDefaults.objectForKey("weather") as? NSDictionary
        if let temp = weather {
            
            var aqi:Int? = weather?.objectForKey("aqi") as? Int
            var quality:String? = weather?.objectForKey("quality") as? String
            if let qualitytemp = quality {
                cell.PM25Label.text = "AQI:\(aqi!)"
                cell.airQualityLabel.text = quality
            }
            else {
                cell.PM25Label.text = "不知道"
                cell.airQualityLabel.text = "不知道"
            }
        }
        else {
            cell.PM25Label.text = "不知道"
            cell.airQualityLabel.text = "不知道"
        }
        
    }
    
    // MARK: seguesInsideTheView
    
    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        
        self.tableView.reloadData()
        if segmentedController.selectedSegmentIndex == 0 {
            self.tableView.backgroundColor = nil
            self.tableView.backgroundView = UIImageView(image: UIImage(named: "backgroundImage.jpg"))
            self.storeHouseRefreshControl.finishingLoading()
            self.storeHouseRefreshControl = nil
            self.storeHouseRefreshControl = CBStoreHouseRefreshControl.attachToScrollView(self.tableView, target: self, refreshAction: "refreshTriggered", plist: "NKU", color: UIColor.whiteColor(), lineWidth: 1.5, dropHeight: 75, scale: 1, horizontalRandomness: 150, reverseLoadingAnimation: false, internalAnimationFactor: 0.5)
            timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "reload", userInfo: nil, repeats: true)
        }
        else {
            timer.invalidate()
            self.tableView.backgroundView = nil
            self.tableView.backgroundColor = UIColor.whiteColor()
            self.storeHouseRefreshControl.finishingLoading()
            self.storeHouseRefreshControl = nil
            self.storeHouseRefreshControl = CBStoreHouseRefreshControl.attachToScrollView(self.tableView, target: self, refreshAction: "refreshTriggered", plist: "NKU", color: UIColor.blackColor(), lineWidth: 1.5, dropHeight: 75, scale: 1, horizontalRandomness: 150, reverseLoadingAnimation: false, internalAnimationFactor: 0.5)
        }
        
    }
    
    // MARK: seguesOutsideTheView
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        
        if identifier == "showCourseDetail" {
            
            if let temp = currentCourse {
                if currentCourse == -1 {
                    return false
                }
                else {
                    return true
                }
            }
            else {
                return false
            }
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showCourseDetail" {
            
            var vc = segue.destinationViewController as! CourseDetailTableViewController
            vc.whichCourse = currentCourse
        }
        
    }
    
    // MARK: storeHouseRefreshControl & ScrollViewDelegate
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.tag == 100 {
            self.storeHouseRefreshControl.scrollViewDidScroll()
        }
        else {
            //           print("scrollView 1 scrolled")
        }
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.tag == 100 {
            self.storeHouseRefreshControl.scrollViewDidEndDragging()
        }
        else {
            
        }
    }
    
    func refreshTriggered() {
        
        if segmentedController.selectedSegmentIndex == 0 {
            var weatherInfoGetter:WeatherInfoGetter = WeatherInfoGetter { () -> Void in
                self.finishRefreshControl()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()

                })
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                weatherInfoGetter.getAllWeatherInfo()
            })
        }
        else {
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "finishRefreshControl", userInfo: nil, repeats: false)
            tableView.reloadData()
            
        }
        
    }
    
    func finishRefreshControl() {
        if segmentedController.selectedSegmentIndex == 0 {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), { () -> Void in
                self.storeHouseRefreshControl.finishingLoading()
            })
        }
        else {
            self.storeHouseRefreshControl.finishingLoading()
        }
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.tag == 101{
            var current = scrollView.contentOffset.x / UIScreen.mainScreen().bounds.size.width
            
            var page:UIPageControl = self.view.viewWithTag(Int(102)) as! UIPageControl
            page.currentPage = Int(current)
        }
    }
    
}
