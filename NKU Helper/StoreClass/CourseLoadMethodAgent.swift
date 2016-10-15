//
//  CourseLoadMethodAgent.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/27.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import Foundation

private let sharedStoreAgent = CourseLoadMethodAgent()

/**
 访问课程加载方式的帮助类
 * * * * *
 
 last modified:
 - date: 2016.9.30
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
class CourseLoadMethodAgent: UserDefaultsBaseStoreAgent, UserDefaultsStoreProtocol {
    
    class var sharedInstance: CourseLoadMethodAgent {
        return sharedStoreAgent
    }
    
    typealias dataForm = Int
    
    let key = "ClassLoadMethod"
    
    /// 获取课表加载方法
    /// - note: 0代表从课程表加载，1代表从课程列表加载
    ///
    /// - returns: 课表加载方法
    func getData() -> dataForm {
        return userDefaults.integer(forKey: key)
    }
    
    /// 存储课程加载方法
    /// - note: 0代表从课程表加载，1代表从课程列表加载
    ///
    /// - parameter data: 课表加载方法
    func save(data: dataForm) {
        userDefaults.removeObject(forKey: key)
        userDefaults.set(data, forKey: key)
        userDefaults.synchronize()
    }
    
}
