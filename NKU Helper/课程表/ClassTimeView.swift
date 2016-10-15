//
//  ClassTimeView.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/13/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import UIKit
import SnapKit
import Then

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
        if (orientation == UIInterfaceOrientation.landscapeLeft) || (orientation == UIInterfaceOrientation.landscapeRight) || (self.frame.width >= 700) {
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
        headScrollView.contentSize = CGSize(width: columnWidth * 7, height: topHeight)
        weekdayViews = [WeekdayView]()
        for i in 1...7 {
            let weekdayView = WeekdayView.loadFromNib()
            headScrollView.addSubview(weekdayView)
            weekdayView.snp.makeConstraints({ (make) in
                make.width.equalTo(columnWidth)
                make.top.equalTo(headScrollView.snp.top)
                make.height.equalTo(topHeight)
                if (i != 1) {
                    make.left.equalTo(weekdayViews.last!.snp.right)
                }
                else {
                    make.left.equalTo(headScrollView.snp.left)
                }
            })
            weekdayView.weekdayLabel.text = CalendarHelper.getWeekdayString(fromWeekday: i)
            weekdayViews.append(weekdayView)
        }
        
        // 绘制timeScrollView中的每堂课时间信息
        for view in timeScrollView.subviews {
            view.removeFromSuperview()
        }
        timeScrollView.contentSize = CGSize(width: timeViewWidth, height: rowHeight * 14)
        timeScheduleViews = [TimeScheduleView]()
        for i in 0...13 {
            let timeScheduleView = TimeScheduleView.loadFromNib()
            timeScrollView.addSubview(timeScheduleView)
            timeScheduleView.snp.makeConstraints({ (make) in
                make.left.equalTo(timeScrollView.snp.left)
                make.width.equalTo(timeViewWidth)
                make.height.equalTo(rowHeight)
                if (i != 0) {
                    make.top.equalTo(timeScheduleViews.last!.snp.bottom)
                }
                else {
                    make.top.equalTo(timeScrollView.snp.top)
                }
            })
            timeScheduleView.timeLabel.text = CalendarHelper.getTimeInfo(forSection: i)
            timeScheduleView.sectionLabel.text = "\(i + 1)"
            let bottomBorderLayer = CALayer().then {
                $0.frame = CGRect(x: 0, y: rowHeight, width: timeViewWidth, height: 0.5)
                $0.backgroundColor = UIColor(red: 216/255, green: 224/255, blue: 226/255, alpha: 1).cgColor;
            }
            timeScheduleView.layer.addSublayer(bottomBorderLayer)
            let topBorderLayer = CALayer().then {
                $0.frame = CGRect(x: 0, y: 0, width: timeViewWidth, height: 0.5)
                $0.backgroundColor = UIColor(red: 216/255, green: 224/255, blue: 226/255, alpha: 1).cgColor;
            }
            timeScheduleView.layer.addSublayer(topBorderLayer)
            timeScheduleViews.append(timeScheduleView)
        }
        
        // 绘制课程表的背景
        for view in classScrollView.subviews {
            view.removeFromSuperview()
        }
        classScrollView.contentSize = CGSize(width: columnWidth * 7, height: rowHeight*14)
        for i in 0...13 {
            let rowBackgroundView = UIView(frame: CGRect(x: 0, y: CGFloat(i) * rowHeight, width: columnWidth * 7, height: rowHeight)).then {
                $0.backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1)
                $0.layer.borderWidth = 0.5
                $0.layer.borderColor = UIColor(red: 216/255, green: 224/255, blue: 226/255, alpha: 1).cgColor
            }
            classScrollView.addSubview(rowBackgroundView)
        }
        
        // 阴影效果
        headShadowView.layer.shadowColor = UIColor.gray.cgColor
        headShadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        headShadowView.layer.shadowOpacity = 0.3
        timeShadowView.layer.shadowColor = UIColor.gray.cgColor
        timeShadowView.layer.shadowOffset = CGSize(width: 2, height: 0)
        timeShadowView.layer.shadowOpacity = 0.3
        
        // 空白View的边框效果
        if let layers = blankView.layer.sublayers {
            for layer in layers {
                layer.removeFromSuperlayer()
            }
        }
        let rightBorderLayer = CALayer().then {
            $0.frame = CGRect(x: timeViewWidth, y: 0, width: 1, height: topHeight)
            $0.backgroundColor = UIColor(red: 216/255, green: 224/255, blue: 226/255, alpha: 1).cgColor
        }
        blankView.layer.addSublayer(rightBorderLayer)
        let bottomBorderLayer = CALayer().then {
            $0.frame = CGRect(x: 0, y: topHeight, width: timeViewWidth, height: 1)
            $0.backgroundColor = UIColor(red: 216/255, green: 224/255, blue: 226/255, alpha: 1).cgColor;
        }
        blankView.layer.addSublayer(bottomBorderLayer)
    }
    
    func drawClassTimeTableOnViewController(_ viewController: UIViewController) {
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
                    courseView.snp.makeConstraints({ (make) in
                        make.left.equalTo(classScrollView.snp.left).offset(CGFloat(weekday - 1) * columnWidth + classViewInset)
                        make.top.equalTo(classScrollView.snp.top).offset(CGFloat(startSection - 1) * rowHeight + classViewInset)
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

    func updateClassTimeTableWithWeek(_ week: Int) {
        do {
            let courses = try Course.getAllCourses()
            courses.forEach({ (current) in
                current.courseTimes.forEach({ (courseTime) in
                    let weekOddEven = courseTime.weekOddEven
                    let startWeek = courseTime.startWeek
                    let endWeek = courseTime.endWeek
                    let courseView = self.classScrollView.viewWithTag(courseTime.key)!
                    if ((weekOddEven == "单周" && week % 2 == 0) || (weekOddEven == "双周" && (week % 2 == 1))) || (week < startWeek) || (week > endWeek) {
                        courseView.alpha = 0.15
                        courseView.isUserInteractionEnabled = false
                    }
                })
            })
        } catch {
        }
    }
    
// MARK: 课程表加载动画
    
    func loadBeginAnimation() {
        
        overlayView = UIView(frame: CGRect(x: self.frame.width / 2, y: self.classScrollView.frame.height / 2 - 50, width: 0, height: 0))
        overlayView.backgroundColor = UIColor.black
        overlayView.alpha = 0.7
        self.addSubview(overlayView)
        
        let overlayViewIn = POPBasicAnimation(propertyNamed: kPOPViewFrame)
        overlayViewIn?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        overlayViewIn?.toValue = NSValue(cgRect: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        overlayViewIn?.duration = 0.5
        overlayView.pop_add(overlayViewIn, forKey: "overlayViewIn")
        
        UALoadView = UAProgressView(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 100, y: UIScreen.main.bounds.height / 2 - 150, width: 200, height: 200))
        UALoadView.tintColor = UIColor(red: 34/255, green: 205/255, blue: 198/255, alpha: 1)
        UALoadView.lineWidth = 5
        UALoadView.alpha = 0
        let textLabel = UILabel(frame: CGRect(x: 20, y: 0, width: 160.0, height: 132.0))
        textLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 40)
        textLabel.textAlignment = NSTextAlignment.center;
        textLabel.textColor = self.UALoadView.tintColor;
        textLabel.backgroundColor = UIColor.clear;
        textLabel.text = "0%"
        self.UALoadView.centralView = textLabel
        self.addSubview(UALoadView)
        
        let UALoadViewFadeIn = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        UALoadViewFadeIn?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        UALoadViewFadeIn?.toValue = 1
        UALoadViewFadeIn?.duration = 0.5
        UALoadView.pop_add(UALoadViewFadeIn, forKey: "UALoadViewFadeIn")
    }
    
    func loadAnimation(_ progress:Float) {
        UALoadView.setProgress(CGFloat(progress), animated: true)
        let label = UALoadView.centralView as! UILabel
        label.text = NSString(format: "%2.0f%%", progress*100) as String
    }
    
    func loadEndAnimation() {
        
        let overlayViewFadeOut = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        overlayViewFadeOut?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        overlayViewFadeOut?.duration = 1
        overlayViewFadeOut?.toValue = 0
        overlayViewFadeOut?.beginTime = CACurrentMediaTime() + 0.8
        overlayView.pop_add(overlayViewFadeOut, forKey: "overlayViewFadeOut")
        
        let UALoadViewFadeOut = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        UALoadViewFadeOut?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        UALoadViewFadeOut?.duration = 1
        UALoadViewFadeOut?.toValue = 0
        UALoadViewFadeOut?.beginTime = CACurrentMediaTime() + 0.8
        
        let UALoadViewUp:POPBasicAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationY)
        UALoadViewUp.duration = 1
        UALoadViewUp.toValue = -100
        UALoadViewUp.beginTime = CACurrentMediaTime() + 0.8
        
        UALoadView.layer.pop_add(UALoadViewUp, forKey: "UALoadViewUp")
        UALoadView.pop_add(UALoadViewFadeOut, forKey: "UALoadViewFadeOut")
    }
    
}
