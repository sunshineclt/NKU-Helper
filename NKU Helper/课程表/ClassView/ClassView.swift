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
    
    var course: Course! {
        didSet {
            classNameLabel.text = course.name
            classroomLabel.text = course.classroom
            self.backgroundColor = course.color?.convertToUIColor() ?? UIColor.grayColor()
        }
    }
    
    class func loadFromNib() -> ClassView {
        return super.loadViewFromNibNamed("ClassView") as! ClassView
    }

}
