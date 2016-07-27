//
//  Course.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/9/18.
//  Copyright © 2015年 陈乐天. All rights reserved.
//

import UIKit
import RealmSwift

/// 课程类
class Course: Object {
    
    dynamic var key = 0
    dynamic var ID = "未知" // 选课序号
    dynamic var number = "未知" // 课程编号
    dynamic var name = "未知"
    dynamic var classroom = "未知"
    dynamic var weekOddEven = "单 双 周"
    dynamic var teacherName = "未知"
    dynamic var weekday = 1
    dynamic var startSection = 1
    dynamic var sectionNumber = 2
    dynamic var startWeek = 1
    dynamic var endWeek = 16
    dynamic var color: Color?
    //TODO: 把thing与Course连起来
//    let thingToDos = List<ThingToDo>()
    
    var endSection:Int {
        return startSection + sectionNumber - 1
    }
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
    convenience init(key:Int, ID:String, number:String, name:String, classroom:String, weekOddEven:String, teacherName:String, weekday:Int, startSection:Int, sectionNumber:Int, startWeek:Int, endWeek:Int) {
        self.init()
        self.key = key
        self.ID = ID
        self.number = number
        self.name = name
        self.classroom = classroom
        self.weekOddEven = weekOddEven
        self.teacherName = teacherName
        self.weekday = weekday
        self.startSection = startSection
        self.sectionNumber = sectionNumber
    }
    
    /**
     返回一周中某一天的所有课程
     
     - parameter weekday: 星期几（周日为0，周一为1）
     
     - throws: NoClassesInStorage和RealmError
     
     - returns: 那一天的所有课程
     */
    class func coursesOnWeekday(weekday: Int) throws -> Results<Course> {
        let convertedWeekday = weekday == 0 ? 7 : weekday
        do {
            let realm = try Realm()
            let courses = realm.objects(Course.self)
            guard courses.count != 0 else {
                throw StoragedDataError.NoClassesInStorage
            }
            return courses.filter("weekday == \(convertedWeekday)").sorted("startSection")
        } catch StoragedDataError.NoClassesInStorage {
            throw StoragedDataError.NoClassesInStorage
        } catch {
            throw StoragedDataError.RealmError
        }
    }
    
}
