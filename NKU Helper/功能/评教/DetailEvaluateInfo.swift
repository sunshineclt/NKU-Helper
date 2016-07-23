//
//  DetailEvaluateInfo.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/21/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import Foundation

struct Question {
    var content: String
    var grade: Int
}

struct DetailEvaluateSection {
    var title: String
    var question: [Question]
}