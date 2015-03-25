//
//  LifeIndexTableViewCell.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/24.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class LifeIndexTableViewCell: UITableViewCell {

    @IBOutlet var mainScrollView: UIScrollView!
    @IBOutlet var pageController: UIPageControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clearColor()
        
        self.backgroundColor = UIColor(white: 1, alpha: 0.1)

    }
    
}
