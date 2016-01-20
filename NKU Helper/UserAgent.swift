//
//  UserAgent.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/13/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
//

import Foundation

private let sharedStoreAgent = UserAgent()

/// 提供访问用户数据的类
class UserAgent:StoreAgent, StoreProtocol {
    
    class var sharedInstance:UserAgent {
        return sharedStoreAgent
    }
    
    typealias dataForm = (UserID: String, Password: String)
    
    let key = "accountInfo"

    /**
     访问用户数据
     
     - returns: 用户ID和密码组成的元组
     */
    func getData() -> dataForm? {
        let userInfo = userDefaults.objectForKey(key) as? NSDictionary
        guard userInfo != nil else {
            return nil
        }
        let userID = userInfo!.objectForKey("userID") as! String
        let password = userInfo!.objectForKey("password") as! String
        return (userID, password)
    }
    
    func saveData(data: dataForm) {
        
    }
    
}