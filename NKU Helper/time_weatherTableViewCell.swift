//
//  time_weatherTableViewCell.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/16.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class time_weatherTableViewCell: UITableViewCell {

    @IBOutlet var dateView: UIView!
    @IBOutlet var weatherDetailView: UIView!
    @IBOutlet var weatherConditionView: UIView!
    
    @IBOutlet var weekdayLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var PM25Label: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var weatherConditionLabel: UILabel!
    @IBOutlet var airQualityLabel: UILabel!
    
    @IBOutlet var weatherImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        weatherConditionLabel.adjustsFontSizeToFitWidth = true
        temperatureLabel.adjustsFontSizeToFitWidth = true
        PM25Label.adjustsFontSizeToFitWidth = true
        
        self.backgroundColor = UIColor.clearColor()
    }
}
