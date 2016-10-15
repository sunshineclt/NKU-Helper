//
//  UserAgent.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/13/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import Locksmith

private let sharedStoreAgent = UserAgent()

/**
 访问用户ID和密码功能的类
 * * * * *
 
 last modified:
 - date: 2016.10.15
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
class UserAgent: UserDefaultsBaseStoreAgent {
    
    class var sharedInstance:UserAgent {
        return sharedStoreAgent
    }
    
    typealias dataForm = User
    
    let key = "accountInfo"

    /// 访问用户信息
    ///
    /// - throws: StoragedDataError.noUserInStorage, StoragedDataError.noPasswordInKeychain
    ///
    /// - returns: User对象
    func getUserInfo() throws -> dataForm {
        guard let userInfo = userDefaults.dictionary(forKey: key) as? [String: String] else {
            throw StoragedDataError.noUserInStorage
        }
        guard let userID = userInfo["userID"] else {
            throw StoragedDataError.noUserInStorage
        }
        guard let dictionary = Locksmith.loadDataForUserAccount(userAccount: userID),
            let password = dictionary["password"] as? String else {
                throw StoragedDataError.noPasswordInKeychain
        }
        let name = userInfo["name"]!
        let timeEnteringSchool = userInfo["timeEnteringSchool"]!
        let departmentAdmitted = userInfo["departmentAdmitted"]!
        let majorAdmitted = userInfo["majorAdmitted"]!
        return User(userID: userID, password: password, name: name, timeEnteringSchool: timeEnteringSchool, departmentAdmitted: departmentAdmitted, majorAdmitted: majorAdmitted)
    }
    
    /// 存储用户信息
    ///
    /// - parameter data: 需要存储的用户
    ///
    /// - throws: 存储时出现的错误
    func save(data: dataForm) throws {
  //      try Locksmith.deleteDataForUserAccount(userAccount: data.userID)
        //try Locksmith.saveData(data: ["password": data.password], forUserAccount: data.userID)
        try Locksmith.updateData(data: ["password": data.password], forUserAccount: data.userID)
        let dictionary = ["userID": data.userID, "name": data.name, "timeEnteringSchool": data.timeEnteringSchool, "departmentAdmitted": data.departmentAdmitted, "majorAdmitted": data.majorAdmitted]
        userDefaults.removeObject(forKey: key)
        userDefaults.set(dictionary, forKey: key)
        userDefaults.synchronize()
    }
    
    /// 删除用户信息
    ///
    /// - throws: 删除时出现的错误
    func delete() throws {
        if let userInfo = userDefaults.dictionary(forKey: key) as? [String: String] {
            let userID = userInfo["userID"]!
            try Locksmith.deleteDataForUserAccount(userAccount: userID)
        }
        userDefaults.removeObject(forKey: key)
    }
    
}
