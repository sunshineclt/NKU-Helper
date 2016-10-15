//
//  ClassToEvaluateTableViewCell.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/21/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import UIKit

class ClassToEvaluateTableViewCell: UITableViewCell {

    var courseToEvaluate: CourseToEvaluate! {
        didSet {
            self.classNameAndTeacherNameLabel.text = courseToEvaluate.className + " - " + courseToEvaluate.teacherName
            self.hasEvaluatedImageView.image = courseToEvaluate.hasEvaluated ? R.image.classEvaluated() : R.image.classNotEvaluated()
        }
    }
    
    @IBOutlet var classNameAndTeacherNameLabel: UILabel!
    @IBOutlet var hasEvaluatedImageView: UIImageView!
    
}
