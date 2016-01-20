//
//  Course.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/9/18.
//  Copyright © 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

class Course: NSObject, NSCoding {
    
    var ID:String
    var number:String
    var name:String
    var classroom:String
    var weekOddEven:String
    var teacherName:String
    var day:Int
    var startSection:Int
    var sectionNumber:Int
    
    var endSection:Int {
        return startSection + sectionNumber - 1
    }
    
    init(ID:String, number:String, name:String, classroom:String, weekOddEven:String, teacherName:String, day:Int, startSection:Int, sectionNumber:Int) {
        
        self.ID = ID
        self.number = number
        self.name = name
        self.classroom = classroom
        self.weekOddEven = weekOddEven
        self.teacherName = teacherName
        self.day = day
        self.startSection = startSection
        self.sectionNumber = sectionNumber
        super.init()

    }
    
    required init?(coder aDecoder: NSCoder) {
        self.ID = aDecoder.decodeObjectForKey("ID") as! String
        self.number = aDecoder.decodeObjectForKey("number") as! String
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.classroom = aDecoder.decodeObjectForKey("classroom") as! String
        self.weekOddEven = aDecoder.decodeObjectForKey("weekOddEven") as! String
        self.teacherName = aDecoder.decodeObjectForKey("teacherName") as! String
        self.day = aDecoder.decodeObjectForKey("day") as! Int
        self.startSection = aDecoder.decodeObjectForKey("startSection") as! Int
        self.sectionNumber = aDecoder.decodeObjectForKey("sectionNumber") as! Int
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(ID, forKey: "ID")
        aCoder.encodeObject(number, forKey: "number")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(classroom, forKey: "classroom")
        aCoder.encodeObject(weekOddEven, forKey: "weekOddEven")
        aCoder.encodeObject(teacherName, forKey: "teacherName")
        aCoder.encodeObject(day, forKey: "day")
        aCoder.encodeObject(startSection, forKey: "startSection")
        aCoder.encodeObject(sectionNumber, forKey: "sectionNumber")
    }
    
    class func coursesOnWeekday(weekday:Int) -> [Course]? {
        
        var todayCourses = [Course]()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let courses:NSArray? = userDefaults.objectForKey("courses") as? NSArray
        guard (courses != nil) else {
            return nil
        }
        guard (courses!.count != 0) else {
            return todayCourses
        }
        var i:Int = 0
        var courseData = courses!.objectAtIndex(i) as! NSData
        var course = NSKeyedUnarchiver.unarchiveObjectWithData(courseData) as! Course
        var courseDay = course.day
        while (courseDay != weekday) {
            i++
            if i>=courses!.count {
                break;
            }
            courseData = courses!.objectAtIndex(i) as! NSData
            course = NSKeyedUnarchiver.unarchiveObjectWithData(courseData) as! Course
            courseDay = course.day
        }
        while courseDay == weekday {
            todayCourses.append(course)
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
        return todayCourses
    }
    /*
    func isCurrnetClass() {
    
        let (weekdayInt, timeInt) = CalendarConverter.weekdayTimeInt()
        
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
*/
}
