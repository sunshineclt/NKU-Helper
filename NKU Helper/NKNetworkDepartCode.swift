//
//  NKNetworkDepartCode.swift
//  NKU Helper
//
//  Created by 陈乐天 on 2/29/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
//

import Foundation
import Alamofire

class NKNetworkDepartCode: NKNetworkBase {
    
    func searchDepartCode(departCode: String) {
        let url = "http://115.28.141.95:25000/departCode/" + NSString(string: departCode).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        Alamofire.request(.GET, url).responseJSON { (response: Response<AnyObject, NSError>) -> Void in
            guard let result = response.result.value as? NSDictionary else {
    
                return
            }
            
        }
    }
    
}