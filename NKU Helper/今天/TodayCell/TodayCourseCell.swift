//
//  TodayCourseCell.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/28.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import UIKit

class TodayCourseCell: UITableViewCell {

    @IBOutlet var containerView: UIView!
    @IBOutlet var colorView: UIView!
    @IBOutlet var classnameLabel: UILabel!
    @IBOutlet var classroomLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!

    var courseTime: CourseTime! {
        didSet {
            colorView.backgroundColor = courseTime.ownerCourse.color?.convertToUIColor() ?? UIColor.grayColor()
            classnameLabel.text = courseTime.ownerCourse.name
            classroomLabel.text = courseTime.classroom
            timeLabel.text = "第\(courseTime.startSection)节到第\(courseTime.endSection)节"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.shadowOffset = CGSizeMake(2, 2)
        containerView.layer.shadowColor = UIColor.grayColor().CGColor
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowOpacity = 0.5
    }
    
}
