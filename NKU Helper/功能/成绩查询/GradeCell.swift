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
    
    fileprivate func getGradeImageWithGrade(_ grade: Double) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 40, height: 40), false, 0)
        let context = UIGraphicsGetCurrentContext()!
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
        context.setFillColor(UIColor(red: CGFloat(red * 0.8 + 0.1), green: CGFloat(green * 0.8 + 0.1), blue: 0.1, alpha: 1).cgColor)
        context.addEllipse(in: CGRect(x: 10, y: 10, width: 20, height: 20));
        context.drawPath(using: .fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return image
        
    }
    
}
