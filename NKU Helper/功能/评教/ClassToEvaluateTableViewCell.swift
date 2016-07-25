//
//  ClassToEvaluateTableViewCell.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/21/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import UIKit

class ClassToEvaluateTableViewCell: UITableViewCell {

    var classToEvaluate: ClassToEvaluate! {
        didSet {
            self.classNameAndTeacherNameLabel.text = classToEvaluate.className + " - " + classToEvaluate.teacherName
            self.hasEvaluatedImageView.image = classToEvaluate.hasEvaluated ? R.image.classEvaluated() : R.image.classNotEvaluated()
        }
    }
    
    @IBOutlet var classNameAndTeacherNameLabel: UILabel!
    @IBOutlet var hasEvaluatedImageView: UIImageView!
    
}
