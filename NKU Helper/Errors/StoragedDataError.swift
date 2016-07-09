//
//  StoragedDataError.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/7.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import Foundation

/**
 存储错误
 
 - NoClassesInStorage: 存储中没有课程信息
 - NoUserInStorage:    存储中没有用户信息
 - NoColorInStorage:   存储中没有颜色信息
 */
enum StoragedDataError: ErrorType {

    case NoClassesInStorage
    case NoUserInStorage
    case NoColorInStorage
    
}