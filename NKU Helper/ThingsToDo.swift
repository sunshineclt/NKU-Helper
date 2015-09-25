//
//  ThingsToDo.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/9/25.
//  Copyright © 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

import Foundation

class ThinsToDo: NSObject, NSCoding {
    
    var name:String
    var place:String?
    var time:NSDate?
    
    init(name:String, place:String?, time:NSDate?) {
        
        self.name = name
        self.time = time
        super.init()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.time = aDecoder.decodeObjectForKey("time") as? NSDate
        self.place = aDecoder.decodeObjectForKey("place") as? String
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(time, forKey: "time")
        aCoder.encodeObject(place, forKey: "place")
    }
    
}