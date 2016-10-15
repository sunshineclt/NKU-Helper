//
//  VersionInfoAgent.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/8/2.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import Foundation

private let sharedStoreAgent = VersionInfoAgent()

/**
 访问用户详细数据的类
 * * * * *
 
 last modified:
 - date: 2016.9.30
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
class VersionInfoAgent: UserDefaultsBaseStoreAgent {

    class var sharedInstance: VersionInfoAgent {
        return sharedStoreAgent
    }
    
    typealias dataForm = (Version: String, Build: String)?
    
    let key = "buildCode"
    
    /// 访问存储中的Version号和Build号
    ///
    /// - returns: Version号和Build号组成的元组
    func getData() -> dataForm {
        guard let data = userDefaults.dictionary(forKey: key) as? [String: String] else {
            return nil
        }
        return (Version: data["version"]!, Build: data["build"]!)
    }
    
    /// 存储当前Version号和Build号
    func saveData() {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        let data = ["version": version, "build": build]
        userDefaults.removeObject(forKey: key)
        userDefaults.set(data, forKey: key)
        userDefaults.synchronize()
    }
    
}
