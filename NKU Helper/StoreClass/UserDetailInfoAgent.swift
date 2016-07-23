//
//  UserDetailInfoAgent.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/20/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation

private let sharedStoreAgent = UserDetailInfoAgent()

/// 提供访问用户详细数据的类
class UserDetailInfoAgent:StoreAgent, StoreProtocol {
    
    class var sharedInstance:UserDetailInfoAgent {
        return sharedStoreAgent
    }

    typealias dataForm = (UserID: String, Password: String, Name: String, TimeEnteringSchool: String, DepartmentAdmitted: String, MajorAdmitted: String)
    
    let key = "accountInfo"
    
    /**
     访问用户详细数据
     
     - throws: StoragedDataError.NoUserInStorage
     
     - returns: 用户ID、密码、姓名、入学时间、录取院系、录取专业组成的元组
     */
    func getData() throws -> dataForm {
        
        if let userInfo = userDefaults.objectForKey(key) as? NSDictionary {
            let userID = userInfo.objectForKey("userID") as! String
            let password = userInfo.objectForKey("password") as! String
            let name = userInfo.objectForKey("name") as! String
            let timeEnteringSchool = userInfo.objectForKey("timeEnteringSchool") as! String
            let departmentAdmitted = userInfo.objectForKey("departmentAdmitted") as! String
            let majorAdmitted = userInfo.objectForKey("majorAdmitted") as! String
            return (UserID: userID, Password: password, Name: name, TimeEnteringSchool: timeEnteringSchool, DepartmentAdmitted: departmentAdmitted, MajorAdmitted: majorAdmitted)
        }
        else {
            throw StoragedDataError.NoUserInStorage
        }
        
    }
    
    /**
     存储用户详细数据
     
     - parameter data: 需要存储的用户详细信息
     */
    func saveData(data: dataForm) {
        
    }
    
}