//
//  ClassTimeView.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/13/16.
//  Copyright © 2016 陈乐天. All rights reserved.
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
    var UALoadView: UAProgressView!
    var overlayView: UIView!
    
    var orientation: UIInterfaceOrientation?
    var rowHeight: CGFloat {
        if (self.frame.height >= 700) {
            return CGFloat(self.frame.height) / 14
        }
        else {
            return 50
        }
    }
    let topHeight: CGFloat = 30
    var columnWidth: CGFloat {
        if (orientation == UIInterfaceOrientation.LandscapeLeft) || (orientation == UIInterfaceOrientation.LandscapeRight) || (self.frame.width >= 700) {
            return (self.frame.width - timeViewWidth) / 7
        }
        else {
            return (self.frame.width - timeViewWidth) / 5
        }
    }
    let timeViewWidth:CGFloat = 40
    let classViewInset:CGFloat = 5
    
    var week:Int!
    
// MARK: 绘制课表
    
    func drawBackground() {
        
        // 绘制headScrollView中的星期几信息
        for view in headScrollView.subviews {
            view.removeFromSuperview()
        }
        headScrollView.contentSize = CGSizeMake(columnWidth * 7, topHeight)
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
            weekdayViews.append(weekdayView)
        }
        
        // 绘制timeScrollView中的每堂课时间信息
        for view in timeScrollView.subviews {
            view.removeFromSuperview()
        }
        timeScrollView.contentSize = CGSizeMake(timeViewWidth, rowHeight*14)
        timeScheduleViews = [TimeScheduleView]()
        for i in 0...13 {
            let timeScheduleView = TimeScheduleView.loadFromNib()
            timeScrollView.addSubview(timeScheduleView)
            timeScheduleView.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(timeScrollView.snp_left)
                make.width.equalTo(timeViewWidth)
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
            let bottomBorderLayer = CALayer()
            bottomBorderLayer.frame = CGRectMake(0, rowHeight, timeViewWidth, 0.5)
            bottomBorderLayer.backgroundColor = UIColor(red: 216/255, green: 224/255, blue: 226/255, alpha: 1).CGColor;
            timeScheduleView.layer.addSublayer(bottomBorderLayer)
            let topBorderLayer = CALayer()
            topBorderLayer.frame = CGRectMake(0, 0, timeViewWidth, 0.5)
            topBorderLayer.backgroundColor = UIColor(red: 216/255, green: 224/255, blue: 226/255, alpha: 1).CGColor;
            timeScheduleView.layer.addSublayer(topBorderLayer)
            timeScheduleViews.append(timeScheduleView)
        }
        
        // 绘制课程表的背景
        for view in classScrollView.subviews {
            view.removeFromSuperview()
        }
        classScrollView.contentSize = CGSizeMake(columnWidth * 7, rowHeight*14)
        for i in 0...13 {
            let rowBackgroundView = UIView(frame: CGRectMake(0, CGFloat(i) * rowHeight, columnWidth * 7, rowHeight))
            rowBackgroundView.backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1)
            rowBackgroundView.layer.borderWidth = 0.5
            rowBackgroundView.layer.borderColor = UIColor(red: 216/255, green: 224/255, blue: 226/255, alpha: 1).CGColor
            classScrollView.addSubview(rowBackgroundView)
        }
        
        // 阴影效果
        headShadowView.layer.shadowColor = UIColor.grayColor().CGColor
        headShadowView.layer.shadowOffset = CGSizeMake(0, 2)
        headShadowView.layer.shadowOpacity = 0.3
        timeShadowView.layer.shadowColor = UIColor.grayColor().CGColor
        timeShadowView.layer.shadowOffset = CGSizeMake(2, 0)
        timeShadowView.layer.shadowOpacity = 0.3
        
        // 空白View的边框效果
        if let layers = blankView.layer.sublayers {
            for layer in layers {
                layer.removeFromSuperlayer()
            }
        }
        let rightBorderLayer = CALayer()
        rightBorderLayer.frame = CGRectMake(timeViewWidth, 0, 1, topHeight)
        rightBorderLayer.backgroundColor = UIColor(red: 216/255, green: 224/255, blue: 226/255, alpha: 1).CGColor
        blankView.layer.addSublayer(rightBorderLayer)
        let bottomBorderLayer = CALayer()
        bottomBorderLayer.frame = CGRectMake(0, topHeight, timeViewWidth, 1)
        bottomBorderLayer.backgroundColor = UIColor(red: 216/255, green: 224/255, blue: 226/255, alpha: 1).CGColor;
        blankView.layer.addSublayer(bottomBorderLayer)
    }
    
    func drawClassTimeTableOnViewController(viewController: UIViewController) {
        
        // 删去原先有的
        for view in classScrollView.subviews {
            if view is ClassView {
                view.removeFromSuperview()
            }
        }
        
        do {
            // 绘制课表
            let courses = try Course.getAllCourses()
            for i in 0 ..< courses.count {
                // 对于每一个课时
                let current = courses[i]
                for courseTime in current.courseTimes {
                    let weekday = courseTime.weekday
                    let startSection = courseTime.startSection
                    let sectionNumber = courseTime.sectionNumber
                    let weekOddEven = courseTime.weekOddEven
                    
                    // 创建一堂课的View
                    let courseView = ClassView.loadFromNib()
                    if let _ = week {
                        if ((weekOddEven == "单周") && (week % 2 == 0) || (weekOddEven == "双周" && (week % 2 == 1))) {
                            courseView.alpha = 0.15
                        }
                    }
                    courseView.courseTime = courseTime
                    self.classScrollView.addSubview(courseView)
                    courseView.snp_makeConstraints(closure: { (make) in
                        make.left.equalTo(classScrollView.snp_left).offset(CGFloat(weekday - 1) * columnWidth + classViewInset)
                        make.top.equalTo(classScrollView.snp_top).offset(CGFloat(startSection - 1) * rowHeight + classViewInset)
                        make.width.equalTo(columnWidth - classViewInset * 2)
                        make.height.equalTo(rowHeight * CGFloat(sectionNumber) - classViewInset * 2)
                    })
                    courseView.layer.cornerRadius = 5
                    courseView.layer.masksToBounds = true
                    courseView.tag = courseTime.key
                    let tapGesture = UITapGestureRecognizer()
                    tapGesture.addTarget(viewController, action: #selector(ClassTimeViewController.showCourseDetail(_:)))
                    courseView.addGestureRecognizer(tapGesture)
                }
            }
        } catch {
            
        }
        
    }

    func updateClassTimeTableWithWeek(week: Int) {
        do {
            let courses = try Course.getAllCourses()
            courses.forEach({ (current) in
                current.courseTimes.forEach({ (courseTime) in
                    let weekOddEven = courseTime.weekOddEven
                    let startWeek = courseTime.startWeek
                    let endWeek = courseTime.endWeek
                    let courseView = self.classScrollView.viewWithTag(courseTime.key)!
                    if ((weekOddEven == "单周") && (week % 2 == 0) || (weekOddEven == "双周" && (week % 2 == 1))) || (week < startWeek) || (week > endWeek) {
                        courseView.alpha = 0.15
                    }
                })
            })
        } catch {
            
        }
    }
    
// MARK: 课程表加载动画
    
    func loadBeginAnimation() {
        
        overlayView = UIView(frame: CGRectMake(self.frame.width / 2, self.classScrollView.frame.height / 2 - 50, 0, 0))
        overlayView.backgroundColor = UIColor.blackColor()
        overlayView.alpha = 0.7
        self.addSubview(overlayView)
        
        let overlayViewIn = POPBasicAnimation(propertyNamed: kPOPViewFrame)
        overlayViewIn.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        overlayViewIn.toValue = NSValue(CGRect: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
        overlayViewIn.duration = 0.5
        overlayView.pop_addAnimation(overlayViewIn, forKey: "overlayViewIn")
        
        UALoadView = UAProgressView(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 2 - 100, UIScreen.mainScreen().bounds.height / 2 - 150, 200, 200))
        UALoadView.tintColor = UIColor(red: 34/255, green: 205/255, blue: 198/255, alpha: 1)
        UALoadView.lineWidth = 5
        UALoadView.alpha = 0
        let textLabel = UILabel(frame: CGRectMake(20, 0, 160.0, 132.0))
        textLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 40)
        textLabel.textAlignment = NSTextAlignment.Center;
        textLabel.textColor = self.UALoadView.tintColor;
        textLabel.backgroundColor = UIColor.clearColor();
        textLabel.text = "0%"
        self.UALoadView.centralView = textLabel
        self.addSubview(UALoadView)
        
        let UALoadViewFadeIn = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        UALoadViewFadeIn.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        UALoadViewFadeIn.toValue = 1
        UALoadViewFadeIn.duration = 0.5
        UALoadView.pop_addAnimation(UALoadViewFadeIn, forKey: "UALoadViewFadeIn")
    }
    
    func loadAnimation(progress:Float) {
        UALoadView.setProgress(CGFloat(progress), animated: true)
        let label = UALoadView.centralView as! UILabel
        label.text = NSString(format: "%2.0f%%", progress*100) as String
    }
    
    func loadEndAnimation() {
        
        let overlayViewFadeOut = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        overlayViewFadeOut.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        overlayViewFadeOut.duration = 1
        overlayViewFadeOut.toValue = 0
        overlayViewFadeOut.beginTime = CACurrentMediaTime() + 0.8
        overlayView.pop_addAnimation(overlayViewFadeOut, forKey: "overlayViewFadeOut")
        
        let UALoadViewFadeOut = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
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
