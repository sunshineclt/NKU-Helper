//
//  Course.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/9/18.
//  Copyright © 2015年 陈乐天. All rights reserved.
//

import UIKit

/// 课程类
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
    var startWeek:Int?
    var endWeek:Int?
    
    var endSection:Int {
        return startSection + sectionNumber - 1
    }
    
    init(ID:String, number:String, name:String, classroom:String, weekOddEven:String, teacherName:String, day:Int, startSection:Int, sectionNumber:Int, startWeek:Int? = nil, endWeek:Int? = nil) {
        
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
    
    /**
     返回一周中某一天的所有课程
     
     - parameter weekday: 星期几（周日为0，周一为1）
     
     - returns: 那一天的所有课程
     */
    class func coursesOnWeekday(weekday:Int) -> [Course]? {
        
        var todayCourses = [Course]()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let courses = userDefaults.objectForKey("courses") as? NSArray
        guard (courses != nil) else {
            return nil
        }
        guard (courses!.count != 0) else {
            return todayCourses
        }
        var i = 0
        var courseData = courses!.objectAtIndex(i) as! NSData
        var course = NSKeyedUnarchiver.unarchiveObjectWithData(courseData) as! Course
        var courseDay = course.day
        while (courseDay != weekday) {
            i += 1
            if i>=courses!.count {
                break;
            }
            courseData = courses!.objectAtIndex(i) as! NSData
            course = NSKeyedUnarchiver.unarchiveObjectWithData(courseData) as! Course
            courseDay = course.day
        }
        while courseDay == weekday {
            todayCourses.append(course)
            i += 1
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
    
}
