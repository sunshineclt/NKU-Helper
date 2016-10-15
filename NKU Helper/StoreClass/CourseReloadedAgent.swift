//
//  CourseLoadedAgent.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/13/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import RealmSwift

private let sharedStoreAgent = CourseLoadedAgent()

/**
 访问课程数据的类
 * * * * *
 
 last modified:
 - date: 2016.9.30
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
class CourseLoadedAgent: UserDefaultsBaseStoreAgent {
    
    class var sharedInstance: CourseLoadedAgent {
        return sharedStoreAgent
    }
    
    let key = "courseLoaded"

    /// 获取课程是否加载的标记
    var isCourseLoaded: Bool {
        return (UserDefaults.standard.object(forKey: "courseLoaded") as? Bool) ?? false
    }
    
    /// 标记课程为已加载
    func signCourseToUnloaded() {
        userDefaults.removeObject(forKey: key)
        userDefaults.set(false, forKey: key)
        userDefaults.synchronize()
    }
    
    /// 标记课程为已加载
    func signCourseToLoaded() {
        userDefaults.removeObject(forKey: key)
        userDefaults.set(true, forKey: key)
        userDefaults.synchronize()
    }
    
}
