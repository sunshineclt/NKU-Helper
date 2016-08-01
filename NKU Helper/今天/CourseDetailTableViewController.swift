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

// MARK: View Property
    let COURSE_INFO_SECTION = 0
    let COURSE_TASK_SECTION = 1
    let COURSE_COLOR_SECTION = 2
    
// MARK: VC状态 property
    
    var nowChoosedColorIndexRow: Int!
    
// MARK: Model
    var courseTime: CourseTime!
    var course: Course {
        return courseTime.ownerCourse
    }
    var colors: Results<Color>!
    var tasks: Results<Task>!
    var tasksNotificationToken: NotificationToken?

// MARK: VC Life Cycle
    
    override func viewDidLoad() {
        // tableViewCell高度自适应
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        // 数据初始化
        do {
            colors = try Color.getColors().filter("liked == true")
            tasks = try Task.getTasksForCourse(course)
            for i in 0..<colors.count {
                if let courseColor = course.color {
                    if courseColor.name == colors[i].name {
                        nowChoosedColorIndexRow = i
                    }
                }
            }
            // 监听Realm事件
            tasksNotificationToken = tasks.addNotificationBlock { [unowned self] (changes: RealmCollectionChange) in
                guard let tableView = self.tableView else { return }
                switch changes {
                case .Initial:
                    // Results are now populated and can be accessed without blocking the UI
                    tableView.reloadData()
                    break
                case .Update(_, let deletions, let insertions, let modifications):
                    // Query results have changed, so apply them to the UITableView
                    tableView.beginUpdates()
                    tableView.insertRowsAtIndexPaths(insertions.map { NSIndexPath(forRow: $0, inSection: 1) },
                        withRowAnimation: .Automatic)
                    tableView.deleteRowsAtIndexPaths(deletions.map { NSIndexPath(forRow: $0, inSection: 1) },
                        withRowAnimation: .Automatic)
                    tableView.reloadRowsAtIndexPaths(modifications.map { NSIndexPath(forRow: $0, inSection: 1) },
                        withRowAnimation: .Automatic)
                    tableView.endUpdates()
                    break
                case .Error(let error):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(error)")
                    break
                }
            }
        } catch {
            presentViewController(ErrorHandler.alert(ErrorHandler.DataBaseError()), animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        do {
            let realm = try Realm()
            try realm.write({
                course.color = colors[nowChoosedColorIndexRow]
            })
        } catch {
        }
    }
    
    deinit {
        tasksNotificationToken?.stop()
    }
    
// MARK: 事件监听
    
    @IBAction func addTaskOfCourse(sender: UIBarButtonItem) {
        performSegueWithIdentifier(R.segue.courseDetailTableViewController.addTask, sender: course)
    }
    
// MARK: 页面间跳转
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let typeInfo = R.segue.courseDetailTableViewController.addTask(segue: segue) {
            let controller = typeInfo.destinationViewController.childViewControllers[0] as! NewTaskTableViewController
            controller.taskType = TaskType.Course
            controller.forCourseTime = courseTime
        }
    }
    
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension CourseDetailTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case COURSE_INFO_SECTION:return "课程信息"
        case COURSE_TASK_SECTION:return "课程任务"
        case COURSE_COLOR_SECTION:return "选择颜色"
        default:return ""
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case COURSE_INFO_SECTION:
            return 4 + 3 * course.courseTimes.count
        case COURSE_TASK_SECTION:
            guard tasks != nil else {
                return 0
            }
            return tasks.count
        case COURSE_COLOR_SECTION:
            guard colors != nil else {
                return 0
            }
            return colors.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == COURSE_INFO_SECTION {
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
                cell.textLabel?.text = "教师姓名"
                cell.detailTextLabel?.text = course.teacherName
            default:
                let index = indexPath.row - 4
                let courseTime = course.courseTimes[index / 3]
                switch index % 3 {
                case 0:
                    cell.textLabel?.text = "课时\(index / 3 + 1)教室"
                    cell.detailTextLabel?.text = courseTime.classroom
                case 1:
                    cell.textLabel?.text = "课时\(index / 3 + 1)上课时间"
                    cell.detailTextLabel?.text = CalendarHelper.getWeekdayStringFromWeekdayInt(courseTime.weekday) + " " + courseTime.weekOddEven + " " + "\(courseTime.startSection)-\(courseTime.endSection)节"
                case 2:
                    cell.textLabel?.text = "课时\(index / 3 + 1)周数"
                    cell.detailTextLabel?.text = "\(courseTime.startWeek)-\(courseTime.endWeek)周"
                default:
                    break
                }
            }
            return cell
        }
        if indexPath.section == COURSE_TASK_SECTION {
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.courseTaskCell.identifier) as! CourseTaskCell
            cell.task = tasks[indexPath.row]
            configureCell(cell, atIndexPath: indexPath, forTask: tasks[indexPath.row])
            return cell
        }
        if indexPath.section == COURSE_COLOR_SECTION {
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.courseColorCell.identifier) as! ColorChooseTableViewCell
            let color = colors[indexPath.row]
            cell.colorView.backgroundColor = color.convertToUIColor()
            cell.accessoryType = indexPath.row == nowChoosedColorIndexRow ? .Checkmark : .None
            return cell
        }
        return UITableViewCell()
    }
    
    private func configureCell(cell: MCSwipeTableViewCell, atIndexPath indexPath: NSIndexPath, forTask task: Task) {
        let checkView = UIImageView(image: R.image.check())
        checkView.contentMode = .Center
        cell.setSwipeGestureWithView(checkView, color: UIColor(red: 85/255, green: 213/255, blue: 80/255, alpha: 1), mode: .Exit, state: .State3) { (cell, state, mode) in
            do {
                try task.toggleDone()
            } catch {
                self.presentViewController(ErrorHandler.alert(ErrorHandler.DataBaseError()), animated: true, completion: nil)
            }
        }
        cell.defaultColor = tableView.backgroundView?.backgroundColor
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == COURSE_COLOR_SECTION {
            let preChoosedColorIndexRow = nowChoosedColorIndexRow
            nowChoosedColorIndexRow = indexPath.row
            self.tableView.reloadRowsAtIndexPaths([indexPath, NSIndexPath(forRow: preChoosedColorIndexRow, inSection: COURSE_COLOR_SECTION)], withRowAnimation: .None)
        }
    }

}
