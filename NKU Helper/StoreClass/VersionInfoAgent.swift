//
//  VersionInfoAgent.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/8/2.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import Foundation
private let sharedStoreAgent = VersionInfoAgent()

/// 提供访问用户详细数据的类
class VersionInfoAgent: UserDefaultsBaseStoreAgent {
    
    private override init() {
        super.init()
    }
    
    class var sharedInstance: VersionInfoAgent {
        return sharedStoreAgent
    }
    
    typealias dataForm = (Version: String, Build: String)?
    
    let key = "buildCode"
    
    /**
     访问存储中的Version号和Build号
     
     - returns: Version号和Build号组成的元组
     */
    func getData() -> dataForm {
        guard let data = userDefaults.objectForKey(key) as? [String: String] else {
            return nil
        }
        return (Version: data["version"]!, Build: data["build"]!)
    }
    
    /**
     存储当前Version号和Build号
     */
    func saveData() {
        let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        let build = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String
        let data = ["version": version, "build": build]
        userDefaults.removeObjectForKey(key)
        userDefaults.setObject(data, forKey: key)
        userDefaults.synchronize()
    }
    
}