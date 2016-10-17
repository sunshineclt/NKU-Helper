//
//  PrintLog.swift
//  NKU Helper
//
//  Created by 陈乐天 on 2016/10/17.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import Foundation
func printLog<T>(_ message: T,
                 file: String = #file,
                 method: String = #function,
                 line: Int = #line)
{
        print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
}
