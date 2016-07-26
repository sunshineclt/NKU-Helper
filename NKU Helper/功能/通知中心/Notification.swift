//
//  Notification.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/12/8.
//  Copyright © 2015年 陈乐天. All rights reserved.
//

import Foundation

class Notification: NSObject {
    
    let title:String
    let time:String
    let url:String
    let text:String
    let readCount:Int
    
    init(title:String, time:String, url:String, text:String, readCount:Int) {
        self.title = title
        let regualarExpression = try! NSRegularExpression(pattern: "(\\d{4}-\\d{2}-\\d{2})T\\d{2}:\\d{2}:\\d{2}.\\d{3}Z", options: .CaseInsensitive)
        let matches = regualarExpression.matchesInString(time, options: .ReportCompletion, range: NSMakeRange(0, (time as NSString).length))
        let match = matches.first!
        self.time = (time as NSString).substringWithRange(match.rangeAtIndex(1))
        self.url = url
        self.text = text
        self.readCount = readCount
    }
    
}