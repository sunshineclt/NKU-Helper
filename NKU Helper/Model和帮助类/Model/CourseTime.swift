//
//  CourseTime.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/30.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import Foundation
import RealmSwift

/**
 课时类
 * * * * *
 
 last modified:
 - date: 2016.10.12
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
class CourseTime: Object {
    
// MARK:- Property
    
    /// 主键
    dynamic var key = 0
    /// 教室
    dynamic var classroom = "未知"
    /// 单双周
    dynamic var weekOddEven = "单双周"
    /// 星期几
    dynamic var weekday = 1
    /// 开始的节数
    dynamic var startSection = 1
    /// 持续的节数
    dynamic var sectionNumber = 2
    /// 结束的节数
    var endSection: Int {
        return startSection + sectionNumber - 1
    }
    /// 开始的周数
    dynamic var startWeek = 1
    /// 结束的周数
    dynamic var endWeek = 16
    /// 对应的课程
    dynamic var forCourse: Course?
    
    /// 设置主键
    ///
    /// - returns: 主键
    override static func primaryKey() -> String? {
        return "key"
    }

    /// 创建一个课时对象
    ///
    /// - parameter key:           主键
    /// - parameter classroom:     教室
    /// - parameter weekOddEven:   单双周
    /// - parameter weekday:       星期几
    /// - parameter startSection:  开始的节数
    /// - parameter sectionNumber: 持续的节数
    /// - parameter startWeek:     开始的周数
    /// - parameter endWeek:       节数的周数
    /// - parameter forCourse:     对应的课程
    ///
    /// - returns: 创建的课时对象
    convenience init(key: Int, classroom: String, weekOddEven: String, weekday: Int, startSection: Int, sectionNumber: Int, startWeek: Int, endWeek: Int, forCourse: Course) {
        self.init()
        self.key = key
        self.classroom = classroom
        self.weekOddEven = ""
        if (weekOddEven as NSString).range(of: "单").length > 0 {
            self.weekOddEven += "单"
        }
        if (weekOddEven as NSString).range(of: "双").length > 0 {
            self.weekOddEven += "双"
        }
        self.weekOddEven += "周"
        self.weekday = weekday
        self.startSection = startSection
        self.sectionNumber = sectionNumber
        self.startWeek = startWeek
        self.endWeek = endWeek
        self.forCourse = forCourse
    }

// MARK:- 实例方法
    
    /// 保存课时
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
    
    /// 获取所有课时
    /// - note: 按照加载顺序排列
    ///
    /// - throws: StoragedDataError.realmError
    ///
    /// - returns: 所有课时
    static func getAllCourseTimes() throws -> Results<CourseTime> {
        do {
            let realm = try Realm()
            let result = realm.objects(CourseTime.self).sorted(byProperty: "key")
            return result
        } catch {
            throw StoragedDataError.realmError
        }
    }
    
    /// 删除所有课时
    /// - important: 在删除所有课程之前必须调用此方法
    ///
    /// - throws: StoragedDataError.realmError
    static func deleteAllCourseTimes() throws {
        do {
            let realm = try Realm()
            let data = try getAllCourseTimes()
            try realm.write({ 
                realm.delete(data)
            })
        } catch {
            throw StoragedDataError.realmError
        }
    }
    
}
