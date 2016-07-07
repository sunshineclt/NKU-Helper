//
//  StoreProtocol.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/13/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
//

/**
*  存储访问类的协议
*/
protocol StoreProtocol {
    associatedtype dataForm
    var key:String {get}
    func getData() throws -> dataForm
    func saveData(data: dataForm)
}