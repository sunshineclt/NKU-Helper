//
//  UIViewExtention.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/16.
//  Copyright © 2016年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

extension UIView {
    
    class func loadViewFromNibNamed(name: String) -> UIView {
        return NSBundle.mainBundle().loadNibNamed(name, owner: nil, options: nil).last as! UIView
    }
    
}