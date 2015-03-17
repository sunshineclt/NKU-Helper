//
//  courseCurrentTableViewCell.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/16.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class courseCurrentTableViewCell: UITableViewCell {

    @IBOutlet var courseInfoView: UIView!
    
    
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var currentCourseNameLabel: UILabel!
    @IBOutlet var currentCourseClassroomLabel: UILabel!
    @IBOutlet var currentCourseTeacherNameLabel: UILabel!
    
    @IBOutlet var progressIndicator: UIProgressView!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        statusLabel.adjustsFontSizeToFitWidth = true
        currentCourseNameLabel.adjustsFontSizeToFitWidth = true
        currentCourseClassroomLabel.adjustsFontSizeToFitWidth = true
        currentCourseTeacherNameLabel.adjustsFontSizeToFitWidth = true
        
        self.backgroundColor = UIColor.clearColor()
    }
    
}
