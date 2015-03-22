//
//  WeatherConditionGetter.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/12.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import Foundation
class WeatherConditionGetter: NSObject {
    
    let areaid:NSString = "101030100"
    var type:NSString = "forecast_v"
    var date:NSString!
    let appid:NSString = "8133cf32c98ad57d"
    let private_key:NSString = "321736_SmartWeatherAPI_274766d"
    var key:NSString!
    
    init(type:NSString) {
        super.init()
        self.type = type
        date = getDate()

    }
    
    override init() {
        super.init()
        date = getDate()
    }
    
    func getDate() -> NSString {
        
        var currentDate:NSDate = NSDate()
        var dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        var dateCut:NSString = dateFormatter.stringFromDate(currentDate)
        dateCut = dateCut.substringToIndex(12)
        return dateCut
    }
    
    func getPublicKey() -> NSString {
        var result:NSString = NSString(format: "http://open.weather.com.cn/data/?areaid=%@&type=%@&date=%@&appid=%@", areaid, type, date, appid)
        return result
    }
    
    func getAPI() -> NSString {
        
        getDate()
        key = hmacSha1()
        key = stringByEncodingURLFormat()
        var shortAppid = appid.substringToIndex(6)
        var result:NSString = NSString(format: "http://open.weather.com.cn/data/?areaid=%@&type=%@&date=%@&appid=%@&key=%@", areaid, type, date, shortAppid, key)
        return result
    }
    
    func stringByEncodingURLFormat() -> NSString {
        
        var encodedString:NSString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, key, nil, "!$&'()*+,-./:;=?@_~%#[]", CFStringBuiltInEncodings.UTF8.rawValue)
        return encodedString
        
    }

    func hmacSha1() -> NSString {
        var public_key = getPublicKey()
        
        var secretData:NSData = private_key.dataUsingEncoding(NSUTF8StringEncoding)!
        var stringData:NSData = public_key.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let keyBytes = secretData.bytes
        let dataBytes = stringData.bytes
        
        var outs = malloc(UInt(CC_SHA1_DIGEST_LENGTH))
        
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), keyBytes, UInt(secretData.length), dataBytes, UInt(stringData.length), outs)

        var signatureData:NSData = NSData(bytesNoCopy: outs, length: 20, freeWhenDone: true)
        
        return signatureData.base64EncodedString()
        
    }
    
}