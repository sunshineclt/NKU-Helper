//
//  TestTimeTableViewCell.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/6/8.
//  Copyright (c) 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

class TestTimeTableViewCell: UITableViewCell {

    @IBOutlet var classNameLabel: UILabel!
    @IBOutlet var startTimeLabel: UILabel!
    @IBOutlet var endTimeLabel: UILabel!
    @IBOutlet var weekdayLabel: UILabel!
    @IBOutlet var classroomLabel: UILabel!
    
    override func awakeFromNib() {
        startTimeLabel.adjustsFontSizeToFitWidth = true
        endTimeLabel.adjustsFontSizeToFitWidth = true
    }
    
}
