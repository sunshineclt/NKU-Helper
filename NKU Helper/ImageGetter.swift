//
//  imageGetter.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/2/7.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import Foundation
class imageGetter: NSObject ,NSURLConnectionDataDelegate {
    
    var responseData:NSMutableData?
    var block:((data:NSData?, err:String?)->Void)!
    
    override init() {
        super.init()
        responseData = nil
        block = nil
    }
    
    func getImageWithBlock(theBlock:(data:NSData?, err:String?)->Void) {
        
        block = theBlock
        let req:NSURLRequest = NSURLRequest(URL: NSURL(string: "http://222.30.32.10/ValidateCode")!)
        responseData = NSMutableData()
        let connection = NSURLConnection(request: req, delegate: self)
        if let _ = connection {
            print("Image Connection Setting Succeed\n", terminator: "")
        }
        else {
            block(data: nil, err:"网络错误")
        }
    }

    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        responseData?.appendData(data)
        print("Image didReceiveData!\n", terminator: "")
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        print("Image connection Did Finish Loading!\n", terminator: "")
        block(data: responseData, err: nil)
    }
    
}