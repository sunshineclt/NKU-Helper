//
//  LeftToDoCell.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/9/18.
//  Copyright © 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

class LeftToDoCell: UITableViewCell {

    @IBOutlet var title: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var placeLabel: UILabel!

    var course:Course! {
        didSet {
            title.text = course.name
            placeLabel.text = course.classroom
            timeLabel.text = "第\(course.startSection)节到第\(course.endSection)节"
        }
    }
    
    override func awakeFromNib() {
        title.adjustsFontSizeToFitWidth = true
        timeLabel.adjustsFontSizeToFitWidth = true
        placeLabel.adjustsFontSizeToFitWidth = true

    }
  
}

