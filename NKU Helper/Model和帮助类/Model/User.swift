//
//  User.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/24.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import Foundation

struct User {

    var userID: String!
    var password: String!
    var name: String!
    var timeEnteringSchool: String!
    var departmentAdmitted: String!
    var majorAdmitted: String!
    
    init(userID: String, password: String) {
        self.userID = userID
        self.password = password
    }
    
    init(userID: String, name: String, timeEnteringSchool: String, departmentAdmitted: String, majorAdmitted: String) {
        self.userID = userID
        self.name = name
        self.timeEnteringSchool = timeEnteringSchool
        self.departmentAdmitted = departmentAdmitted
        self.majorAdmitted = majorAdmitted
    }
    
    init(userID: String, password: String, name: String, timeEnteringSchool: String, departmentAdmitted: String, majorAdmitted: String) {
        self.userID = userID
        self.password = password
        self.name = name
        self.timeEnteringSchool = timeEnteringSchool
        self.departmentAdmitted = departmentAdmitted
        self.majorAdmitted = majorAdmitted
    }
    
}
