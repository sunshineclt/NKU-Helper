//
//  SelectCourseTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/9/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

class SelectCourseTableViewController: UITableViewController {

    @IBAction func selectCourse(sender: UIButton) {
        
        NKNetworkSelectCourse().selectCourseWithCourseIndex(CourseIndex.text ?? "") { (result) -> Void in
            switch result {
            case .Fail:fallthrough
            case .InputError:fallthrough
            case .AlreadySelected:fallthrough
            case .LackOfNumber:fallthrough
            case .NotAssignedGrade:fallthrough
            case .TimeConflict:
                self.presentViewController(ErrorHandler.alert(ErrorHandler.SelectCourseFail()), animated: true, completion: nil)
            case .Success:
                self.CourseIndex.text = "选课成功"
            }
        }
        
    }
    
    
    @IBAction func searchCourse(sender: UIButton) {
    }
    
    @IBOutlet var CourseIndex: UITextField!
    @IBOutlet var CourseName: UITextField!
}
