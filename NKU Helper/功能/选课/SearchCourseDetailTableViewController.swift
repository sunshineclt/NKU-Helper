//
//  SearchCourseDetailTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 2/29/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import UIKit

class SearchCourseDetailTableViewController: UITableViewController {

    var courseSelecting: CourseSelecting!
    var courseHelper = NKNetworkSelectCourse()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func selectCourse(sender: UIButton) {
        courseHelper.selectCourseWithCourseIndex(courseSelecting.ID) { (result) -> Void in
            print(result)
        }
    }
    
    @IBAction func deleteCourse(sender: UIButton) {
        courseHelper.deleteCourseWithCourseIndex(courseSelecting.ID) { (result) -> Void in
            print(result)
        }
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 11
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row >= 10 {
            return 150
        }
        else {
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard indexPath.row < 10 else {
            let cell = tableView.dequeueReusableCellWithIdentifier("classModification", forIndexPath: indexPath)
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("classDetailInfo", forIndexPath: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "选课序号"
            cell.detailTextLabel?.text = courseSelecting.ID
        case 1:
            cell.textLabel?.text = "课程名称"
            cell.detailTextLabel?.text = courseSelecting.name
        case 2:
            cell.textLabel?.text = "课程类型"
            cell.detailTextLabel?.text = courseSelecting.classType.rawValue
        case 3:
            cell.textLabel?.text = "人数限制"
            cell.detailTextLabel?.text = "\(courseSelecting.number)"
        case 4:
            cell.textLabel?.text = "教师姓名"
            cell.detailTextLabel?.text = courseSelecting.teacherName
        case 5:
            cell.textLabel?.text = "授课方式"
            cell.detailTextLabel?.text = courseSelecting.teachingMethod
        case 6:
            cell.textLabel?.text = "开课时间"
            cell.detailTextLabel?.text = "周\(courseSelecting.weekday) " + courseSelecting.time + "节"
        case 7:
            cell.textLabel?.text = "起止周次"
            cell.detailTextLabel?.text = courseSelecting.startEndWeek
        case 8:
            cell.textLabel?.text = "教室名称"
            cell.detailTextLabel?.text = courseSelecting.classroom
        case 9:
            cell.textLabel?.text = "开课单位"
            cell.detailTextLabel?.text = courseSelecting.depart
        default:
            break
        }
        return cell
    }

}
