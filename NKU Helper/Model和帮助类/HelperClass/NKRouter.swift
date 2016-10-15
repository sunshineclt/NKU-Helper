//
//  NKRouter.swift
//  NKU Helper
//
//  Created by 陈乐天 on 2016/10/14.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import Foundation

private let sharedRouter = NKRouter()

/**
 控制页面跳转的类
 - note: 只是初步实现
 * * * * *
 
 last modified:
 - date: 2016.10.14
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
class NKRouter {
    
    var action: [String: Int]!
    
    class var sharedInstance: NKRouter {
        return sharedRouter
    }
    
    init() {
        
    }
    
}
