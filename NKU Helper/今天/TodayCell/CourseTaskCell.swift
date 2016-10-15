//
//  CourseTaskCell.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/28.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import UIKit

class CourseTaskCell: MCSwipeTableViewCell {

    @IBOutlet var containerView: UIView!
    @IBOutlet var colorView: UIView!
    @IBOutlet var classNameLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    var task: Task! {
        didSet {
            colorView.backgroundColor = task.color?.convertToUIColor() ?? UIColor.gray
            classNameLabel.text = task.forCourse!.name
            titleLabel.text = task.title
            descriptionLabel.text = task.descrip
            guard let dueDate = task.dueDate else {
                timeLabel.text = ""
                return
            }
            timeLabel.text = CalendarHelper.getCustomTimeIntervalDisplay(toDate: dueDate)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.shadowOffset = CGSize(width: 2, height: 2)
        containerView.layer.shadowColor = UIColor.gray.cgColor
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowOpacity = 0.5
    }
    
}
