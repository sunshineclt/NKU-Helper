//
//  gradeGetter.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/2/14.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import Foundation
class GradeGetter: NSObject, NSURLConnectionDataDelegate {
    
    var block:(result:NSArray)->Void
    var respondData:NSMutableData?
    var connection:NSURLConnection?
    var step:Int
    var finalResult:NSMutableArray?
    override init() {
        block = {(result:NSArray)->Void in
            
        }
        respondData = nil
        connection = nil
        step = 0
        finalResult = nil
        super.init()

    }
    
    func getGrade(uid:NSString, password:NSString, validateCode:NSString, block:(result:NSArray)->Void){
        self.block = block
        var url:NSURL = NSURL(string: "http://222.30.32.10/stdloginAction.do")!
        var req:NSMutableURLRequest = NSMutableURLRequest(URL: url)
    
        //for debug
    
        var uid_test = "1410159"
        var password_test = "110089"
        
        var data:NSString = NSString(format: "operation=&usercode_text=%@&userpwd_text=%@&checkcode_text=%@&submittype=%%C8%%B7+%%C8%%CF", uid_test, password_test, validateCode)
        
        //for debug ended
        
        req.HTTPBody = data.dataUsingEncoding(NSUTF8StringEncoding)
        req.HTTPMethod = "POST"
        connection = NSURLConnection(request: req, delegate: self)
        step = 1
        if let temp = connection {
            respondData = NSMutableData()
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        respondData?.appendData(data)
        print("data did Receive!\n")
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        
        if (step == 1) {
            var encoding:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
            var html:NSString = NSString(data: respondData!, encoding: encoding)!
//            print("****************************************\n")
//            print(html)
            step = 2
            var req:NSURLRequest = NSURLRequest(URL: NSURL(string: "http://222.30.32.10/xsxk/studiedAction.do")!)
            self.connection = NSURLConnection(request: req, delegate: self)
            respondData = NSMutableData()
        }
        else{
            
            finalResult = NSMutableArray()
            if (step == 2){
                var encoding:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
                var html:NSString = NSString(data: respondData!, encoding: encoding)!
                
                print("*********************************************\n")
                print("*********************************************\n")
                print("*********************************************\n")
                print("*********************************************\n")
                print(html)
                
                html = html.substringFromIndex(html.rangeOfString("/table").location+6)
                var ans:NSString = html.substringWithRange(NSMakeRange(html.rangeOfString("<table").location, html.rangeOfString("/table").location - html.rangeOfString("<table").location))
                ans = ans.substringFromIndex(ans.rangeOfString("/tr").location+4)
                
                print("*********************************************\n")
                print("*********************************************\n")
                print("*********************************************\n")
                print("*********************************************\n")
                print(ans)
                
                var regularXP1:NSRegularExpression = NSRegularExpression(pattern: "<tr", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!
                var regularXP2:NSRegularExpression = NSRegularExpression(pattern: "(<td.*?>)(.*?)(\t)(</td>)", options: NSRegularExpressionOptions.DotMatchesLineSeparators, error: nil)!
                var matches:NSArray = regularXP1.matchesInString(ans, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, ans.length))
                for var i=0; i<matches.count; i++ {
                    var r1:NSTextCheckingResult = matches.objectAtIndex(i) as NSTextCheckingResult
                    var r2:NSTextCheckingResult
                    var now:NSString
                    if (i < matches.count-1){
                        r2 = matches.objectAtIndex(i+1) as NSTextCheckingResult
                        now = ans.substringWithRange(NSMakeRange(r1.range.location, r2.range.location-r1.range.location))
                    }
                    else{
                        now = ans.substringFromIndex(r1.range.location)
                    }
                    var items:NSArray = regularXP2.matchesInString(now, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, now.length))
                    
                    print("*********************************************\n")
                    print("*********************************************\n")
                    print("*********************************************\n")
                    print("*********************************************\n")
                    print("There are \(items.count) items\n")
                    
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
                    print("Name is \(className), Type is \(classType), grade is \(grade), credit is \(credit)\n")
                    
                    var obj:NSMutableDictionary = NSMutableDictionary()
                    obj.setObject(className, forKey: "className")
                    obj.setObject(classType, forKey: "classType")
                    obj.setObject(grade, forKey: "grade")
                    obj.setObject(credit, forKey: "credit")
                    
                    finalResult?.addObject(obj)
                    
                    
                }
                
                block(result: finalResult!)

                
            }
            
            
            
        }
        
    }
    
}