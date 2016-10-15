//
//  CourseSelecting.swift
//  NKU Helper
//
//  Created by 陈乐天 on 2/29/16.
//  Copyright © 2015年 陈乐天. All rights reserved.
//

import Foundation

/**
 选课中的课程类
 - important: 未启用!!!
 * * * * *
 
 last modified:
 - date: 2016.10.1
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
class CourseSelecting: NSObject {

    var ID: String
    var name: String
    var teacherName: String
    var weekday: Int
    var time: String
    var startEndWeek: String
    var classroom: String
    var classType: ClassType
    var teachingMethod: String
    var depart: String
    var number: Int
    
    init(ID: String, name: String, teachername: String, weekday: Int, time: String, startEndWeek: String, classroom: String, classType: ClassType, number: Int, teachingMethod: String, depart: String) {
        
        self.ID = ID
        self.name = name
        self.teacherName = teachername
        self.weekday = weekday
        self.time = time
        self.startEndWeek = startEndWeek
        self.classroom = classroom
        self.classType = classType
        self.teachingMethod = teachingMethod
        self.depart = depart
        self.number = number
    }
    
}

enum ClassType: String {
    case JiHuaNei = "计划内"
    case XianXuan = "限选"
}
