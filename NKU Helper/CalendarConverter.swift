//
//  CalendarConverter.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/7/5.
//  Copyright (c) 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

import Foundation
class CalendarConverter: NSObject {
    
    static let sharedInstance = CalendarConverter()
    
    static func weekdayInt() -> Int {
        
        let date = NSDate()
        let calender:NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let unitFlags:NSCalendarUnit = NSCalendarUnit.Weekday
        let components:NSDateComponents = calender.components(unitFlags, fromDate: date)
        var weekdayInt:Int = -1
        switch (components.weekday) {
        case 1:
            weekdayInt = 6
        case 2:
            weekdayInt = 0
        case 3:
            weekdayInt = 1
        case 4:
            weekdayInt = 2
        case 5:
            weekdayInt = 3
        case 6:
            weekdayInt = 4
        case 7:
            weekdayInt = 5
        default:weekdayInt = -1
        }

        return weekdayInt
        
    }
    
    static func monthDayWeekdayString() -> (String, String, String) {
        
        let date = NSDate()
        let calender:NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        
        let unitFlags:NSCalendarUnit = [NSCalendarUnit.Weekday, NSCalendarUnit.Month, NSCalendarUnit.Day]
        let components:NSDateComponents = calender.components(unitFlags, fromDate: date)
        let month:String = "\(components.month)"
        let day:String = "\(components.day)"
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
        default:weekday = "星期N"
        }
        
        return (month, day, weekday)
            
    }
    
    static func weekdayTimeInt() -> (Int, Double) {
        
        let date = NSDate()
        let calender:NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let unitFlags:NSCalendarUnit = [NSCalendarUnit.Weekday, NSCalendarUnit.Hour, NSCalendarUnit.Minute]
        let components:NSDateComponents = calender.components(unitFlags, fromDate: date)
        var weekdayInt:Int = -1
        switch (components.weekday) {
        case 1:
            weekdayInt = 6
        case 2:
            weekdayInt = 0
        case 3:
            weekdayInt = 1
        case 4:
            weekdayInt = 2
        case 5:
            weekdayInt = 3
        case 6:
            weekdayInt = 4
        case 7:
            weekdayInt = 5
        default:weekdayInt = -1
        }
        
        let hourInt:Double = Double(components.hour) + Double(components.minute)/60
        
        return (weekdayInt, hourInt)
    }
    
    static func timeInt() -> Double {
        
        let date = NSDate()
        let calender:NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let unitFlags:NSCalendarUnit = [NSCalendarUnit.Hour, NSCalendarUnit.Minute]
        let components:NSDateComponents = calender.components(unitFlags, fromDate: date)
        let time:Double = Double(components.hour) + Double(components.minute)/60
        
        return time
    }
    
}