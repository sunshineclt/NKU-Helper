//
//  UserDefaultsStoreProtocol.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/13/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

/**
*  NSUserDefaults存储访问类的协议
*/
protocol UserDefaultsStoreProtocol {
    
    /// 数据读取和存储的格式
    associatedtype dataForm
    
    /// NSUserDefaults存储的key
    var key:String {get}
    
    func getData() throws -> dataForm
    func saveData(data: dataForm) throws
}