//
//  WeatherInfoGetter.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/4/24.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import Foundation
class WeatherInfoGetter: NSObject {
    
    var weather:NSMutableDictionary!
    var block:(() -> Void)!
    var error:Bool!
    
    init(block:(() -> Void)) {
        super.init()
        weather = NSMutableDictionary()
        self.block = block
        error = false
    }
    
    func getAllWeatherInfo() {
        getWeatherCondition()
        getPM25()
        save()
    }
    
    func getWeatherCondition() {
        
        var weatherGetter:WeatherConditionGetter = WeatherConditionGetter()
        var API:NSString = weatherGetter.getAPI()
        var url:NSURL = NSURL(string: API as String)!
        var returnData:NSData? = NSData(contentsOfURL: url)
        if let temp = returnData {
            
            //For Debug
            /*
            var returnString:NSString = NSString(data: returnData!, encoding: NSUTF8StringEncoding)!
            print(returnString)
            print("\n**********************\n")
            */
            
            let jsonData:NSDictionary? = NSJSONSerialization.JSONObjectWithData(returnData!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary
            if let json = jsonData {
                let temp:NSDictionary = jsonData!.objectForKey("f") as! NSDictionary
                let forecastAll = temp.objectForKey("f1") as! NSArray
                
                var theFirstDayForecast:NSDictionary = forecastAll.objectAtIndex(0) as! NSDictionary
                var theFirstDay:NSMutableDictionary = NSMutableDictionary()
                var weather = theFirstDayForecast.objectForKey("fa") as! String
                var temperature = theFirstDayForecast.objectForKey("fc") as! String
                var windDirection = theFirstDayForecast.objectForKey("fe") as! String
                var windStrenth = theFirstDayForecast.objectForKey("fg") as! String
                theFirstDay.setObject(weather, forKey: "dayWeather")
                theFirstDay.setObject(temperature, forKey: "dayTemperature")
                theFirstDay.setObject(windDirection, forKey: "dayWindDirection")
                theFirstDay.setObject(windStrenth, forKey: "dayWindStrenth")
                weather = theFirstDayForecast.objectForKey("fb") as! String
                temperature = theFirstDayForecast.objectForKey("fd") as! String
                windDirection = theFirstDayForecast.objectForKey("ff") as! String
                windStrenth = theFirstDayForecast.objectForKey("fh") as! String
                theFirstDay.setObject(weather, forKey: "nightWeather")
                theFirstDay.setObject(temperature, forKey: "nightTemperature")
                theFirstDay.setObject(windDirection, forKey: "nightWindDirection")
                theFirstDay.setObject(windStrenth, forKey: "nightWindStrenth")
                self.weather.setObject(theFirstDay, forKey: "firstDay")
                
                var theSecondDayForecast:NSDictionary = forecastAll.objectAtIndex(1) as! NSDictionary
                var theSecondDay:NSMutableDictionary = NSMutableDictionary()
                weather = theSecondDayForecast.objectForKey("fa") as! String
                temperature = theSecondDayForecast.objectForKey("fc") as! String
                windDirection = theSecondDayForecast.objectForKey("fe") as! String
                windStrenth = theSecondDayForecast.objectForKey("fg") as! String
                theSecondDay.setObject(weather, forKey: "dayWeather")
                theSecondDay.setObject(temperature, forKey: "dayTemperature")
                theSecondDay.setObject(windDirection, forKey: "dayWindDirection")
                theSecondDay.setObject(windStrenth, forKey: "dayWindStrenth")
                weather = theSecondDayForecast.objectForKey("fb") as! String
                temperature = theSecondDayForecast.objectForKey("fd") as! String
                windDirection = theSecondDayForecast.objectForKey("ff") as! String
                windStrenth = theSecondDayForecast.objectForKey("fh") as! String
                theSecondDay.setObject(weather, forKey: "nightWeather")
                theSecondDay.setObject(temperature, forKey: "nightTemperature")
                theSecondDay.setObject(windDirection, forKey: "nightWindDirection")
                theSecondDay.setObject(windStrenth, forKey: "nightWindStrenth")
                self.weather.setObject(theSecondDay, forKey: "secondDay")
                
                self.weather.setObject(NSDate(), forKey: "recentUpdateWeather")
            }
            else {
                error = true
            }
        }
        else {
            error = true
        }
    }
    
    func getPM25() {
        
        var urlString:String = "http://www.pm25.in/api/querys/only_aqi.json?city=tianjin&token=K4BcCM5m1pdnwo3AGe7p&stations=no"
        var url:NSURL = NSURL(string: urlString)!
        var returnData:NSData? = NSData(contentsOfURL: url)
        if let temp = returnData {
            let jsonData:NSArray? = NSJSONSerialization.JSONObjectWithData(returnData!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSArray
            if let json = jsonData {
                let aqiData:NSDictionary = jsonData!.objectAtIndex(0) as! NSDictionary
                let aqi:Int = aqiData.objectForKey("aqi") as! Int
                let quality:NSString = aqiData.objectForKey("quality") as! NSString
                self.weather.setObject(aqi, forKey: "aqi")
                self.weather.setObject(quality, forKey: "quality")
                
                self.weather.setObject(NSDate(), forKey: "recentUpdatePM25")
            }
            else {
                error = true
            }
        }
        else {
            error = true
        }
        
    }
    
    func getLifeIndex() {
        
        var weatherGetter:WeatherConditionGetter = WeatherConditionGetter(type: "index_v")
        var API:String = weatherGetter.getAPI() as String
        var url:NSURL = NSURL(string: API)!
        var returnData:NSData? = NSData(contentsOfURL: url)
        if let temp = returnData {
            
            let jsonData:NSDictionary? = NSJSONSerialization.JSONObjectWithData(returnData!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary
            if let json = jsonData {
                let indexData:NSArray = jsonData!.objectForKey("i") as! NSArray
                
                var index:NSMutableDictionary = NSMutableDictionary()
                
                for (var i=0;i<3;i++) {
                    
                    var indexAll = NSMutableDictionary()
                    
                    var indexDataNow:NSDictionary = indexData.objectAtIndex(i) as! NSDictionary
                    var indexName:NSString = indexDataNow.objectForKey("i2") as! NSString
                    var indexBrief:NSString = indexDataNow.objectForKey("i4") as! NSString
                    var indexDetail:NSString = indexDataNow.objectForKey("i5") as! NSString
                    
                    indexAll.setObject(indexName, forKey: "name")
                    indexAll.setObject(indexBrief, forKey: "brief")
                    indexAll.setObject(indexDetail, forKey: "detail")
                    
                    switch i {
                    case 0:index.setObject(indexAll, forKey: "cloth")
                    case 1:index.setObject(indexAll, forKey: "comfort")
                    default:index.setObject(indexAll, forKey: "exercise")
                    }
                    
                }
                
                self.weather.setObject(index, forKey: "index")
            }
            else {
                error = true
            }
        }
        else {
            error = true
        }
    }
    
    func save() {
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if !error {
            userDefaults.removeObjectForKey("weather")
            userDefaults.setObject(weather, forKey: "weather")
            userDefaults.synchronize()
        }
        else {
            var alertView:UIAlertView = UIAlertView(title: "网络错误", message: "木有网不能刷新天气哦~", delegate: nil, cancelButtonTitle: "好")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                alertView.show()
            })
        }
        block()
    }
    
}