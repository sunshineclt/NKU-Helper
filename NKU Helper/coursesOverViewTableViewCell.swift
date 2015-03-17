//
//  coursesOverViewTableViewCell.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/17.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class coursesOverViewTableViewCell: UITableViewCell {

    @IBOutlet var classNameLabel: UILabel!
    @IBOutlet var classroomLabel: UILabel!
    @IBOutlet var teacherNameLabel: UILabel!
    @IBOutlet var startSectionLabel: UILabel!
    @IBOutlet var endSectionLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.orangeColor()
        
        classNameLabel.adjustsFontSizeToFitWidth = true
        classroomLabel.adjustsFontSizeToFitWidth = true
        teacherNameLabel.adjustsFontSizeToFitWidth = true
        startSectionLabel.adjustsFontSizeToFitWidth = true
        endSectionLabel.adjustsFontSizeToFitWidth = true
        
        self.backgroundColor = UIColor.clearColor()
        var backgroundView:UIView = UIView(frame: CGRectMake(0, 0, 320, 150))
        backgroundView.backgroundColor = UIColor.clearColor()
        self.backgroundView = backgroundView
        
    }
    
}
