//
//  NKNetworkSearchCourse.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/9/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
//

import Foundation

/**
 *  搜索课程的代理事件
 */
protocol SearchCourseDelegate {
    func didReceiveSearchResult(result: [Course])
}

/// 提供搜索课程功能的网络库
class NKNetworkSearchCourse: NKNetworkBase{
    
    var delegate:SearchCourseDelegate?
    
    /**
     根据课程名称搜索课程
     
     - parameter name: 课程名称
     */
    func searchCourseWithName(name: String) {
        
    }
    
}