//
//  WeekdayView.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/16.
//  Copyright © 2016年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

class WeekdayView: UIView {

    @IBOutlet var weekdayLabel: UILabel!
    
    class func loadFromNib() -> WeekdayView {
        return super.loadViewFromNibNamed("WeekdayView") as! WeekdayView
    }

}
