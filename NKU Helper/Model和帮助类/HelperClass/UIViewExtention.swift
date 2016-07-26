//
//  UIViewExtention.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/16.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import UIKit

extension UIView {
    
    class func loadViewFromNibNamed(name: String) -> UIView {
        let views = NSBundle.mainBundle().loadNibNamed(name, owner: nil, options: nil)
        for view😈 in views {
            if let view = view😈 as? UIView {
                return view
            }
        }
        return UIView()
    }
    
}