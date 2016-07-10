//
//  CourseDetailTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/4/7.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class CourseDetailTableViewController: UITableViewController {

    var whichCourse:Int!
    var course:Course!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        if whichCourse != nil {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let courses = userDefaults.objectForKey("courses") as! [NSData]
            let courseData = courses[whichCourse]
            course = NSKeyedUnarchiver.unarchiveObjectWithData(courseData) as! Course
        }

    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("courseDetail", forIndexPath: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "选课序号"
            cell.detailTextLabel?.text = course.ID
        case 1:
            cell.textLabel?.text = "课程编号"
            cell.detailTextLabel?.text = course.number
        case 2:
            cell.textLabel?.text = "课程名称"
            cell.detailTextLabel?.text = course.name
        case 3:
            cell.textLabel?.text = "单双周"
            cell.detailTextLabel?.text = course.weekOddEven
        case 4:
            cell.textLabel?.text = "教室"
            cell.detailTextLabel?.text = course.classroom
        default:
            cell.textLabel?.text = "教师姓名"
            cell.detailTextLabel?.text = course.teacherName
        }
        
        return cell
    }
    
}
