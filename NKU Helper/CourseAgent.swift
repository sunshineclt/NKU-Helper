//
//  CourseAgent.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/13/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
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
     访问课程
     
     - returns: 课程组成的NSArray
     */
    func getData() -> dataForm? {
        return userDefaults.objectForKey(key) as? NSArray
    }
    
    func saveData(data: dataForm) {
        
    }
    
    
}