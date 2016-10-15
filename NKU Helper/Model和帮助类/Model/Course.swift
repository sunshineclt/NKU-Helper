//
//  Course.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/9/18.
//  Copyright © 2015年 陈乐天. All rights reserved.
//

import UIKit
import RealmSwift

/**
 课程类
 * * * * *
 
 last modified:
 - date: 2016.10.12
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
class Course: Object {

// MARK:- Property
    
    /// 主键
    dynamic var key = 0
    /// 选课序号
    dynamic var ID = "未知"
    /// 课程编号
    dynamic var number = "未知"
    /// 课程名称
    dynamic var name = "未知"
    /// 教师姓名
    dynamic var teacherName = "未知"
    /// 颜色
    dynamic var color: Color?
    /// 课时
    let courseTimes = LinkingObjects(fromType: CourseTime.self, property: "forCourse")
    /// 任务
    let tasks = LinkingObjects(fromType: Task.self, property: "forCourse")
    
    /// 设置主键
    ///
    /// - returns: 主键
    override static func primaryKey() -> String? {
        return "key"
    }
    
// MARK:- 实例方法
    
    /// 创建一个课程对象
    ///
    /// - parameter key:         主键
    /// - parameter ID:          选课序号
    /// - parameter number:      课程编号
    /// - parameter name:        课程名称
    /// - parameter teacherName: 教师姓名
    ///
    /// - returns: 创建的课程对象
    convenience init(key:Int, ID:String, number:String, name:String, teacherName:String) {
        self.init()
        self.key = key
        self.ID = ID
        self.number = number
        self.name = name
        self.teacherName = teacherName
    }
    
    /// 存储课程信息
    ///
    /// - throws: StoragedDataError.realmError
    func save() throws {
        do {
            let realm = try Realm()
            try realm.write({
                realm.add(self)
            })
        } catch {
            throw StoragedDataError.realmError
        }
    }
    
// MARK:- 类方法
    
    /// 增加一个课时
    /// - important: 若这门课不存在则创建，若存在则加入到其课时中
    /// - important: 课程和课时均已保存
    ///
    /// - parameter key:           主键
    /// - parameter ID:            选课序号
    /// - parameter number:        课程编号
    /// - parameter name:          课程名称
    /// - parameter classroom:     教室
    /// - parameter weekOddEven:   单双周
    /// - parameter teacherName:   教师姓名
    /// - parameter weekday:       周几
    /// - parameter startSection:  开始的节数
    /// - parameter sectionNumber: 持续的节数
    /// - parameter startWeek:     开始的周数
    /// - parameter endWeek:       结束的周数
    ///
    /// - throws: StoragedDataError.realmError
    ///
    /// - returns: 若这门课不存在则返回创建的Course实例，若存在则加入课时后返回nil
    class func saveCourseTimeWith(key:Int, ID:String, number:String, name:String, classroom:String, weekOddEven:String, teacherName:String, weekday:Int, startSection:Int, sectionNumber:Int, startWeek:Int, endWeek:Int) throws {
        do {
            let realm = try Realm()
            let existedCourses = realm.objects(Course.self).filter("ID == '\(ID)'")
            if let existedCourse = existedCourses.first {
                // 这门课存在，直接将课时加入
                let courseTime = CourseTime(key: key, classroom: classroom, weekOddEven: weekOddEven, weekday: weekday, startSection: startSection, sectionNumber: sectionNumber, startWeek: startWeek, endWeek: endWeek, forCourse: existedCourse)
                try courseTime.save()
            } else {
                // 这门课不存在，新建一门课
                let course = Course(key: key, ID: ID, number: number, name: name, teacherName: teacherName)
                try course.save()
                let courseTime = CourseTime(key: key, classroom: classroom, weekOddEven: weekOddEven, weekday: weekday, startSection: startSection, sectionNumber: sectionNumber, startWeek: startWeek, endWeek: endWeek, forCourse: course)
                try courseTime.save()
            }
        }
        catch {
            throw StoragedDataError.realmError
        }
    }
    
    /// 获取一周中某一天的所有课时
    /// - note: 按照加载顺序排列
    ///
    /// - parameter weekday: 星期几（周日为0，周一为1）
    ///
    /// - throws: StoragedDataError.realmError、StoragedDataError.noClassesInStorage
    ///
    /// - returns: 那一天的所有课时
    class func getCourseTimes(onWeekday weekday: Int) throws -> Results<CourseTime> {
        guard CourseLoadedAgent.sharedInstance.isCourseLoaded else {
            throw StoragedDataError.noCoursesInStorage
        }
        do {
            let convertedWeekday = weekday == 0 ? 7 : weekday
            let realm = try Realm()
            return realm.objects(CourseTime.self).filter("weekday == \(convertedWeekday)").sorted(byProperty: "key")
        } catch {
            throw StoragedDataError.realmError
        }
    }

    /// 获取所有课程
    /// - note: 按照加载顺序排列
    ///
    /// - throws: StoragedDataError.noClassesInStorage、StoragedDataError.realmError
    ///
    /// - returns: 所有课程
    class func getAllCourses() throws -> Results<Course> {
        guard CourseLoadedAgent.sharedInstance.isCourseLoaded else {
            throw StoragedDataError.noCoursesInStorage
        }
        do {
            let realm = try Realm()
            return realm.objects(Course.self).sorted(byProperty: "key")
        } catch {
            throw StoragedDataError.realmError
        }
    }

    /// 删除所有课程信息
    /// - important: 必须先删除课时信息，与课程相关的任务信息，再删除课程信息
    ///
    /// - throws: StoragedDataError.realmError
    class func deleteAllCourses() throws {
        do {
            let realm = try Realm()
            let data = try getAllCourses()
            try realm.write({
                realm.delete(data)
            })
            CourseLoadedAgent.sharedInstance.signCourseToUnloaded()
        } catch StoragedDataError.noCoursesInStorage {
            CourseLoadedAgent.sharedInstance.signCourseToUnloaded()
        } catch {
            CourseLoadedAgent.sharedInstance.signCourseToUnloaded()
            throw StoragedDataError.realmError
        }
    }

}
