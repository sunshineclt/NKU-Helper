//
//  ClassTimeView.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/13/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit
import SnapKit

class ClassTimeView: UIView {

    @IBOutlet var blankView: UIView!
    @IBOutlet var headShadowView: UIView!
    @IBOutlet var timeShadowView: UIView!
    @IBOutlet var classScrollView: UIScrollView!
    @IBOutlet var headScrollView: UIScrollView!
    @IBOutlet var timeScrollView: UIScrollView!
    @IBOutlet var timeScrollViewWidthConstraint: NSLayoutConstraint!
    var weekdayViews = [WeekdayView]()
    var timeScheduleViews = [TimeScheduleView]()
    var UALoadView:UAProgressView!
    var overlayView:UIView!
    
    var orientation: UIInterfaceOrientation?
    let rowHeight: CGFloat = 50
    let topHeight: CGFloat = 30
    var columnWidth: CGFloat {
        if (orientation == UIInterfaceOrientation.LandscapeLeft) || (orientation == UIInterfaceOrientation.LandscapeRight) {
            return self.frame.width / 8
        }
        else {
            return self.frame.width / 6
        }
    }
    
    var week:Int!
    
// MARK: 绘制课表
    
    func drawBackground() {
        
        // 调整timeScrollView的宽度
        timeScrollViewWidthConstraint.constant = columnWidth
        
        // 绘制headScrollView中的星期几信息
        for view in headScrollView.subviews {
            view.removeFromSuperview()
        }
        headScrollView.contentSize = CGSizeMake(columnWidth * 8, topHeight)
        weekdayViews = [WeekdayView]()
        for i in 1...7 {
            let weekdayView = WeekdayView.loadFromNib()
            headScrollView.addSubview(weekdayView)
            weekdayView.snp_makeConstraints(closure: { (make) in
                make.width.equalTo(columnWidth)
                make.top.equalTo(headScrollView.snp_top)
                make.height.equalTo(topHeight)
                if (i != 1) {
                    make.left.equalTo(weekdayViews.last!.snp_right)
                }
                else {
                    make.left.equalTo(headScrollView.snp_left)
                }
            })
            weekdayView.weekdayLabel.text = CalendarHelper.getWeekdayStringFromWeekdayInt(i)
            let rightBorderLayer = CALayer()
            rightBorderLayer.frame = CGRectMake(columnWidth-1, 0, 1, topHeight)
            rightBorderLayer.backgroundColor = UIColor(red: 216/255, green: 224/255, blue: 226/255, alpha: 1).CGColor
            weekdayView.layer.addSublayer(rightBorderLayer)
            weekdayViews.append(weekdayView)
        }
        
        // 设置classScrollView的大小
        classScrollView.contentSize = CGSizeMake(columnWidth * 7, rowHeight*14)
        
        // 绘制timeScrollView中的每堂课时间信息
        for view in timeScrollView.subviews {
            view.removeFromSuperview()
        }
        timeScrollView.contentSize = CGSizeMake(columnWidth, rowHeight*14)
        timeScheduleViews = [TimeScheduleView]()
        for i in 0...13 {
            let timeScheduleView = TimeScheduleView.loadFromNib()
            timeScrollView.addSubview(timeScheduleView)
            timeScheduleView.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(timeScrollView.snp_left)
                make.width.equalTo(columnWidth)
                make.height.equalTo(rowHeight)
                if (i != 0) {
                    make.top.equalTo(timeScheduleViews.last!.snp_bottom)
                }
                else {
                    make.top.equalTo(timeScrollView.snp_top)
                }
            })
            timeScheduleView.timeLabel.text = CalendarHelper.getTimeInfoFromSectionInt(i)
            timeScheduleView.sectionLabel.text = "\(i + 1)"
            timeScheduleView.tag = -1
            let bottomBorderLayer = CALayer()
            bottomBorderLayer.frame = CGRectMake(0, rowHeight-1, columnWidth, 1)
            bottomBorderLayer.backgroundColor = UIColor(red: 216/255, green: 224/255, blue: 226/255, alpha: 1).CGColor;
            timeScheduleView.layer.addSublayer(bottomBorderLayer)
            timeScheduleViews.append(timeScheduleView)
        }
        
        // 阴影效果
        headShadowView.layer.shadowColor = UIColor.grayColor().CGColor
        headShadowView.layer.shadowOffset = CGSizeMake(0, 2)
        headShadowView.layer.shadowOpacity = 0.3
        timeShadowView.layer.shadowColor = UIColor.grayColor().CGColor
        timeShadowView.layer.shadowOffset = CGSizeMake(2, 0)
        timeShadowView.layer.shadowOpacity = 0.3
        
        // 空白View的边框效果
        let rightBorderLayer = CALayer()
        rightBorderLayer.frame = CGRectMake(columnWidth, 0, 1, topHeight)
        rightBorderLayer.backgroundColor = UIColor(red: 216/255, green: 224/255, blue: 226/255, alpha: 1).CGColor
        blankView.layer.addSublayer(rightBorderLayer)
        let bottomBorderLayer = CALayer()
        bottomBorderLayer.frame = CGRectMake(0, topHeight, columnWidth, 1)
        bottomBorderLayer.backgroundColor = UIColor(red: 216/255, green: 224/255, blue: 226/255, alpha: 1).CGColor;
        blankView.layer.addSublayer(bottomBorderLayer)
    }
    
    func drawClassTimeTableOnViewController(viewController: UIViewController) {
        
        for view in classScrollView.subviews {
            if (view.tag != -1) {               // -1代表是背景中的第几节课及时间等
                view.removeFromSuperview()
            }
        }
        drawBackground()
        
        var usedColor:[Int] = []
        for _ in 0 ..< Colors.colors.count {
            usedColor.append(1)
        }
        
        var coloredCourse = Dictionary<String, Int>()
        
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let courses:NSArray = userDefaults.objectForKey("courses") as! NSArray
        for i in 0 ..< courses.count {
            let currentData = courses.objectAtIndex(i) as! NSData
            let current = NSKeyedUnarchiver.unarchiveObjectWithData(currentData) as! Course
            let day = current.day
            let startSection = current.startSection
            let sectionNumber = current.sectionNumber
            let name = current.name
            let classroom = current.classroom
            let classID = current.ID
            let weekOddEven = current.weekOddEven
            
            let course:UIView = UIView(frame: CGRectMake(CGFloat(day) * columnWidth, CGFloat(startSection - 1) * rowHeight, columnWidth, rowHeight * CGFloat(sectionNumber)))
            
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
                    count += 1
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
            tapGesture.addTarget(viewController, action: #selector(ClassTimeViewController.showCourseDetail(_:)))
            course.addGestureRecognizer(tapGesture)
            
            self.classScrollView.addSubview(course)
        }
        
    }

    func updateClassTimeTableWithWeek(week: Int) {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let courses:NSArray = userDefaults.objectForKey("courses") as! NSArray
        for i in 0 ..< courses.count {
            let currentData = courses.objectAtIndex(i) as! NSData
            let current = NSKeyedUnarchiver.unarchiveObjectWithData(currentData) as! Course
            let weekOddEven = current.weekOddEven
            
            let course = self.classScrollView.viewWithTag(i)!
            
            if ((weekOddEven == "单 周") && (week % 2 == 0) || (weekOddEven == "双 周" && (week % 2 == 1))) {
                course.alpha = 0.5
            }
        }
    }
    
// MARK: 课程表加载动画
    
    func loadBeginAnimation() {
        
        overlayView = UIView(frame: CGRectMake(self.frame.width / 2, self.classScrollView.frame.height / 2 - 50, 0, 0))
        overlayView.backgroundColor = UIColor.blackColor()
        overlayView.alpha = 0.7
        self.addSubview(overlayView)
        
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
        self.addSubview(UALoadView)
        
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
        
        UALoadView.layer.pop_addAnimation(UALoadViewUp, forKey: "UALoadViewUp")
        UALoadView.pop_addAnimation(UALoadViewFadeOut, forKey: "UALoadViewFadeOut")
    }
    
}
