//
//  NKNetworkEvaluateSubmit.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/22/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation
import Alamofire

protocol NKNetworkEvaluateSubmitProtocol {
    func didFailToSubmit()
    func didSuccessToSubmit()
}

/// 提供提交评教结果的网络类
class NKNetworkEvaluateSubmit: NKNetworkBase {
    
    var delegate: NKNetworkEvaluateSubmitProtocol?
    
    /**
     提交评教结果
     
     - parameter grade:   各项分数
     - parameter opinion: 意见
     - parameter index:   当前评教的课程的index
     */
    func submit(grade: [String], opinion: String, index: Int) {
        //TODO: 在开放时整理
        let url = NSURL(string: "http://222.30.32.10/evaluate/stdevatea/queryTargetAction.do")!
        let req = NSMutableURLRequest(URL: url)
        var data = String(format: "operation=Store")
        for i in 0 ..< grade.count {
            let gradeString = "&array[\(i)]=\(grade[i])"
            data = data.stringByAppendingString(gradeString)
        }
        data = data.stringByAppendingString("&opinion=\(opinion)")
        req.HTTPBody = data.dataUsingEncoding(CFStringConvertEncodingToNSStringEncoding(0x0632))
        req.addValue("http://222.30.32.10/evaluate/stdevatea/queryTargetAction.do?operation=target&index=\(index)", forHTTPHeaderField: "Referer")
        req.HTTPMethod = "POST"
        Alamofire.request(req).responseString { (response) -> Void in
            if let html = response.result.value {
                if (html as NSString).rangeOfString("成功保存").length > 0 {
                    self.delegate?.didSuccessToSubmit()
                }
                else {
                    self.delegate?.didFailToSubmit()
                }
            }
            else {
                self.delegate?.didFailToSubmit()
            }
        }
    }
    
}