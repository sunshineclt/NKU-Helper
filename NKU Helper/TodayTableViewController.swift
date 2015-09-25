//
//  TodayTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/16.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class TodayTableViewController: UITableViewController, UIApplicationDelegate {

    let courseCurrentViewHeight:CGFloat = 260
    
    // MARK: 下拉刷新的property
    
    @IBOutlet var segmentedController: UISegmentedControl!
    var storeHouseRefreshControl:CBStoreHouseRefreshControl!
    
    // MARK: 渲染Overview Class的颜色
    
    var usedColor:[Int]!
    var colors:Colors = Colors()

    // MARK: 与weather有关
    
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
        self.segmentedController.tintColor = UIColor(red: 16/255, green: 128/255, blue: 207/255, alpha: 1)
        self.tableView.contentOffset = CGPointMake(0, -100)
        self.storeHouseRefreshControl.scrollViewDidEndDragging()
        self.tableView.estimatedRowHeight = self.tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let accountInfo:NSDictionary? = userDefaults.objectForKey("accountInfo") as? NSDictionary
        if let _ = accountInfo {
            
        }
        else {
            
            self.performSegueWithIdentifier("login", sender: nil)
            
        }
            

    }
    
    // MARK: tableView Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        currentCourse = -1
        usedColor = []
        for var i=0;i<colors.colors.count;i++ {
            usedColor.append(1)
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedController.selectedSegmentIndex == 0 {
            return 2
        }
        else {
            let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let courses:NSArray? = userDefaults.objectForKey("courses") as? NSArray
            if let _ = courses {
                
                let weekdayInt = CalendarConverter.weekdayInt()
                let course:NSArray = handleTodayCourses(weekdayInt)
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
                let cell:TimeWeatherStatusTableViewCell = tableView.dequeueReusableCellWithIdentifier("time_weather") as! TimeWeatherStatusTableViewCell
                
                handleDate(cell)
                refreshWeatherCondition(cell)
                refreshPM25(cell)
                
                return cell
            case 1:
                // 显示当前课程
                
                let cell:courseCurrentTableViewCell = tableView.dequeueReusableCellWithIdentifier("courseCurrent") as! courseCurrentTableViewCell
                
                let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                let account:NSDictionary? = userDefaults.objectForKey("accountInfo") as? NSDictionary
                if let _ = account {

                    let toValue:Float! = handleStatus(cell)
                    if let _ = toValue {
                        let anim:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPShapeLayerStrokeEnd)
                        anim.duration = 1
                        anim.toValue = toValue
                        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                        let layers = cell.animateView.layer.sublayers
                        for i in layers! {
                            if i.isKindOfClass(CAShapeLayer) {
                                let layer = i as! CAShapeLayer
                                layer.pop_addAnimation(anim, forKey: "show")
                            }
                        }
                    }
                    
                }
                else {
                    
                    cell.currentCourseClassroomLabel.text = "不知道诶！"
                    cell.currentCourseNameLabel.text = "不知道诶！"
                    cell.currentCourseTimeLabel.text = "不知道诶！"
                    cell.statusLabel.text = "不知道诶！"
                }
                
                return cell
            default:
                let 💩:UITableViewCell? = self.tableView.dequeueReusableCellWithIdentifier("miaomiao") as UITableViewCell?
                return 💩!
            }
        }
        else {
            // courseOverView
            
            let cell:coursesOverViewTableViewCell = tableView.dequeueReusableCellWithIdentifier("coursesOverview") as! coursesOverViewTableViewCell
            
            let weekdayInt = CalendarConverter.weekdayInt()
            
            let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let todayCourses:NSArray = handleTodayCourses(weekdayInt)
            let courseIndex:Int = todayCourses.objectAtIndex(indexPath.row) as! Int
            let courses:NSArray = userDefaults.objectForKey("courses") as! NSArray
            let courseData = courses.objectAtIndex(courseIndex) as! NSData
            let course = NSKeyedUnarchiver.unarchiveObjectWithData(courseData) as! Course
            cell.classNameLabel.text = course.name
            cell.classroomLabel.text = course.classroom
            cell.teacherNameLabel.text = course.teacherName
            let startSection:Int = course.startSection
            let sectionNumber:Int = course.sectionNumber
            cell.startSectionLabel.text = "第\(startSection)节"
            cell.endSectionLabel.text = "第\(startSection + sectionNumber - 1)节"
            
            let imageView:UIImageView = UIImageView(frame: CGRectMake(16, 16, UIScreen.mainScreen().bounds.width - 32, 126))
            let likedColors:NSArray = userDefaults.objectForKey("preferredColors") as! NSArray
            var count:Int = 0
            var colorIndex = Int(arc4random_uniform(UInt32(colors.colors.count)))
            
            while (usedColor[colorIndex] == 0) || (likedColors.objectAtIndex(colorIndex) as! Int == 0) {
                colorIndex = Int(arc4random_uniform(UInt32(colors.colors.count)))
                count++
                if count>1000 {
                    break
                }
                
            }
            imageView.backgroundColor = colors.colors[colorIndex]
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
        
        let (month, day, weekday) = CalendarConverter.monthDayWeekdayString()
        
        cell.dateLabel.text = month + "月" + day + "日"
        cell.weekdayLabel.text = weekday
        
    }
    
    func handleStatus(cell: courseCurrentTableViewCell) -> Float! {
        
        let (weekdayInt, timeInt) = CalendarConverter.weekdayTimeInt()
        
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let courses:NSArray? = userDefaults.objectForKey("courses") as? NSArray
        
        if let _ = courses {
            
            switch (timeInt) {
            case 0..<7:
                cell.statusLabel.text = "充足的睡眠是美好一天的开始！"
                cell.currentCourseNameLabel.text = "充足的睡眠是美好一天的开始!"
                cell.currentCourseClassroomLabel.text = "@ 寝室"
                cell.currentCourseTimeLabel.text = "睡到七点吧~"
                currentCourse = -1
                let progress:Float = Float(timeInt+2)/10
                return progress
            case 7..<8:
                cell.statusLabel.text = "早上好，最近一节课是"
                showCourseInfo(weekdayInt, whichSection: 0, cell: cell)
                let progress:Float = Float(timeInt+2)/10
                return progress
            case 8..<35/4:
                cell.statusLabel.text = "第一节课进行中"
                showCourseInfo(weekdayInt, whichSection: 0, cell: cell)
                let progress:Float = Float(timeInt-8)*4/3
                return progress
            case 35/4..<107/12:
                cell.statusLabel.text = "第一节课下课中"
                showCourseInfo(weekdayInt, whichSection: 1, cell: cell)
                let progress:Float = Float(timeInt-35/4)*6
                return progress
            case 107/12..<29/3:
                cell.statusLabel.text = "第二节课进行中"
                showCourseInfo(weekdayInt, whichSection: 1, cell: cell)
                let progress:Float = Float(timeInt-107/12)*4/3
                return progress
            case 29/3..<10:
                cell.statusLabel.text = "第二节课下课中"
                showCourseInfo(weekdayInt, whichSection: 2, cell: cell)
                let progress:Float = Float(timeInt-29/3)*3
                return progress
            case 10..<43/4:
                cell.statusLabel.text = "第三节课进行中"
                showCourseInfo(weekdayInt, whichSection: 2, cell: cell)
                let progress:Float = Float(timeInt-10)*4/3
                return progress
            case 43/4..<131/12:
                cell.statusLabel.text = "第三节课下课中"
                showCourseInfo(weekdayInt, whichSection: 3, cell: cell)
                let progress:Float = Float(timeInt-43/4)*6
                return progress
            case 131/12..<35/3:
                cell.statusLabel.text = "第四节课进行中"
                showCourseInfo(weekdayInt, whichSection: 3, cell: cell)
                let progress:Float = Float(timeInt-131/12)*4/3
                return progress
            case 35/3..<12.5:
                cell.statusLabel.text = "午饭及午休时间"
                cell.currentCourseNameLabel.text = "Have a nice lunch and sleep!"
                cell.currentCourseClassroomLabel.text = "@ 食堂&寝室"
                cell.currentCourseTimeLabel.text = "睡到一点半吧~"
                currentCourse = -1
                let progress:Float = Float(timeInt-35/3)*3/7
                return progress
            case 12.5..<14:
                cell.statusLabel.text = "下午好，最近一节课是"
                showCourseInfo(weekdayInt, whichSection: 4, cell: cell)
                let progress:Float = Float(timeInt-35/3)*3/7
                return progress
            case 14..<59/4:
                cell.statusLabel.text = "第五节课进行中"
                showCourseInfo(weekdayInt, whichSection: 4, cell: cell)
                let progress:Float = Float(timeInt-14)*4/3
                return progress
            case 59/4..<179/12:
                cell.statusLabel.text = "第五节课下课中"
                showCourseInfo(weekdayInt, whichSection: 5, cell: cell)
                let progress:Float = Float(timeInt-59/4)*6
                return progress
            case 179/12..<47/3:
                cell.statusLabel.text = "第六节课进行中"
                showCourseInfo(weekdayInt, whichSection: 5, cell: cell)
                let progress:Float = Float(timeInt-179/12)*4/3
                return progress
            case 47/3..<16:
                cell.statusLabel.text = "第六节课下课中"
                showCourseInfo(weekdayInt, whichSection: 6, cell: cell)
                let progress:Float = Float(timeInt-47/3)*3
                return progress
            case 16..<67/4:
                cell.statusLabel.text = "第七节课进行中"
                showCourseInfo(weekdayInt, whichSection: 6, cell: cell)
                let progress:Float = Float(timeInt-16)*4/3
                return progress
            case 67/4..<203/12:
                cell.statusLabel.text = "第七节课下课中"
                showCourseInfo(weekdayInt, whichSection: 7, cell: cell)
                let progress:Float = Float(timeInt-67/4)*6
                return progress
            case 203/12..<53/3:
                cell.statusLabel.text = "第八节课进行中"
                showCourseInfo(weekdayInt, whichSection: 7, cell: cell)
                let progress:Float = Float(timeInt-203/12)*4/3
                return progress
            case 53/3..<18:
                cell.statusLabel.text = "晚餐时间"
                cell.currentCourseNameLabel.text = "Have a nice dinner!"
                cell.currentCourseClassroomLabel.text = "@ 食堂"
                cell.currentCourseTimeLabel.text = "细嚼慢咽助消化~"
                currentCourse = -1
                let progress:Float = Float(timeInt-53/3)*6/5
                return progress
            case 18..<18.5:
                cell.statusLabel.text = "晚上好，最近一节课是"
                showCourseInfo(weekdayInt, whichSection: 8, cell: cell)
                let progress:Float = Float(timeInt-53/3)*6/5
                return progress
            case 18.5..<77/4:
                cell.statusLabel.text = "第九节课进行中"
                showCourseInfo(weekdayInt, whichSection: 8, cell: cell)
                let progress:Float = Float(timeInt-18.5)*4/3
                return progress
            case 77/4..<233/12:
                cell.statusLabel.text = "第九节课下课中"
                showCourseInfo(weekdayInt, whichSection: 9, cell: cell)
                let progress:Float = Float(timeInt-77/4)*6
                return progress
            case 233/12..<121/6:
                cell.statusLabel.text = "第十节课进行中"
                showCourseInfo(weekdayInt, whichSection: 9, cell: cell)
                let progress:Float = Float(timeInt-233/12)*4/3
                return progress
            case 121/6..<61/3:
                cell.statusLabel.text = "第十节课下课中"
                showCourseInfo(weekdayInt, whichSection: 10, cell: cell)
                let progress:Float = Float(timeInt-121/6)*6
                return progress
            case 61/3..<253/12:
                cell.statusLabel.text = "第十一节课进行中"
                showCourseInfo(weekdayInt, whichSection: 10, cell: cell)
                let progress:Float = Float(timeInt-61/3)*4/3
                return progress
            case 253/12..<85/4:
                cell.statusLabel.text = "第十一节课下课中"
                showCourseInfo(weekdayInt, whichSection: 11, cell: cell)
                let progress:Float = Float(timeInt-253/12)*6
                return progress
            case 85/4..<22:
                cell.statusLabel.text = "第十二节课进行中"
                showCourseInfo(weekdayInt, whichSection: 11, cell: cell)
                let progress:Float = Float(timeInt-85/4)*4/3
                return progress
            default:
                cell.statusLabel.text = "忙碌的一天结束啦"
                cell.currentCourseNameLabel.text = "Have a neat sleep!"
                cell.currentCourseClassroomLabel.text = "@ 寝室"
                cell.currentCourseTimeLabel.text = "睡到七点吧~"
                currentCourse = -1
                let progress:Float = Float(timeInt-22)/10
                return progress
            }
        }
        else {
            
            //没有course信息
            cell.statusLabel.text = "不知道诶！"
            cell.currentCourseNameLabel.text = "不知道诶!"
            cell.currentCourseClassroomLabel.text = "@ 不知道诶！"
            cell.currentCourseTimeLabel.text = "不知道诶！"
            let alert:UIAlertView = UIAlertView(title: "数据错误", message: "还未加载课程数据\n请先到课程表页面加载课程数据", delegate: nil, cancelButtonTitle: "好的，马上去！")
            currentCourse = -1
            alert.show()
            return nil
        }
    }
    
    func handleTodayCourses(weekday:Int) -> NSArray {
        
        let todayCourses:NSMutableArray = NSMutableArray()
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let courses:NSArray? = userDefaults.objectForKey("courses") as? NSArray
        if let _ = courses {
            var i:Int = 0
            
            var courseData = courses!.objectAtIndex(i) as! NSData
            var course = NSKeyedUnarchiver.unarchiveObjectWithData(courseData) as! Course
            var courseDay:Int = course.day
            while (courseDay != weekday) {
                i++
                if i>=courses!.count {
                    break;
                }
                courseData = courses!.objectAtIndex(i) as! NSData
                let course = NSKeyedUnarchiver.unarchiveObjectWithData(courseData) as! Course
                courseDay = course.day
            }
            while courseDay == weekday {
                todayCourses.addObject(i)
                i++
                if (i<=courses!.count-1) {
                    courseData = courses!.objectAtIndex(i) as! NSData
                    course = NSKeyedUnarchiver.unarchiveObjectWithData(courseData) as! Course
                    courseDay = course.day
                }
                else {
                    break
                }
            }
        }
        return todayCourses
    }
    
    func showCourseInfo(weekdayInt:Int, whichSection:Int, cell: courseCurrentTableViewCell) {
        
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let courseStatus:NSArray = userDefaults.objectForKey("courseStatus") as! NSArray
        let todayCourseStatus:NSArray = courseStatus.objectAtIndex(weekdayInt) as! NSArray
        let courses:NSArray = userDefaults.objectForKey("courses") as! NSArray
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
            cell.currentCourseClassroomLabel.text = "休息 Or"
            cell.currentCourseTimeLabel.text = "嗨皮去~"
            currentCourse = -1
        }
        else {
            let courseData = courses.objectAtIndex(status) as! NSData
            let course = NSKeyedUnarchiver.unarchiveObjectWithData(courseData) as! Course
            currentCourse = status
            cell.currentCourseNameLabel.text = course.name
            cell.currentCourseClassroomLabel.text = course.classroom
            cell.currentCourseClassroomLabel.text = "@ " + cell.currentCourseClassroomLabel.text!
            let startSection = course.startSection
            let sectionNumber = course.sectionNumber
            cell.currentCourseTimeLabel.text = "第\(startSection)节至第\(startSection + sectionNumber - 1)节"
            if !isPresentCourse {
                cell.statusLabel.text = "最近一节课是"
            }
        }
    }
    
    func refreshWeatherCondition(cell: TimeWeatherStatusTableViewCell) {
        
        let time = CalendarConverter.timeInt()
        
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let weather:NSDictionary? = userDefaults.objectForKey("weather") as? NSDictionary
        
        if let temp = weather {
            
            let firstDay:NSDictionary = temp.objectForKey("firstDay") as! NSDictionary
            let secondDay:NSDictionary = temp.objectForKey("secondDay") as! NSDictionary
            
            switch time {
            case 0...6:
                fallthrough
            case 18...24:
                let weatherCondition = firstDay.objectForKey("nightWeather") as! String
                let weatherImage = "night" + weatherCondition + ".png"
                cell.weatherImageView.image = UIImage(named: weatherImage)
                cell.temperatureLabel.text = "温度：" + (firstDay.objectForKey("nightTemperature") as! String) + "℃"
                cell.weatherConditionLabel.text = weatherEncodeToWeatherCondition[weatherCondition]
            case 6...8:
                let weatherCondition = secondDay.objectForKey("dayWeather") as! String
                let weatherImage = "day" + weatherCondition + ".png"
                cell.weatherImageView.image = UIImage(named: weatherImage)
                cell.temperatureLabel.text = "温度：" + (secondDay.objectForKey("dayTemperature") as! String) + "℃"
                cell.weatherConditionLabel.text = weatherEncodeToWeatherCondition[weatherCondition]
            case 8...18:
                let weatherCondition = firstDay.objectForKey("dayWeather") as! String
                let weatherImage = "day" + weatherCondition + ".png"
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
        
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let weather:NSDictionary? = userDefaults.objectForKey("weather") as? NSDictionary
        if let _ = weather {
            
            let aqi:Int? = weather?.objectForKey("aqi") as? Int
            let quality:String? = weather?.objectForKey("quality") as? String
            if let _ = quality {
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
        }
        else {
            self.tableView.backgroundView = nil
            self.tableView.backgroundColor = UIColor.whiteColor()
            self.storeHouseRefreshControl.finishingLoading()
            self.storeHouseRefreshControl = nil
            self.storeHouseRefreshControl = CBStoreHouseRefreshControl.attachToScrollView(self.tableView, target: self, refreshAction: "refreshTriggered", plist: "NKU", color: UIColor.blackColor(), lineWidth: 1.5, dropHeight: 75, scale: 1, horizontalRandomness: 150, reverseLoadingAnimation: false, internalAnimationFactor: 0.5)
        }
        
    }
    
    // MARK: seguesOutsideTheView
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        if identifier == "showCourseDetail" {
            
            if let _ = currentCourse {
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
            
            let vc = segue.destinationViewController as! CourseDetailTableViewController
            vc.whichCourse = currentCourse
            
        }
        
    }
    
    @IBAction func currentCourseTapGesture(sender: UITapGestureRecognizer) {
        
        if let _ = currentCourse {
            if currentCourse == -1 {
            }
            else {
                self.performSegueWithIdentifier("showCourseDetail", sender: nil)
            }
        }

        
    }
    
    func launchJump() {
        
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
            let weatherInfoGetter:WeatherInfoGetter = WeatherInfoGetter { () -> Void in
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
            let current = scrollView.contentOffset.x / UIScreen.mainScreen().bounds.size.width
            
            let page:UIPageControl = self.view.viewWithTag(Int(102)) as! UIPageControl
            page.currentPage = Int(current)
        }
    }
    
}
