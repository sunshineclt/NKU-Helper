//
//  User.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/24.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import Foundation

/**
 用户信息类
 * * * * *
 
 last modified:
 - date: 2016.10.12
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
struct User {

    /// 学号
    var userID: String
    /// 密码
    var password: String
    /// 姓名
    var name: String
    /// 入学时间
    var timeEnteringSchool: String
    /// 录取院系
    var departmentAdmitted: String
    /// 录取专业
    var majorAdmitted: String
    
    /// 创建一个User对象
    ///
    /// - parameter userID:             学号
    /// - parameter password:           密码
    /// - parameter name:               姓名
    /// - parameter timeEnteringSchool: 入学时间
    /// - parameter departmentAdmitted: 录取院系
    /// - parameter majorAdmitted:      录取专业
    ///
    /// - returns: User对象
    init(userID: String, password: String, name: String, timeEnteringSchool: String, departmentAdmitted: String, majorAdmitted: String) {
        self.userID = userID
        self.password = password
        self.name = name
        self.timeEnteringSchool = timeEnteringSchool
        self.departmentAdmitted = departmentAdmitted
        self.majorAdmitted = majorAdmitted
    }
    
}
