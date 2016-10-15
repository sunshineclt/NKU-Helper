//
//  CalendarConverter.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/7/5.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import Foundation

/**
 获取日期信息的帮助类
 * * * * *
 
 last modified:
 - date: 2016.10.12
 
 - author: 陈乐天
 - since: Swift3.0
 - version: 1.0
 */
class CalendarHelper {
    
    /// 获取当前日期是星期几
    /// - note: 数字形式
    /// - important: 周日为0，周一为1
    ///
    /// - returns: 当前日期是星期几
    static func getWeekdayInt() -> Int {
        let components = getNowDateComponent()
        switch (components.weekday!) {
        case 1:return 0
        case 2:return 1
        case 3:return 2
        case 4:return 3
        case 5:return 4
        case 6:return 5
        case 7:return 6
        default:return -1
        }
    }
    
    /// 获取当前月份、日期、星期几信息
    /// - note: 字符串形式
    /// - note: 星期几信息形如"星期天"
    ///
    /// - returns: 当前月份、日期、星期几信息
    static func getMonthDayWeekdayString() -> (String, String, String) {
        let components = getNowDateComponent()
        let month = "\(components.month!)"
        let day = "\(components.day!)"
        var weekday: String
        switch (components.weekday!) {
        case 1:weekday = "星期天"
        case 2:weekday = "星期一"
        case 3:weekday = "星期二"
        case 4:weekday = "星期三"
        case 5:weekday = "星期四"
        case 6:weekday = "星期五"
        case 7:weekday = "星期六"
        default:weekday = "星期N"
        }
        return (month, day, weekday)
    }
    
    /// 建立一个在今天之后若干天的Date对象
    /// - note: 时间为0时0分0秒
    ///
    /// - parameter day: 几天后
    ///
    /// - returns: 所需的Date对象
    static func buildDate(afterDays days: Int) -> Date {
        let components = getNowDateComponent()
        let calendar = Calendar.current
        var originalDay = DateComponents()
        originalDay.year = components.year
        originalDay.month = components.month
        originalDay.day = components.day
        return Date(timeInterval: Double(days) * 24 * 60 * 60, since: calendar.date(from: originalDay)!)
    }
    
    /// 获取当前时间信息
    /// - important: 数字形式（为小时+分钟/60）
    ///
    /// - returns: 当前时间信息
    static func getTime() -> Double {
        let components = getNowDateComponent()
        let time = Double(components.hour!) + Double(components.minute!)/60
        return time
    }
    
    /// 将数字的周几信息转化为字符串的周几信息
    /// - important: 周一为1，周日为7
    ///
    /// - parameter weekday: 数字的周几信息
    ///
    /// - returns: 字符串的周几信息
    static func getWeekdayString(fromWeekday weekday: Int) -> String {
        switch weekday {
        case 1:return "周一"
        case 2:return "周二"
        case 3:return "周三"
        case 4:return "周四"
        case 5:return "周五"
        case 6:return "周六"
        case 7:return "周日"
        default:return "未知"
        }
    }
    
    /// 获取第几节课的开始时间信息
    ///
    /// - parameter section: 第几节课（从0开始）
    ///
    /// - returns: 该课的开始时间
    static func getTimeInfo(forSection section: Int) -> String {
        switch section {
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

    /// 获取从当前时间到目标时间的时间差的人性化显示
    ///
    /// - parameter toDate: 目标时间
    ///
    /// - returns: 时间差的人性化显示
    static func getCustomTimeIntervalDisplay(toDate: Date) -> String {
        let nowComponents = getNowDateComponent()
        let toDateComponents = Calendar.current.dateComponents([.weekday, .month, .day, .hour, .minute, .year], from: toDate)
        var component = DateComponents()
        component.day = toDateComponents.day! - nowComponents.day!
        component.month = toDateComponents.month! - nowComponents.month!
        component.year = toDateComponents.year! - nowComponents.year!
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month, .weekOfMonth, .day]
        formatter.unitsStyle = .abbreviated
        formatter.includesTimeRemainingPhrase = true
        return formatter.string(from: component)!
    }
    
    /// 获取现在时间的各个components
    ///
    /// - returns: DateComponents
    static func getNowDateComponent() -> DateComponents {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday, .month, .day, .hour, .minute, .year], from: date)
        return components
    }
    
}
