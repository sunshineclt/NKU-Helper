//
//  CalendarConverter.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/7/5.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import Foundation

/// 获取日期信息的帮助类，规定周日为0，周一为1
class CalendarHelper {
    
    /**
     获取当前日期是星期几（数字形式）
     
     - returns: 当前日期是星期几
     */
    static func getWeekdayInt() -> Int {

        let components = getNowDateComponent()
        switch (components.weekday) {
        case 1:
            return 6
        case 2:
            return 0
        case 3:
            return 1
        case 4:
            return 2
        case 5:
            return 3
        case 6:
            return 4
        case 7:
            return 5
        default:
            return -1
        }
        
    }
    
    /**
     获取当前月份、日期、星期几信息（字符串形式）
     
     - returns: 当前月份、日期、星期几信息
     */
    static func getMonthDayWeekdayString() -> (String, String, String) {
        
        let components = getNowDateComponent()
        let month = "\(components.month)"
        let day = "\(components.day)"
        var weekday:String
        switch (components.weekday) {
        case 1:
            weekday = "星期天"
        case 2:
            weekday = "星期一"
        case 3:
            weekday = "星期二"
        case 4:
            weekday = "星期三"
        case 5:
            weekday = "星期四"
        case 6:
            weekday = "星期五"
        case 7:
            weekday = "星期六"
        default:
            weekday = "星期N"
        }
        return (month, day, weekday)
            
    }
    
    /**
     获取当前时间信息（数字形式）
     
     - returns: 当前时间信息（为小时+分钟/60）
     */
    static func getTimeInt() -> Double {
        
        let components = getNowDateComponent()
        let time = Double(components.hour) + Double(components.minute)/60
        
        return time
    }
    
    /**
     将数字的周几信息转化为字符串的周几信息（1为周一，7为周日）
     
     - parameter weekday: 数字的周几信息
     
     - returns: 字符串的周几信息
     */
    static func getWeekdayStringFromWeekdayInt(weekday: Int) -> String {
        switch weekday {
        case 1:return "周一"
        case 2:return "周二"
        case 3:return "周三"
        case 4:return "周四"
        case 5:return "周五"
        case 6:return "周六"
        case 7:return "周日"
        default:return ""
        }
    }
    
    /**
     获取第几节课的开始时间信息
     
     - parameter sectionInt: 第几节课（从0开始）
     
     - returns: 该课的开始时间
     */
    static func getTimeInfoFromSectionInt(sectionInt: Int) -> String {
        switch sectionInt {
        case 0:return "08:00"
        case 1:return "08:55"
        case 2:return "10:00"
        case 3:return "10:55"
        case 4:return "12:00"
        case 5:return "12:55"
        case 6:return "14:00"
        case 7:return "14:55"
        case 8:return "16:00"
        case 9:return "16:55"
        case 10:return "18:30"
        case 11:return "19:25"
        case 12:return "20:20"
        case 13:return "21:15"
        default:return ""
        }
    }
    
    static private func getNowDateComponent() -> NSDateComponents {
        let date = NSDate()
        let calender = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let unitFlags:NSCalendarUnit = [.Weekday, .Month, .Day, .Hour, .Minute]
        let components = calender.components(unitFlags, fromDate: date)
        return components
    }
    
}