//
//  CourseAgent.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/13/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import RealmSwift

private let sharedStoreAgent = CourseAgent()

/// 提供访问课程数据的类
class CourseAgent: StoreAgent {
    
    private override init() {
        super.init()
    }
    
    class var sharedInstance:CourseAgent {
        return sharedStoreAgent
    }
    
    let key = "courseLoaded"
    
    typealias dataForm = [Course]
    
    static var isCourseLoaded: Bool {
        return (NSUserDefaults.standardUserDefaults().objectForKey("courseLoaded") as? Bool) ?? false
    }
    
    
    /**
     获取所有课程
     
     - throws: StoragedDataError.NoClassesInStorage和RealmError
     
     - returns: 课程组成的Array
     */
    func getData() throws -> Results<Course> {
        guard CourseAgent.isCourseLoaded else {
            throw StoragedDataError.NoClassesInStorage
        }
        do {
            let realm = try Realm()
            let result = realm.objects(Course.self)
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
    func saveData(data: dataForm) throws {
        do {
            let realm = try Realm()
            try realm.write({ 
                for course in data {
                    realm.add(course)
                }
            })
            userDefaults.removeObjectForKey(key)
            userDefaults.setBool(true, forKey: key)
        } catch {
            throw StoragedDataError.RealmError
        }
    }
    
    /**
     删除课程信息
     
     - throws: RealmError
     */
    func deleteData() throws {
        do {
            let realm = try Realm()
            let data = try getData()
            try realm.write({ 
                for course in data {
                    realm.delete(course)
                }
            })
            userDefaults.removeObjectForKey(key)
            userDefaults.setBool(false, forKey: key)
        } catch StoragedDataError.NoClassesInStorage {
            userDefaults.removeObjectForKey(key)
            userDefaults.setBool(false, forKey: key)
        } catch {
            throw StoragedDataError.RealmError
        }
    }
    
}