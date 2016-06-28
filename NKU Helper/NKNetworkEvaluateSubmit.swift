//
//  NKNetworkEvaluateSubmit.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/22/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
//

import Foundation
import Alamofire

protocol NKNetworkEvaluateSubmitProtocol {
    func didFailToSubmit()
    func didSuccessToSubmit()
}

class NKNetworkEvaluateSubmit: NKNetworkBase {
    
    var delegate: NKNetworkEvaluateSubmitProtocol?
    
    func submit(grade: [String], opinion: String, index: Int) {
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
        Alamofire.request(req).responseString { (response: Response<String, NSError>) -> Void in
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