//
//  CourseTime.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/30.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import Foundation
import RealmSwift

/// 课时类
class CourseTime: Object {
    
    dynamic var key = 0
    dynamic var classroom = "未知"
    dynamic var weekOddEven = "单双周"
    dynamic var weekday = 1
    dynamic var startSection = 1
    dynamic var sectionNumber = 2
    dynamic var startWeek = 1
    dynamic var endWeek = 16
    let forCourse = LinkingObjects(fromType: Course.self, property: "courseTimes")
    var ownerCourse: Course {
        return forCourse[0]
    }
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
    var endSection: Int {
        return startSection + sectionNumber - 1
    }
    
    convenience init(key: Int, classroom: String, weekOddEven: NSString, weekday: Int, startSection: Int, sectionNumber: Int, startWeek: Int, endWeek: Int) {
        self.init()
        self.key = key
        self.classroom = classroom
        self.weekOddEven = ""
        if weekOddEven.rangeOfString("单").length > 0 {
            self.weekOddEven += "单"
        }
        if weekOddEven.rangeOfString("双").length > 0 {
            self.weekOddEven += "双"
        }
        self.weekOddEven += "周"
        self.weekday = weekday
        self.startSection = startSection
        self.sectionNumber = sectionNumber
        self.startWeek = startWeek
        self.endWeek = endWeek
    }

    /**
     保存课时
     
     - throws: RealmError
     */
    func save() throws {
        do {
            let realm = try Realm()
            try realm.write({
                realm.add(self)
            })
        } catch {
            throw StoragedDataError.RealmError
        }
    }
    
    /**
     获取所有课时
     
     - throws: RealmError
     
     - returns: 所有课时
     */
    static func getAll() throws -> Results<CourseTime> {
        do {
            let realm = try Realm()
            let result = realm.objects(CourseTime.self).sorted("key")
            return result
        } catch {
            throw StoragedDataError.RealmError
        }
    }
    
    /**
     删除所有课时
     
     - throws: RealmError
     */
    static func deleteAll() throws {
        do {
            let realm = try Realm()
            let data = try getAll()
            try realm.write({ 
                realm.delete(data)
            })
        } catch {
            throw StoragedDataError.RealmError
        }
    }
    
}
