//
//  ClassTimeView.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/13/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

class ClassTimeView: UIView {

    @IBOutlet var shadowView: UIView!
    @IBOutlet var classScrollView: UIScrollView!
    @IBOutlet var headScrollView: UIScrollView!

    var UALoadView:UAProgressView!
    var overlayView:UIView!
    
    let rowHeight:CGFloat = 50
    let columnWidth:CGFloat = UIScreen.mainScreen().bounds.width / 6
    
    var week:Int!
    
    // MARK: 绘制课表
    
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
                time.text = "21:15"
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
    
    func drawClassTimeTableOnViewController(viewController: UIViewController) {
        
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
            tapGesture.addTarget(viewController, action: "showCourseDetail:")
            course.addGestureRecognizer(tapGesture)
            
            self.classScrollView.addSubview(course)
        }
        
    }

    func updateClassTimeTableWithWeek(week: Int) {
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
