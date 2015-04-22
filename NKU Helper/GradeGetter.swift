//
//  gradeGetter.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/2/14.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import Foundation
class GradeGetter: NSObject, NSURLConnectionDataDelegate {
    
    var block:(result:NSArray?, error:String?)->Void
    var respondData:NSMutableData?
    var connection:NSURLConnection?
    var finalResult:NSMutableArray?
    var flag:Bool
    
    override init() {
        block = {(result:NSArray?, error:String?)->Void in
            
        }
        respondData = nil
        connection = nil
        finalResult = nil
        flag = false
        super.init()
        
    }
    
    func getGrade(block:(result:NSArray?, error:String?)->Void){
        
        self.block = block
        
        var req:NSURLRequest = NSURLRequest(URL: NSURL(string: "http://222.30.32.10/xsxk/studiedAction.do")!)
        self.connection = NSURLConnection(request: req, delegate: self)
        if let temp = connection {
            respondData = NSMutableData()
        }
        else {
            var alertView:UIAlertView = UIAlertView(title: "网络错误", message: "木有网没有办法获得成绩呢！", delegate: nil, cancelButtonTitle: "好的好的，为了该死的成绩去搞点网吧")
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        respondData?.appendData(data)
//        print("data did Receive!\n")
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
//        print("data did finish loading\n")

        finalResult = NSMutableArray()
        var encoding:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
        var html:NSString = NSString(data: respondData!, encoding: encoding)!
        
/*
        print("*********************************************\n")
        print("*********************************************\n")
        print("*********************************************\n")
        print("*********************************************\n")
        print(ans)
*/
        
        html = html.substringFromIndex(html.rangeOfString("/table").location+6)
        var ans:NSString = html.substringWithRange(NSMakeRange(html.rangeOfString("<table").location, html.rangeOfString("/table").location - html.rangeOfString("<table").location))
        ans = ans.substringFromIndex(ans.rangeOfString("/tr").location+4)
        
/*
        print("*********************************************\n")
        print("*********************************************\n")
        print("*********************************************\n")
        print("*********************************************\n")
        print(ans)
*/
        
        var regularXP1:NSRegularExpression = NSRegularExpression(pattern: "<tr", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!
        var regularXP2:NSRegularExpression = NSRegularExpression(pattern: "(<td.*?>)(.*?)(\t)(</td>)", options: NSRegularExpressionOptions.DotMatchesLineSeparators, error: nil)!
        var matches:NSArray = regularXP1.matchesInString(ans as String, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, ans.length))
        for var i=0; i<matches.count; i++ {
            var r1:NSTextCheckingResult = matches.objectAtIndex(i) as! NSTextCheckingResult
            var r2:NSTextCheckingResult
            var now:NSString
            if (i < matches.count-1){
                r2 = matches.objectAtIndex(i+1) as! NSTextCheckingResult
                now = ans.substringWithRange(NSMakeRange(r1.range.location, r2.range.location-r1.range.location))
            }
            else{
                now = ans.substringFromIndex(r1.range.location)
            }
            var items:NSArray = regularXP2.matchesInString(now as String, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, now.length))
            
/*
            print("*********************************************\n")
            print("*********************************************\n")
            print("*********************************************\n")
            print("*********************************************\n")
            print("There are \(items.count) items\n")
*/
            
            var className:NSString
            var classType:NSString
            var grade:NSString
            var credit:NSString
            
            className = now.substringWithRange(items.objectAtIndex(2).rangeAtIndex(2))
            className = className.substringToIndex(className.length-13)
            classType = now.substringWithRange(items.objectAtIndex(3).rangeAtIndex(2))
            classType = classType.substringToIndex(classType.length-13)
            grade = now.substringWithRange(items.objectAtIndex(4).rangeAtIndex(2))
            grade = grade.substringToIndex(grade.length-13)
            credit = now.substringWithRange(items.objectAtIndex(5).rangeAtIndex(2))
            credit = credit.substringToIndex(credit.length-13)
            
//      print("Name is \(className), Type is \(classType), grade is \(grade), credit is \(credit)\n")
        
            var obj:NSMutableDictionary = NSMutableDictionary()
            obj.setObject(className, forKey: "className")
            obj.setObject(classType, forKey: "classType")
            obj.setObject(grade, forKey: "grade")
            obj.setObject(credit, forKey: "credit")
            
            finalResult?.addObject(obj)
            
            
        }
        
        block(result: finalResult!, error: nil)
        
    }
    
}