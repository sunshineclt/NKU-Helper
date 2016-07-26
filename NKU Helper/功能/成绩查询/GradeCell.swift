//
//  GradeCell.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/2/16.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class GradeCell: UITableViewCell {

    @IBOutlet var ClassNameLabel: UILabel!
    @IBOutlet var GradeLabel: UILabel!
    @IBOutlet var CreditLabel: UILabel!
    @IBOutlet var gradeImageView: UIImageView!
    
    var grade: Grade! {
        didSet {
            ClassNameLabel.text = grade.className
            GradeLabel.text = grade.gradeString
            CreditLabel.text = grade.creditString
            gradeImageView.image = getGradeImageWithGrade((grade.gradeString as NSString).doubleValue)
        }
    }
    
    private func getGradeImageWithGrade(grade: Double) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 40), false, 0)
        let context = UIGraphicsGetCurrentContext()
        let per = (grade - 60) / 40
        var red: Double = 0, green: Double = 0
        if per < 0.5 {
            red = 1
            green = per / 0.5
        }
        else {
            green = 1
            red = ( 1 - per ) / 0.5
        }
        if per < 0 {
            red = 0
            green = 0
        }
        CGContextSetFillColorWithColor(context, UIColor(red: CGFloat(red * 0.8 + 0.1), green: CGFloat(green * 0.8 + 0.1), blue: 0.1, alpha: 1).CGColor)
        CGContextAddEllipseInRect(context, CGRectMake(10, 10, 20, 20));
        CGContextDrawPath(context, .Fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return image
        
    }
    
}
