//
//  gradeGetter.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/2/14.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import Foundation
class GradeGetter: NSObject, NSURLConnectionDataDelegate {
    
    var block:((result:NSArray?, abcgpa:NSString?, error:String?)->Void)!
    var respondData:NSMutableData?
    var finalResult:NSMutableArray = NSMutableArray()
    var flag:Bool
    var pre:NSString = NSString(string: "Hello Kugou")
    
    override init() {

        respondData = nil
        flag = false
        super.init()
        
    }
    
    func getGrade(block:(result:NSArray?, abcgpa:NSString?, error:String?)->Void){
        
        self.block = block
        
        let req:NSURLRequest = NSURLRequest(URL: NSURL(string: "http://222.30.32.10/xsxk/studiedAction.do")!)
        let connection = NSURLConnection(request: req, delegate: self)
        if let _ = connection {
            respondData = NSMutableData()
        }
        else {
            block(result: nil, abcgpa:nil, error: "网络错误")
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        respondData?.appendData(data)
//        print("data did Receive!\n")
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        //        print("data did finish loading\n")
        
        let encoding:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
        var html:NSString = NSString(data: respondData!, encoding: encoding)!
        if html.isEqualToString(pre as String) {
            let abcgpa = html.substringWithRange(NSMakeRange(html.rangeOfString("ABC类课学分绩").location+9, html.rangeOfString("成绩合格课程").location-html.rangeOfString("ABC类课学分绩").location-10))
            block(result: finalResult, abcgpa:abcgpa, error: nil)
        }
        else {
            /*
            print("*********************************************\n")
            print("*********************************************\n")
            print("*********************************************\n")
            print("*********************************************\n")
            print(html)
            */
            pre = html
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
            
            let regularXP1:NSRegularExpression = try! NSRegularExpression(pattern: "<tr", options: NSRegularExpressionOptions.CaseInsensitive)
            let regularXP2:NSRegularExpression = try! NSRegularExpression(pattern: "(<td.*?>)(.*?)(\t)(</td>)", options: NSRegularExpressionOptions.DotMatchesLineSeparators)
            let matches:NSArray = regularXP1.matchesInString(ans as String, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, ans.length))
            for var i=0; i<matches.count; i++ {
                let r1:NSTextCheckingResult = matches.objectAtIndex(i) as! NSTextCheckingResult
                var r2:NSTextCheckingResult
                var now:NSString
                if (i < matches.count-1){
                    r2 = matches.objectAtIndex(i+1) as! NSTextCheckingResult
                    now = ans.substringWithRange(NSMakeRange(r1.range.location, r2.range.location-r1.range.location))
                }
                else{
                    now = ans.substringFromIndex(r1.range.location)
                }
                let items:NSArray = regularXP2.matchesInString(now as String, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, now.length))
                
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
                
                let obj:NSMutableDictionary = NSMutableDictionary()
                obj.setObject(className, forKey: "className")
                obj.setObject(classType, forKey: "classType")
                obj.setObject(grade, forKey: "grade")
                obj.setObject(credit, forKey: "credit")
                
                finalResult.addObject(obj)
                
            }
            
            let req:NSURLRequest = NSURLRequest(URL: NSURL(string: "http://222.30.32.10/xsxk/studiedPageAction.do?page=next")!)
            let connection = NSURLConnection(request: req, delegate: self)
            if let _ = connection {
                respondData = NSMutableData()
            }
            else {
                block(result: nil, abcgpa:nil, error: "网络错误")
            }

            
        }
        
    }
    
}