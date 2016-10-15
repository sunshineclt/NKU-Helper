//
//  StoragedDataError.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/7.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import Foundation

/// 存储错误
///
/// - noCoursesInStorage:   存储中没有课程信息
/// - noUserInStorage:      存储中没有用户信息
/// - noPasswordInKeychain: 钥匙串中没有用户密码信息
/// - noColorInStorage:     存储中没有颜色信息
/// - realmError:           Realm错误
enum StoragedDataError: Error {
    case noCoursesInStorage
    case noUserInStorage
    case noPasswordInKeychain
    case noColorInStorage
    case realmError
}
