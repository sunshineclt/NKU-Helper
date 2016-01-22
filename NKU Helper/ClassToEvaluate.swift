//
//  ClassToEvaluate.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/21/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
//

import Foundation

class ClassToEvaluate {
    
    var className: String
    var teacherName: String
    var hasEvaluated: Bool
    var index: Int
    
    init(className: String, teacherName: String, hasEvaluated: String, index: Int) {
        self.className = className
        self.teacherName = teacherName
        if hasEvaluated == "未评价" {
            self.hasEvaluated = false
        }
        else {
            self.hasEvaluated = true
        }
        self.index = index
    }
    
}