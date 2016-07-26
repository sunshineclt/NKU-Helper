//
//  ClassInfoTableViewCell.swift
//  NKU Helper
//
//  Created by 陈乐天 on 2/29/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import UIKit

class ClassInfoTableViewCell: UITableViewCell {

    var course: CourseSelecting! {
        didSet {
            classNameLabel.text = course.name
            teacherNameLabel.text = course.teacherName
            teachingMethodLabel.text = course.teachingMethod
            timeLabel.text = "周\(course.weekday) " + course.time + "节"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    @IBOutlet var classNameLabel: UILabel!
    @IBOutlet var teacherNameLabel: UILabel!
    @IBOutlet var teachingMethodLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
}
