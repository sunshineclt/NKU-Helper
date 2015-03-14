//
//  imageGetter.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/2/7.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import Foundation
class imageGetter: NSObject ,NSURLConnectionDataDelegate {
    var connection:NSURLConnection?
    var responseData:NSMutableData?
    var readyToStart:Bool = false
    var block:((data:NSData?, err:NSError?)->Void)
    
    func getImageWithBlock(theBlock:(data:NSData?, err:NSError?)->Void){
        block = theBlock
        if readyToStart {
            responseData = NSMutableData()
            connection?.start()
            print("Image Receiving Data!\n")
        }
        else{
            print("Image Not Ready To Start Connection!!!\n")
        }
    }
    
    override init() {
        block = {(data:NSData?, err:NSError?)->Void in
        
        }
        super.init()
        var req:NSURLRequest = NSURLRequest(URL: NSURL(string: "http://222.30.32.10/ValidateCode")!)
        connection = NSURLConnection(request: req, delegate: self, startImmediately: false)
        readyToStart = false
        responseData = nil
        if let temp = connection {
            print("Image Connection Setting Succeed\n")
            readyToStart = true
        }
        else {
            var alertView:UIAlertView = UIAlertView(title: "网络错误", message: "没有网无法加载验证码", delegate: nil, cancelButtonTitle: "好，现在就去弄点网")
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        responseData?.appendData(data)
        print("Image didReceiveData!\n")
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        
        print("Image connection Did Finish Loading!\n")
        block(data: responseData, err: nil)

        
    }
    
}