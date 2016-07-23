//
//  CourseAgent.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/13/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation

private let sharedStoreAgent = CourseAgent()

/// 提供访问课程数据的类
class CourseAgent: StoreAgent, StoreProtocol {
    
    class var sharedInstance:CourseAgent {
        return sharedStoreAgent
    }
    
    typealias dataForm = NSArray
    
    let key = "courses"
    
    /**
     获取所有课程
     
     - throws: StoragedDataError.NoClassesInStorage
     
     - returns: 课程组成的NSArray
     */
    func getData() throws -> dataForm {
        
        if let courseDatas = userDefaults.objectForKey(key) as? NSArray {
            return courseDatas
        }
        else {
            throw StoragedDataError.NoClassesInStorage
        }
        
    }
    
    /**
     存储课程信息（暂未实现）
     
     - parameter data: 要存储的课程信息
     */
    func saveData(data: dataForm) {
        
    }
    
    
}