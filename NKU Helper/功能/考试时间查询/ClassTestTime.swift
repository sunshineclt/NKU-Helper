//
//  ClassTestTime.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/26.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import Foundation

class ClassTestTime: NSObject {
    
    var className: String
    var week: Int
    var weekday: Int
    var startSection: Int
    var endSection: Int
    var classroom: String
    var startTime: Date
    var endTime: Date
    
    init(classname: String, week: Int, weekday: Int, startSection: Int, endSection: Int, classroom: String, startTime: String, endTime: String) {
        self.className = classname
        self.week = week
        self.weekday = weekday
        self.startSection = startSection
        self.endSection = endSection
        self.classroom = classroom
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedStartTime = (startTime as NSString).substring(to: (startTime as NSString).length - 2)
        self.startTime = dateFormatter.date(from: formattedStartTime)!
        let formattedEndTime = (endTime as NSString).substring(to: (endTime as NSString).length - 2)
        self.endTime = dateFormatter.date(from: formattedEndTime)!
    }
    
    /**
     获取日期的String表示
     
     - returns: 日期的String表示
     */
    func getDayString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd"
        return dateFormatter.string(from: startTime)
    }
    
    /**
     获取考试时间的String表示
     
     - returns: 考试时间的String表示
     */
    func getTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: startTime) + " - " + dateFormatter.string(from: endTime)
    }
    
    /**
     获取所有考试的周数信息，供分组使用
     
     - parameter classTestTime: 所有考试的周数信息
     
     - returns: 所有考试在哪几周
     */
    class func getWeekArray(_ classTestTime: [ClassTestTime]) -> [Int] {
        let arr = classTestTime.map { (testTime) -> Int in
            return testTime.week
        }
        let set = Set(arr)
        return Array(set).sorted()
    }
    
}
