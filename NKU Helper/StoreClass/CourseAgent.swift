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
class CourseAgent: UserDefaultsBaseStoreAgent {
    
    private override init() {
        super.init()
    }
    
    class var sharedInstance:CourseAgent {
        return sharedStoreAgent
    }
    
    let key = "courseLoaded"

    /// 获取课程是否加载的标记
    var isCourseLoaded: Bool {
        return (NSUserDefaults.standardUserDefaults().objectForKey("courseLoaded") as? Bool) ?? false
    }
    
    /**
     标记课程为未加载
     */
    func signCourseToUnloaded() {
        userDefaults.removeObjectForKey(key)
        userDefaults.setBool(false, forKey: key)
        userDefaults.synchronize()
    }
    
    /**
     标记课程为已加载
     */
    func signCourseToLoaded() {
        userDefaults.removeObjectForKey(key)
        userDefaults.setBool(true, forKey: key)
        userDefaults.synchronize()
    }
    
}