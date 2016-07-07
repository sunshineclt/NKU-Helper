//
//  ThingsToDo.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/9/25.
//  Copyright © 2015年 陈乐天. All rights reserved.
//

import Foundation

/// Thing的类
class ThingToDo: NSObject, NSCoding {
    
    var name:String
    var time:NSDate?
    var done:Bool
    var type:ThingsType
    
    init(name:String, time:NSDate?, place:String?, type:ThingsType) {
        
        self.name = name
        self.time = time
        self.done = false
        self.type = type
        super.init()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.time = aDecoder.decodeObjectForKey("time") as? NSDate
        self.done = aDecoder.decodeObjectForKey("done") as! Bool
        let type = aDecoder.decodeObjectForKey("type") as! Int
        self.type = ThingsType(rawValue: type)!
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(time, forKey: "time")
        aCoder.encodeObject(done, forKey: "done")
        aCoder.encodeObject(self.type.rawValue, forKey: "type")
    }
    
    static let userDefaults = NSUserDefaults.standardUserDefaults()
    
    /**
     获取剩余事情的数量（不包括已完成的事情）
     
     - returns: 剩余事情的数量（不包括已完成的事情）
     */
    class func getLeftThingsCount() -> Int {
        var count = 0
        if let thingDatas = userDefaults.objectForKey("things") as? [NSData] {
            count = thingDatas.map({ (thingData) -> ThingToDo in
                return NSKeyedUnarchiver.unarchiveObjectWithData(thingData) as! ThingToDo
            }).reduce(0, combine: { (oldCount, aThing) -> Int in
                return oldCount + (aThing.done ? 0 : 1)
            })
        }
        return count
    }
    
    /**
     获取所有的事情（包括已完成但未从存储中删去的事情）
     
     - returns: 所有的事情（包括已完成但未从存储中删去的事情）
     */
    class func getThings() -> [ThingToDo] {
        
        var thingsLeft = [ThingToDo]()
        if let thingDatas = userDefaults.objectForKey("things") as? [NSData] {
            thingDatas.forEach({ (thingData) in
                let aThing = NSKeyedUnarchiver.unarchiveObjectWithData(thingData) as! ThingToDo
                thingsLeft.insert(aThing, atIndex: 0)
            })
        }
        return thingsLeft
    }
    
    /**
     更新存储中的事情，将已完成的事情删去（同步过程）
     */
    class func updateStoredThings() {
        
        var thingsLeftData = [NSData]()
        if let thingDatas = userDefaults.objectForKey("things") as? [NSData] {
            thingsLeftData = thingDatas.filter({ (thingData) -> Bool in
                let aThing = NSKeyedUnarchiver.unarchiveObjectWithData(thingData) as! ThingToDo
                return !aThing.done
            })
        }
        userDefaults.removeObjectForKey("things")
        userDefaults.setObject(thingsLeftData, forKey: "things")
        userDefaults.synchronize()
    }
    
}

enum ThingsType:Int {
    case Short = 0
    case Alarmed = 1
}