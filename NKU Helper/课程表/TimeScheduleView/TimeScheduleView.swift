//
//  TimeScheduleView.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/16.
//  Copyright © 2016年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

class TimeScheduleView: UIView {

    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var sectionLabel: UILabel!
    
    class func loadFromNib() -> TimeScheduleView {
        return super.loadViewFromNibNamed("TimeScheduleView") as! TimeScheduleView
    }

}
