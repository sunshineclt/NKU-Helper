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
        return courseTime.forCourse!
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
            colors = try Color.getAllColors().filter("liked == true")
            tasks = try Task.getTasks(forCourse: course)
            // 找到目前选择的颜色并保存在nowChoosedColorIndexRow中
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
                case .initial:
                    tableView.reloadData()
                    break
                case .update(_, let deletions, let insertions, let modifications):
                    tableView.beginUpdates()
                    tableView.insertRows(at: insertions.map{ IndexPath(row: $0, section: 1) }, with: .automatic)
                    tableView.deleteRows(at: deletions.map{ IndexPath(row: $0, section: 1) }, with: .automatic)
                    tableView.reloadRows(at: modifications.map{ IndexPath(row: $0, section: 1) }, with: .automatic)
                    tableView.endUpdates()
                    break
                case .error(let error):
                    fatalError("\(error)")
                    break
                }
            }
        } catch {
            present(ErrorHandler.alert(withError: ErrorHandler.DataBaseError()), animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
    
    @IBAction func addTaskOfCourse(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: R.segue.courseDetailTableViewController.addTask, sender: course)
    }
    
// MARK: 页面间跳转
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typeInfo = R.segue.courseDetailTableViewController.addTask(segue: segue) {
            let controller = typeInfo.destination.childViewControllers[0] as! NewTaskTableViewController
            controller.taskType = TaskType.course
            controller.forCourseTime = courseTime
        }
    }
    
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension CourseDetailTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case COURSE_INFO_SECTION:return "课程信息"
        case COURSE_TASK_SECTION:return "课程任务"
        case COURSE_COLOR_SECTION:return "选择颜色"
        default:return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == COURSE_INFO_SECTION {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.courseDetailCell.identifier, for: indexPath)
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
                    cell.detailTextLabel?.text = CalendarHelper.getWeekdayString(fromWeekday: courseTime.weekday) + " " + courseTime.weekOddEven + " " + "\(courseTime.startSection)-\(courseTime.endSection)节"
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
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.courseTaskCell.identifier) as! CourseTaskCell
            cell.task = tasks[indexPath.row]
            configureCell(cell, atIndexPath: indexPath, forTask: tasks[indexPath.row])
            return cell
        }
        if indexPath.section == COURSE_COLOR_SECTION {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.courseColorCell.identifier) as! ColorChooseTableViewCell
            let color = colors[indexPath.row]
            cell.colorView.backgroundColor = color.convertToUIColor()
            cell.accessoryType = indexPath.row == nowChoosedColorIndexRow ? .checkmark : .none
            return cell
        }
        return UITableViewCell()
    }
    
    private func configureCell(_ cell: MCSwipeTableViewCell, atIndexPath indexPath: IndexPath, forTask task: Task) {
        let checkView = UIImageView(image: R.image.check())
        checkView.contentMode = .center
        cell.setSwipeGestureWith(checkView, color: UIColor(red: 85/255, green: 213/255, blue: 80/255, alpha: 1), mode: .exit, state: .state3) { (cell, state, mode) in
            do {
                try task.toggleDone()
            } catch {
                self.present(ErrorHandler.alert(withError: ErrorHandler.DataBaseError()), animated: true, completion: nil)
            }
        }
        cell.defaultColor = tableView.backgroundView?.backgroundColor
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == COURSE_COLOR_SECTION {
            let preChoosedColorIndexRow = nowChoosedColorIndexRow
            nowChoosedColorIndexRow = indexPath.row
            self.tableView.reloadRows(at: [indexPath, IndexPath(row: preChoosedColorIndexRow!, section: COURSE_COLOR_SECTION)], with: .none)
        }
    }

}
