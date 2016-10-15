//
//  Task.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/9/25.
//  Copyright © 2015年 陈乐天. All rights reserved.
//

import Foundation
import RealmSwift

/**
 任务类
 * * * * *
 
 last modified:
 - date: 2016.10.12
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
class Task: Object {
    
// MARK:- Property
    
    /// 标题
    dynamic var title = "我是标题"
    /// 描述
    dynamic var descrip = "我是描述"
    /// 截止日期
    dynamic var dueDate: Date?
    /// 是否完成
    dynamic var done = false
    /// 绑定的课程
    dynamic var forCourse: Course?
    /// 颜色
    dynamic var color: Color?
    /// 任务类型
    dynamic var typeStored = TaskType.general.rawValue
    var type: TaskType {
        get {
            return TaskType(rawValue: typeStored)!
        }
        set {
            try! realm?.write {
                typeStored = newValue.rawValue
            }
        }
    }
    
    /// 创建一个Task对象
    ///
    /// - parameter title:     标题
    /// - parameter descrip:   描述
    /// - parameter type:      任务类型
    /// - parameter dueDate:   截止日期，可选，默认为nil
    /// - parameter forCourse: 绑定的课程，可选，默认为nil
    ///
    /// - returns: Task对象
    convenience init(title: String, descrip: String, type: TaskType, dueDate: Date? = nil, forCourse: Course? = nil) {
        self.init()
        self.title = title
        self.descrip = descrip
        self.dueDate = dueDate
        self.forCourse = forCourse
        self.type = type
    }
    
// MARK:- 类方法
    
    /// 获取剩下的任务
    /// - note: 不包括已完成的任务，根据dueDate排序
    ///
    /// - throws: StoragedDataError.realmError
    ///
    /// - returns: 剩下的任务
    class func getLeftTasks() throws -> Results<Task> {
        do {
            let realm = try Realm()
            return realm.objects(Task.self).filter("done == false").sorted(byProperty: "dueDate")
        } catch {
            throw StoragedDataError.realmError
        }
    }
    
    /// 获取所有的任务
    /// - note: 包括已完成但未从存储中删去的任务，根据dueDate排序
    ///
    /// - throws: StoragedDataError.realmError
    ///
    /// - returns: 剩余的任务，根据dueDate排序
    class func getAllTasks() throws -> Results<Task> {
        do {
            let realm = try Realm()
            return realm.objects(Task.self).sorted(byProperty: "dueDate")
        } catch {
            throw StoragedDataError.realmError
        }
    }
    
    /// 获取指定课程所对应的任务
    /// - note: 包括已完成但未从存储中删去的任务，根据dueDate排序
    ///
    /// - parameter course: 指定课程
    ///
    /// - throws: StoragedDataError.realmError
    ///
    /// - returns: 该课程的任务
    class func getTasks(forCourse course: Course) throws -> Results<Task> {
        do {
            let realm = try Realm()
            return realm.objects(Task.self).filter("forCourse.key == \(course.key) AND done == false").sorted(byProperty: "dueDate")
        } catch {
            throw StoragedDataError.realmError
        }
    }
    
    /// 删去已完成的任务
    ///
    /// - throws: StoragedDataError.realmError
    class func updateStoredTasks() throws {
        do {
            let realm = try Realm()
            let doneTasks = realm.objects(Task.self).filter("done == true")
            try realm.write({
                realm.delete(doneTasks)
            })
        } catch {
            throw StoragedDataError.realmError
        }
    }
    
    /// 删除所有课程相关的任务
    /// - important: 在删除课程前必须调用此方法
    ///
    /// - throws: StoragedDataError.realmError
    class func deleteCourseTasks() throws {
        do {
            let realm = try Realm()
            let courseTasks = realm.objects(Task.self).filter({ (thing) -> Bool in
                return thing.type == .course
            })
            try realm.write({
                for courseTask in courseTasks {
                    realm.delete(courseTask)
                }
            })
        } catch {
            throw StoragedDataError.realmError
        }
    }
    
// MARK:- 实例方法
    
    /// 保存任务
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
    
    /// 删除任务
    ///
    /// - throws: StoragedDataError.realmError
    func delete() throws {
        do {
            let realm = try Realm()
            try realm.write({
                realm.delete(self)
            })
        } catch {
            throw StoragedDataError.realmError
        }
    }
    
    /// 更改任务完成状态
    ///
    /// - throws: StoragedDataError.realmError
    func toggleDone() throws {
        do {
            let realm = try Realm()
            try realm.write({
                self.done = !self.done
            })
        } catch {
            throw StoragedDataError.realmError
        }
    }
    
}

/**
 任务类
 - general: 一般
 - course:  课程作业
 * * * * *
 
 last modified:
 - date: 2016.10.1
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
enum TaskType: String {
    case general
    case course
}
