//
//  ClassView.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/17.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import UIKit

class ClassView: UIView {
    
    @IBOutlet var classNameLabel: UILabel!
    @IBOutlet var classroomLabel: UILabel!
    
    var courseTime: CourseTime! {
        didSet {
            classNameLabel.text = courseTime.forCourse?.name
            classroomLabel.text = courseTime.classroom
            self.backgroundColor = courseTime.forCourse?.color?.convertToUIColor() ?? UIColor.gray
        }
    }
    
    class func loadFromNib() -> ClassView {
        return super.loadViewFromNib(named: "ClassView") as! ClassView
    }

}
