//
//  PreferredColorAgent.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/13/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
//

import Foundation

private let sharedStoreAgent = PreferredColorAgent()

/// 提供访问颜色喜好的类
class PreferredColorAgent: StoreAgent, StoreProtocol {
    
    class var sharedInstance:PreferredColorAgent {
        return sharedStoreAgent
    }
    
    typealias dataForm = [Int]
    
    let key = "preferredColors"

    /**
     访问颜色喜好
     
     - throws: StoragedDataError.NoColorInStorage
     
     - returns: 颜色喜好组成的NSMutableArray
     */
    func getData() throws -> dataForm {

        if let colorDatas = userDefaults.objectForKey(key) as? [Int] {
            return colorDatas
        }
        else {
            throw StoragedDataError.NoColorInStorage
        }
        
    }
    
    /**
     存储颜色喜好
     
     - parameter data: 颜色喜好组成的NSMutableArray
     */
    func saveData(data: dataForm) {
        userDefaults.removeObjectForKey(key)
        userDefaults.setObject(data, forKey: key)
        userDefaults.synchronize()
    }
    
}
