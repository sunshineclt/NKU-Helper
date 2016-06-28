//
//  ThingsToDo.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/9/25.
//  Copyright © 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

import Foundation

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
    
    class func thingsLeftCount() -> Int {
        var count = 0
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let thingsOption = userDefaults.objectForKey("things") as? NSArray
        if let things = thingsOption {
            for thingData in things {
                let aThingData = thingData as! NSData
                let aThing = NSKeyedUnarchiver.unarchiveObjectWithData(aThingData) as! ThingToDo
                if !aThing.done {
                    count += 1
                }
            }
        }
        return count
    }
    
    class func thingsLeft() -> [ThingToDo] {
        
        var thingsLeft = [ThingToDo]()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let thingsOption = userDefaults.objectForKey("things") as? NSArray
        if let things = thingsOption {
            for thingData in things {
                let aThingData = thingData as! NSData
                let aThing = NSKeyedUnarchiver.unarchiveObjectWithData(aThingData) as! ThingToDo
                thingsLeft.insert(aThing, atIndex: 0)
            }
        }
        return thingsLeft
    }
    
    class func thingsUpdate() -> [ThingToDo] {
        
        var thingsLeft = [ThingToDo]()
        let thingsLeftData = NSMutableArray()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let thingsOption = userDefaults.objectForKey("things") as? NSArray
        if let things = thingsOption {
            for thingData in things {
                let aThingData = thingData as! NSData
                let aThing = NSKeyedUnarchiver.unarchiveObjectWithData(aThingData) as! ThingToDo
                if !aThing.done {
                    thingsLeft.insert(aThing, atIndex: 0)
                    thingsLeftData.addObject(aThingData)
                }
            }
        }
        let thingsToSave:NSArray = NSArray(array: thingsLeftData)
        userDefaults.removeObjectForKey("things")
        userDefaults.setObject(thingsToSave, forKey: "things")
        userDefaults.synchronize()
        return thingsLeft
    }
    
}

enum ThingsType:Int {
    case Short = 0
    case Alarmed = 1
}