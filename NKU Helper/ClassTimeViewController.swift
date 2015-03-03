//
//  ClassTimeViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/1.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class ClassTimeViewController: UIViewController, NSURLConnectionDataDelegate {
    
    @IBOutlet var classTimeWebView: UIWebView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var accountInfo:NSDictionary? = userDefaults.objectForKey("accountInfo") as NSDictionary?
        if let temp = accountInfo {
            
        }
        else {
            self.performSegueWithIdentifier("saveAccountInfo", sender: nil)
        }
        
        
    }
    
    override  func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        if isLogIn() {
            refreshClassTimeTable("myself")
            var req:NSURLRequest = NSURLRequest(URL: NSURL(string: "http://222.30.32.10/xsxk/selectedAction.do?operation=kebiao")!)
            classTimeWebView.loadRequest(req)
        }
        else {
            self.performSegueWithIdentifier("login", sender: nil)
        }
    }
    
    func isLogIn() -> Bool {
        var req:NSURLRequest = NSURLRequest(URL: NSURL(string: "http://222.30.32.10/xsxk/selectedAction.do?operation=kebiao")!)
        var response:NSHTTPURLResponse = NSHTTPURLResponse()
        var receivedData:NSData = NSURLConnection.sendSynchronousRequest(req, returningResponse: nil, error: nil)!
        var encoding:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
        var html:NSString = NSString(data: receivedData, encoding: encoding)!
        if html.rangeOfString("星期一").length > 0 {
            return true
        }
        else{
            return false
        }
    }
    
    
    @IBAction func refreshClassTimeTable(sender: AnyObject) {
        
        if isLogIn() {
            var req:NSURLRequest = NSURLRequest(URL: NSURL(string: "http://222.30.32.10/xsxk/selectedAction.do?operation=kebiao")!)
            classTimeWebView.loadRequest(req)
        }
        else {
            self.performSegueWithIdentifier("login", sender: nil)
        }
    }
    
}