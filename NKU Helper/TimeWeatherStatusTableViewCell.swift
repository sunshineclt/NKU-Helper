//
//  TimeWeatherStatusTableViewCell.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/5/11.
//  Copyright (c) 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

class TimeWeatherStatusTableViewCell: UITableViewCell {
    
    @IBOutlet var weekdayLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var PM25Label: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var weatherConditionLabel: UILabel!
    @IBOutlet var airQualityLabel: UILabel!
    @IBOutlet var weatherImageView: UIImageView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.backgroundColor = UIColor.clearColor()
        
        weatherConditionLabel.adjustsFontSizeToFitWidth = true
        temperatureLabel.adjustsFontSizeToFitWidth = true
        PM25Label.adjustsFontSizeToFitWidth = true
        airQualityLabel.adjustsFontSizeToFitWidth = true
        dateLabel.adjustsFontSizeToFitWidth = true
        
        
    }
}
