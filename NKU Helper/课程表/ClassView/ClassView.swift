//
//  ClassView.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/17.
//  Copyright © 2016年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

class ClassView: UIView {
    
    @IBOutlet var classNameLabel: UILabel!
    @IBOutlet var classroomLabel: UILabel!
    
    class func loadFromNib() -> ClassView {
        return super.loadViewFromNibNamed("ClassView") as! ClassView
    }

}
