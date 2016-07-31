//
//  ThingsToDo.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/9/25.
//  Copyright © 2015年 陈乐天. All rights reserved.
//

import Foundation
import RealmSwift

/// Thing的类
class Task: Object {
    
    dynamic var title = "我是标题"
    dynamic var descrip = "我是描述"
    dynamic var dueDate: NSDate?
    dynamic var done = false
    dynamic var forCourse: Course?
    dynamic var color: Color?
    dynamic var typeStored = TaskType.General.rawValue
    var type: TaskType {
        get {
            return TaskType(rawValue: typeStored)!
        }
        set {
            typeStored = newValue.rawValue
        }
    }
    
    convenience init(title: String, descrip: String, type: TaskType, dueDate: NSDate? = nil, forCourse: Course? = nil) {
        self.init()
        self.title = title
        self.descrip = descrip
        self.dueDate = dueDate
        self.forCourse = forCourse
        self.type = type
    }
    
    /**
     获取剩余的任务（不包括已完成的任务），根据dueDate排序
     
     - throws: RealmError
     
     - returns: 剩余的任务（不包括已完成的任务），根据dueDate排序
     */
    class func getLeftTasks() throws -> Results<Task> {
        do {
            let realm = try Realm()
            return realm.objects(Task.self).filter("done == false").sorted("dueDate")
        } catch {
            throw StoragedDataError.RealmError
        }
    }
    
    /**
     获取所有的任务（包括已完成但未从存储中删去的任务），根据dueDate排序
     
     - throws: RealmError
     
     - returns: 剩余的任务，根据dueDate排序
     */
    class func getTasks() throws -> Results<Task> {
        do {
            let realm = try Realm()
            return realm.objects(Task.self).sorted("dueDate")
        } catch {
            throw StoragedDataError.RealmError
        }
    }
    
    /**
     删去已完成的任务
     
     - throws: RealmError
     */
    class func updateStoredTasks() throws {
        do {
            let realm = try Realm()
            let doneTasks = realm.objects(Task.self).filter("done == true")
            try realm.write({
                realm.delete(doneTasks)
            })
        } catch {
            throw StoragedDataError.RealmError
        }
    }
    
    /**
     获取指定课程所对应的任务
     
     - parameter course: 指定课程
     
     - throws: RealmError
     
     - returns: 该课程的任务
     */
    class func getTasksForCourse(course: Course) throws -> Results<Task> {
        do {
            let realm = try Realm()
            return realm.objects(Task.self).filter("forCourse.key == \(course.key) AND done == false").sorted("dueDate")
        } catch {
            throw StoragedDataError.RealmError
        }
    }
    
    /**
     删除课程相关的任务
     
     - throws: RealmError
     */
    static func deleteCourseTasks() throws {
        do {
            let realm = try Realm()
            let courseTasks = realm.objects(Task.self).filter({ (thing) -> Bool in
                return thing.type == .Course
            })
            try realm.write({
                for courseTask in courseTasks {
                    realm.delete(courseTask)
                }
            })
        } catch {
            throw StoragedDataError.RealmError
        }
    }
    
    /**
     保存任务
     
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
     删除任务
     
     - throws: RealmError
     */
    func delete() throws {
        do {
            let realm = try Realm()
            try realm.write({
                realm.delete(self)
            })
        } catch {
            throw StoragedDataError.RealmError
        }
    }
    
    /**
     更改done的状态
     
     - throws: RealmError
     */
    func toggleDone() throws {
        do {
            let realm = try Realm()
            try realm.write({
                self.done = !self.done
            })
        } catch {
            throw StoragedDataError.RealmError
        }
    }
    
}

enum TaskType: String {
    case General
    case Course
}