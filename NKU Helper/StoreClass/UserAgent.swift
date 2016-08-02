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

/// 提供访问用户ID和密码功能的类
class UserAgent: UserDefaultsBaseStoreAgent, UserDefaultsStoreProtocol {
    
    private override init() {
        super.init()
    }
    
    class var sharedInstance:UserAgent {
        return sharedStoreAgent
    }
    
    typealias dataForm = User
    
    let key = "accountInfo"

    /**
     访问用户ID和密码
     
     - throws: StoragedDataError.NoUserInStorage, StoragedDataError.NoPasswordInKeychain
     
     - returns: 用户ID和密码组成的元组
     */
    func getData() throws -> dataForm {
        guard let userInfo = userDefaults.objectForKey(key) as? [String: String] else {
            throw StoragedDataError.NoUserInStorage
        }
        guard let userID = userInfo["userID"] else {
            throw StoragedDataError.NoUserInStorage
        }
        guard let dictionary = Locksmith.loadDataForUserAccount(userID), password = dictionary["password"] as? String else {
            throw StoragedDataError.NoPasswordInKeychain
        }
        return User(userID: userID, password: password)
    }
    
    /**
     存储密码
     
     - parameter data: 需要存储的用户的用户名和密码
     
     - throws: 存储时出现的错误
     */
    func saveData(data: dataForm) throws {
        do {
            try Locksmith.updateData(["password": data.password], forUserAccount: data.userID)
        } catch let err {
            throw err
        }
    }
    
    /**
     删除密码信息
     
     - throws: 删除时出现的错误
     */
    func deleteData() throws {
        if let userInfo = userDefaults.objectForKey(key) as? NSDictionary {
            let userID = userInfo.objectForKey("userID") as! String
            do {
                try Locksmith.deleteDataForUserAccount(userID)
            } catch let err {
                throw err
            }
        }
    }
    
}