//
//  ClassModificationTableViewCell.swift
//  NKU Helper
//
//  Created by 陈乐天 on 2/29/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

class ClassModificationTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        selectCourseButton.layer.cornerRadius = (selectCourseButton.frame.width + 20) / 2
        deleteCourseButton.layer.cornerRadius = (deleteCourseButton.frame.width + 20) / 2
    }

    @IBOutlet var selectCourseButton: UIButton!
    @IBOutlet var deleteCourseButton: UIButton!

}
