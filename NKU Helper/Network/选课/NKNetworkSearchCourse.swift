//
//  NKNetworkSearchCourse.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/9/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/**
 *  搜索课程的代理事件
 */
protocol NKNetworkSearchCourseDelegate {
    func didReceiveSearchResult(result: [CourseSelecting])
    func didFailToReceiveSearchResult(message: String)
}

/// 提供搜索课程功能的网络库
class NKNetworkSearchCourse: NKNetworkBase{
    
    var delegate:NKNetworkSearchCourseDelegate?
    
    /**
     根据课程名称搜索课程
     
     - parameter name: 课程名称
     */
    func searchCourseWithClassName(name: String) {
        let url = "http://115.28.141.95:25000/class/classname/" + NSString(string: name).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        Alamofire.request(.GET, url).responseJSON { (response: Response<AnyObject, NSError>) -> Void in
            switch response.result {
            case .Success(let value):
                let json = JSON(value)
                guard json["code"].intValue == 0 else {
                    self.delegate?.didFailToReceiveSearchResult(json["message"].stringValue)
                    return
                }
                let data = json["data"].arrayValue
                var searchResult = [CourseSelecting]()
                for i in 1 ..< data.count {
                    let now = data[i].arrayValue
                    let jiHuaNei = now[2].intValue
                    let xianXuan = now[3].intValue
                    var classType: ClassType
                    var number: Int
                    if jiHuaNei > 0 {
                        classType = ClassType.JiHuaNei
                        number = jiHuaNei
                    }
                    else {
                        classType = ClassType.XianXuan
                        number = xianXuan
                    }
                    let courseSelecting = CourseSelecting(ID: now[0].stringValue, name: now[1].stringValue, teachername: now[4].stringValue, weekday: now[6].intValue, time: now[7].stringValue, startEndWeek: now[8].stringValue, classroom: now[9].stringValue, classType: classType, number: number, teachingMethod: now[5].stringValue, depart: now[10].stringValue)
                    searchResult.append(courseSelecting)
                }
                self.delegate?.didReceiveSearchResult(searchResult)
            case .Failure(let error):
                print(error)
                self.delegate?.didFailToReceiveSearchResult("网络错误")
            }
            
        }
    }
    
    func searchCourseWithClassID(ID: String) {
        let url = "http://115.28.141.95:25000/class/classname/" + NSString(string: ID).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        Alamofire.request(.GET, url).responseJSON { (response: Response<AnyObject, NSError>) -> Void in
            guard (response.result.value as? NSDictionary) != nil else {
                self.delegate?.didReceiveSearchResult([])
                return
            }
            
        }
    }
    
    func searchCourseWithTeachername(teachername: String) {
        let url = "http://115.28.141.95:25000/class/classname/" + NSString(string: teachername).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        Alamofire.request(.GET, url).responseJSON { (response: Response<AnyObject, NSError>) -> Void in
            guard (response.result.value as? NSDictionary) != nil else {
                self.delegate?.didReceiveSearchResult([])
                return
            }
            
        }
    }
    
    func searchCourseWithDepartcode(departcode: String) {
        let url = "http://115.28.141.95:25000/class/classname/" + NSString(string: departcode).stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        Alamofire.request(.GET, url).responseJSON { (response: Response<AnyObject, NSError>) -> Void in
            guard (response.result.value as? NSDictionary) != nil else {
                self.delegate?.didReceiveSearchResult([])
                return
            }
            
        }
    }
    

    
}