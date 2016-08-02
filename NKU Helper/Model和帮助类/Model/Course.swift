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
    dynamic var teacherName = "未知"
    dynamic var color: Color?
    let courseTimes = List<CourseTime>()
    let tasks = LinkingObjects(fromType: Task.self, property: "forCourse")
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
    /**
     增加一个课时，如果这门课不存在则创建，如果存在则加入到其课时中
     
     - returns: 若创建了则返回Course实例，若在已存在的课程中增加了课时则返回nil
     */
    static func addCourseTime(key key:Int, ID:String, number:String, name:String, classroom:String, weekOddEven:String, teacherName:String, weekday:Int, startSection:Int, sectionNumber:Int, startWeek:Int, endWeek:Int) -> Course? {
        let realm = try! Realm()
        let existedCourses = realm.objects(Course.self).filter("ID == '\(ID)'")
        if let existedCourse = existedCourses.first {
            let courseTime = CourseTime(key: key, classroom: classroom, weekOddEven: weekOddEven, weekday: weekday, startSection: startSection, sectionNumber: sectionNumber, startWeek: startWeek, endWeek: endWeek)
            try! courseTime.save()
            try! realm.write({ 
                existedCourse.courseTimes.append(courseTime)
            })
            return nil
        } else {
            return Course(key: key, ID: ID, number: number, name: name, classroom: classroom, weekOddEven: weekOddEven, teacherName: teacherName, weekday: weekday, startSection: startSection, sectionNumber: sectionNumber, startWeek: startWeek, endWeek: endWeek)
        }
    }
    
    private convenience init(key:Int, ID:String, number:String, name:String, classroom:String, weekOddEven:String, teacherName:String, weekday:Int, startSection:Int, sectionNumber:Int, startWeek:Int, endWeek:Int) {
        self.init()
        self.key = key
        self.ID = ID
        self.number = number
        self.name = name
        self.teacherName = teacherName
        let courseTime = CourseTime(key: key, classroom: classroom, weekOddEven: weekOddEven, weekday: weekday, startSection: startSection, sectionNumber: sectionNumber, startWeek: startWeek, endWeek: endWeek)
        try! courseTime.save()
        self.courseTimes.append(courseTime)
    }
    
    /**
     返回一周中某一天的所有课时
     
     - parameter weekday: 星期几（周日为0，周一为1）
     
     - throws: NoClassesInStorage和RealmError
     
     - returns: 那一天的所有课时
     */
    class func coursesOnWeekday(weekday: Int) throws -> Results<CourseTime> {
        let convertedWeekday = weekday == 0 ? 7 : weekday
        do {
            let realm = try Realm()
            let courseTimes = realm.objects(CourseTime.self).sorted("key")
            guard courseTimes.count != 0 else {
                throw StoragedDataError.NoCoursesInStorage
            }
            return courseTimes.filter("weekday == \(convertedWeekday)").sorted("key")
        } catch StoragedDataError.NoCoursesInStorage {
            throw StoragedDataError.NoCoursesInStorage
        } catch {
            throw StoragedDataError.RealmError
        }
    }

    /**
     获取所有课程

     - throws: StoragedDataError.NoClassesInStorage和RealmError

     - returns: 课程组成的Array
     */
    class func getAllCourses() throws -> Results<Course> {
        guard CourseAgent.sharedInstance.isCourseLoaded else {
            throw StoragedDataError.NoCoursesInStorage
        }
        do {
            let realm = try Realm()
            let result = realm.objects(Course.self).sorted("key")
            return result
        } catch {
            throw StoragedDataError.RealmError
        }
    }

    /**
     存储课程信息

     - parameter data: 要存储的课程

     - throws: RealmError
     */
    class func saveCourses(courses: [Course]) throws {
        do {
            let realm = try Realm()
            try realm.write({
                for course in courses {
                    realm.add(course)
                }
            })
        } catch {
            throw StoragedDataError.RealmError
        }
    }

    /**
     删除课程信息

     - throws: RealmError
     */
    class func deleteAllCourses() throws {
        do {
            let realm = try Realm()
            let data = try getAllCourses()
            try realm.write({
                realm.delete(data)
            })
            CourseAgent.sharedInstance.signCourseToUnloaded()
        } catch StoragedDataError.NoCoursesInStorage {
            CourseAgent.sharedInstance.signCourseToUnloaded()
        } catch {
            throw StoragedDataError.RealmError
        }
    }

}
