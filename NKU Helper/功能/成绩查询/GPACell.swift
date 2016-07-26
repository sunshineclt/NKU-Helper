//
//  GPACell.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/18.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import UIKit

class GPACell: UITableViewCell {

    @IBOutlet var ClassNameLabel: UILabel!
    @IBOutlet var GradeLabel: UILabel!
    @IBOutlet var gradeImageView: UIImageView!
    
    var GPAName: String! {
        didSet {
            ClassNameLabel.text = GPAName
        }
    }
    var GPASum: Double!
    var GPA: Double! {
        didSet {
            GradeLabel.text = NSString(format: "%.2lf", GPA) as String
            gradeImageView.image = getGradeImageWithGrade(GPA)
        }
    }

    private func getGradeImageWithGrade(grade: Double) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 40), false, 0)
        let context = UIGraphicsGetCurrentContext()
        let per = (grade - 1) / (GPASum - 1)
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
