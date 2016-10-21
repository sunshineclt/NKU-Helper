//
//  TodayViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/28.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import UIKit
import RealmSwift
import BTNavigationDropdownMenu
import Then

class TodayViewController: UIViewController {

// MARK: View Property
    @IBOutlet var headerView: UIView! {
        didSet {
            // 给headerView加阴影
            headerView.layer.shadowOffset = CGSize(width: 1, height: 1)
            headerView.layer.shadowColor = UIColor.gray.cgColor
            headerView.layer.shadowRadius = 2
            headerView.layer.shadowOpacity = 0.2
        }
    }
    @IBOutlet var mainTableView: UITableView!
    @IBOutlet var todayCourseCountLabel: UILabel!
    @IBOutlet var taskCountLabel: UILabel!
    
    var navigationMenuView: BTNavigationDropdownMenu!
    let todayTags = ["今天的课程", "剩下的任务"]
    let TODAY_COURSE_SEGMENT = 0
    let LEFT_TASK_SEGMENT = 1
    
// MARK: VC状态 property
    
    var selectedTodayTagIndex = 0
    
// MARK: Model
    var todayCourses: Results<CourseTime>? {
        didSet {
            self.todayCourseCountLabel.text = "今天有\(self.todayCourses?.count ?? 0)节课"
        }
    }
    var tasks: Results<Task>? {
        didSet {
            self.taskCountLabel.text = "还剩\(self.tasks?.count ?? 0)个任务"
        }
    }
    var realm: Realm?
    var tasksNotificationToken: NotificationToken?
    var coursesNotificationToken: NotificationToken?
    
// MARK: VC Life Cycle
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // tableView最上面稍微空出一点
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 10))
        mainTableView.tableHeaderView = tableHeaderView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        // tableViewCell高度自适应
        mainTableView.estimatedRowHeight = 100
        mainTableView.rowHeight = UITableViewAutomaticDimension
        
        // NavigationBar上导航效果的设置
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 156/255, green: 89/255, blue: 182/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationMenuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: todayTags[selectedTodayTagIndex], items: todayTags as [AnyObject]).then {
            $0.cellHeight = 50
            $0.cellBackgroundColor = self.navigationController?.navigationBar.barTintColor
            $0.cellSelectionColor = UIColor(red: 111/255, green:41/255, blue:139/255, alpha: 1.0)
            $0.shouldKeepSelectedCellColor = true
            $0.cellTextLabelColor = UIColor.white
            $0.cellTextLabelFont = UIFont(name: "HelveticaNeue", size: 17)
            $0.cellTextLabelAlignment = .center
            $0.arrowPadding = 15
            $0.animationDuration = 0.4
            $0.maskBackgroundColor = UIColor.black
            $0.maskBackgroundOpacity = 0.3
            $0.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
                self.selectedTodayTagIndex = indexPath
                self.mainTableView.reloadData()
            }
        }
        self.navigationItem.titleView = navigationMenuView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 数据初始化
        guard let _ = try? UserAgent.sharedInstance.getUserInfo() else {
            self.performSegue(withIdentifier: R.segue.todayViewController.login, sender: "TodayViewController")
            return
        }
        do {
            // 监听Realm事件（主要处理Course相关的事件，Task相关的事件如上单独监听（不知道为何单独监听Course无效））
            if coursesNotificationToken == nil {
                coursesNotificationToken = realm?.addNotificationBlock({ (notification, realm) in
                    if self.selectedTodayTagIndex == self.TODAY_COURSE_SEGMENT {
                        self.mainTableView.reloadData()
                        self.todayCourseCountLabel.text = "今天有\(self.todayCourses?.count ?? 0)节课"
                    }
                })
            }
            if todayCourses == nil {
                todayCourses = try Course.getCourseTimes(onWeekday: CalendarHelper.getWeekdayInt())
                NKNetworkInfoHandler.fetchNowWeek { (nowWeek, isVocation) in
                    guard let nowWeek = nowWeek, let isVocation = isVocation else {
                        return
                    }
                    if isVocation {
                        return
                    }
                    self.todayCourses = nowWeek % 2 == 0 ? self.todayCourses?.filter("!((weekOddEven == '单周') || (\(nowWeek) < startWeek) || (\(nowWeek) > endWeek))") : self.todayCourses?.filter("!((weekOddEven == '双周') || (\(nowWeek) < startWeek) || (\(nowWeek) > endWeek))")
                    self.mainTableView.reloadData()
                }
                self.mainTableView.reloadData()
                self.todayCourseCountLabel.text = "今天有\(self.todayCourses?.count ?? 0)节课"
            }
            if tasks == nil {
                tasks = try Task.getLeftTasks()
                // 监听Realm事件
                tasksNotificationToken = tasks!.addNotificationBlock { [unowned self] (changes: RealmCollectionChange) in
                    guard let tableView = self.mainTableView else { return }
                    if self.selectedTodayTagIndex == self.LEFT_TASK_SEGMENT {
                        switch changes {
                        case .initial:
                            tableView.reloadData()
                            break
                        case .update(_, let deletions, let insertions, let modifications):
                            tableView.beginUpdates()
                            tableView.insertRows(at: insertions.map{ IndexPath(row: $0, section: 0) }, with: .automatic)
                            tableView.deleteRows(at: deletions.map{ IndexPath(row: $0, section: 0) }, with: .automatic)
                            tableView.reloadRows(at: modifications.map{ IndexPath(row: $0, section: 0) }, with: .automatic)
                            tableView.endUpdates()
                            break
                        case .error(let error):
                            fatalError("\(error)")
                            break
                        }
                    }
                    self.taskCountLabel.text = "还剩\(self.tasks?.count ?? 0)个任务"
                }
            }
        } catch StoragedDataError.noCoursesInStorage {
            self.present(ErrorHandler.alert(withError: ErrorHandler.CoursesNotExist()), animated: true, completion: nil)
        } catch StoragedDataError.realmError {
            self.present(ErrorHandler.alert(withError: ErrorHandler.DataBaseError()), animated: true, completion: nil)
        } catch {
            
        }
    }
    
    deinit {
        tasksNotificationToken?.stop()
        coursesNotificationToken?.stop()
    }
    
// MARK: 事件监听
    
    @IBAction func addTaskOfCourse(_ sender: UIButton) {
        let courseTime = (sender.superview!.superview!.superview as! TodayCourseCell).courseTime
        performSegue(withIdentifier: R.segue.todayViewController.addTask, sender: courseTime)
    }
    
// MARK: 页面间跳转
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.hidesBottomBarWhenPushed = true
        if let typeInfo = R.segue.todayViewController.showCourseDetail(segue: segue) {
            let senderCell = sender as! TodayCourseCell
            typeInfo.destination.courseTime = senderCell.courseTime
        }
        if let typeInfo = R.segue.todayViewController.addTask(segue: segue) {
            let controller = typeInfo.destination.childViewControllers[0] as! NewTaskTableViewController
            if let courseTime = sender as? CourseTime {
                controller.taskType = TaskType.course
                controller.forCourseTime = courseTime
            } else {
                controller.taskType = TaskType.general
            }
        }
    }
    
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension TodayViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedTodayTagIndex {
        case TODAY_COURSE_SEGMENT:
            guard let count = todayCourses?.count else {
                return 0
            }
            return count
        case LEFT_TASK_SEGMENT:
            guard let count = tasks?.count else {
                return 0
            }
            return count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch selectedTodayTagIndex {
        case TODAY_COURSE_SEGMENT:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.todayCourseCell.identifier) as! TodayCourseCell
            cell.courseTime = todayCourses![indexPath.row]
            return cell
        case LEFT_TASK_SEGMENT:
            let task = tasks![indexPath.row]
            switch task.type {
            case .course:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.courseTaskCell.identifier) as! CourseTaskCell
                cell.task = task
                configureCell(cell, atIndexPath: indexPath, forTask: task)
                return cell
            case .general:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.generalTaskCell.identifier) as! GeneralTaskCell
                cell.task = task
                configureCell(cell, atIndexPath: indexPath, forTask: task)
                return cell
            }
        default:
            return UITableViewCell()
        }

    }
    
    fileprivate func configureCell(_ cell: MCSwipeTableViewCell, atIndexPath indexPath: IndexPath, forTask task: Task) {
        let checkView = UIImageView(image: R.image.check())
        checkView.contentMode = .center
        cell.setSwipeGestureWith(checkView, color: UIColor(red: 85/255, green: 213/255, blue: 80/255, alpha: 1), mode: .exit, state: .state3) { (cell, state, mode) in
            do {
                try task.toggleDone()
            } catch {
                self.present(ErrorHandler.alert(withError: ErrorHandler.DataBaseError()), animated: true, completion: nil)
            }
        }
        cell.defaultColor = mainTableView.backgroundView?.backgroundColor
    }
    
}

// MARK: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
extension TodayViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        switch selectedTodayTagIndex {
        case TODAY_COURSE_SEGMENT:
            return NSAttributedString(string: "今天没有课呢╭(′▽`)╯", attributes: [NSForegroundColorAttributeName : UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1), NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 15)!])
        case LEFT_TASK_SEGMENT:
            return NSAttributedString(string: "任务都完成了呢╰(￣▽￣)╮", attributes: [NSForegroundColorAttributeName : UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1), NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 15)!])
        default:
            return NSAttributedString(string: "今天什么事情都没有呢(╯▽╰)", attributes: [NSForegroundColorAttributeName : UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1), NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 15)!])
        }
    }
}
