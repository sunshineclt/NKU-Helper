//
//  CourseLoadMethodAgent.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/27.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import Foundation

private let sharedStoreAgent = CourseLoadMethodAgent()

class CourseLoadMethodAgent: UserDefaultsBaseStoreAgent, UserDefaultsStoreProtocol {
    
    private override init() {
        super.init()
    }
    
    class var sharedInstance:CourseLoadMethodAgent {
        return sharedStoreAgent
    }
    
    typealias dataForm = Int
    
    let key = "ClassLoadMethod"
    
    /**
     获取课表加载方法
     
     - returns: 课表加载方法（0代表从课程表加载，1代表从课程列表加载）
     */
    func getData() -> dataForm {
        if let courseLoadMethod = userDefaults.objectForKey(key) as? Int {
            return courseLoadMethod
        }
        else {
            return 0
        }
    }
    
    /**
     存储课程加载方法
     
     - parameter data: 要存储的课程加载方法（0代表从课程表加载，1代表从课程列表加载）
     */
    func saveData(data: dataForm) {
        userDefaults.removeObjectForKey(key)
        userDefaults.setObject(data, forKey: key)
        userDefaults.synchronize()
    }
    
}