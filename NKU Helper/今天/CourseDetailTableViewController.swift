//
//  CourseDetailTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/4/7.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit
import RealmSwift

class CourseDetailTableViewController: UITableViewController {

    var course:Course!

    var colors: Results<Color>!
    
    override func viewDidLoad() {
        do {
            colors = try Color.getColors().filter("liked == true")
        } catch {
            presentViewController(ErrorHandler.alert(ErrorHandler.DataBaseError()), animated: true, completion: nil)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "课程信息" : "选择颜色"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 1 else {
            return 6
        }
        guard colors != nil else {
            return 0
        }
        return colors.count
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.section == 1 ? 60 : 44
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.courseDetailCell.identifier, forIndexPath: indexPath)
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
            case 5:
                cell.textLabel?.text = "教师姓名"
                cell.detailTextLabel?.text = course.teacherName
            default:
                break
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.courseColorCell.identifier) as! ColorChooseTableViewCell
            let color = colors[indexPath.row]
            cell.colorView.backgroundColor = color.convertToUIColor()
            cell.accessoryType = .None
            if let courseColor = course.color {
                if courseColor.name == color.name {
                    cell.accessoryType = .Checkmark
                }
            }
            return cell
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            do {
                let realm = try Realm()
                let sameIDCourses = realm.objects(Course.self).filter("ID == '\(course.ID)'")
                try realm.write({
                    course.color = colors[indexPath.row]
                    for sameIDCourse in sameIDCourses {
                        sameIDCourse.color = colors[indexPath.row]
                    }
                    self.tableView.reloadData()
                })
            } catch {
                
            }
        }
    }
    
}
