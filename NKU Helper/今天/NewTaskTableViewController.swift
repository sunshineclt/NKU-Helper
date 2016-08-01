//
//  NewTaskTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/29.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import UIKit

class NewTaskTableViewController: UITableViewController {

    var taskType: TaskType!
    var forCourseTime: CourseTime? {
        didSet {
            if forCourseCell != nil {
                if let courseTime = forCourseTime {
                    forCourseCell.detailTextLabel?.text = courseTime.ownerCourse.name
                } else {
                    forCourseCell.detailTextLabel?.text = "None"
                }
            }
        }
    }
    var dueDate: NSDate? {
        didSet {
            if let date = dueDate {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yy-MM-dd"
                dueDateCell.detailTextLabel?.text = formatter.stringFromDate(date)
            } else {
                dueDateCell.detailTextLabel?.text = "None"
            }
        }
    }
    var color: Color! {
        didSet {
            colorPresentView.backgroundColor = color.convertToUIColor()
        }
    }
    @IBOutlet var titleCell: TextFieldCell!
    @IBOutlet var descriptionCell: TextFieldCell!
    @IBOutlet var forCourseCell: UITableViewCell!
    @IBOutlet var dueDateCell: UITableViewCell!
    @IBOutlet var chooseColorCell: UITableViewCell!
    @IBOutlet var colorPresentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        color = (try! Color.getColors())[0]
        if let courseTime = forCourseTime {
            forCourseCell.detailTextLabel?.text = courseTime.ownerCourse.name
        } else {
            forCourseCell.detailTextLabel?.text = "None"
        }
    }
    
    @IBAction func saveButtonClicked(sender: UIBarButtonItem) {
        do {
            let task: Task
            if let courseTime = forCourseTime {
                task = Task(title: titleCell.textField.text ?? "", descrip: descriptionCell.textField.text ?? "", type: taskType, dueDate: dueDate, forCourse: courseTime.ownerCourse)
            }
            else {
                task = Task(title: titleCell.textField.text ?? "", descrip: descriptionCell.textField.text ?? "", type: taskType, dueDate: dueDate)
            }
            task.color = color
            try task.save()
            self.dismissViewControllerAnimated(true, completion: nil)
        } catch {
            presentViewController(ErrorHandler.alert(ErrorHandler.DataBaseError()), animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonClicked(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}