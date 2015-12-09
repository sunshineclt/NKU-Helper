//
//  Notification.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/12/8.
//  Copyright © 2015年 &#38472;&#20048;&#22825;. All rights reserved.
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
        self.time = time
        self.url = url
        self.text = text
        self.readCount = readCount
    }
    
}