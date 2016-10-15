//
//  UIViewExtention.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/16.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import UIKit

extension UIView {
    
    /// 从Nib中根据名称加载UIView
    ///
    /// - parameter name: Nib的名称
    ///
    /// - returns: Nib中包含的根UIView，若没有找到则返回nil
    class func loadViewFromNib(named name: String) -> UIView? {
        let views = Bundle.main.loadNibNamed(name, owner: nil, options: nil)!
        for view in views {
            if let view = view as? UIView {
                return view
            }
        }
        return nil
    }
    
}
