//
//  NewTodayViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/28.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import UIKit
import RealmSwift
import BTNavigationDropdownMenu

class NewTodayViewController: UIViewController {

// MARK: View Property
    @IBOutlet var headerView: UIView!
    @IBOutlet var mainTableView: UITableView!
    @IBOutlet var todayCourseCountLabel: UILabel!
    @IBOutlet var thingToDoCountLabel: UILabel!
    
    var navigationMenuView: BTNavigationDropdownMenu!
    let todayTags = ["今天", "今天的课程", "剩下的任务"]
    let TODAY_SEGMENT = 0
    let TODAY_COURSE_SEGMENT = 1
    let LEFT_TASK_SEGMENT = 2
    
// MARK: VC状态 property
    
    var selectedTodayTagIndex = 0
    
// MARK: Model
    var todayCourses: Results<CourseTime>?
    var thingsToDo: Results<Task>?
    var realm: Realm?
    var tasksNotificationToken: NotificationToken?
    var realmNotificationToken: NotificationToken?
    
// MARK: VC Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 给headerView加阴影
        headerView.layer.shadowOffset = CGSizeMake(1, 1)
        headerView.layer.shadowColor = UIColor.grayColor().CGColor
        headerView.layer.shadowRadius = 2
        headerView.layer.shadowOpacity = 0.2
        
        // tableViewCell高度自适应
        mainTableView.estimatedRowHeight = 100
        mainTableView.rowHeight = UITableViewAutomaticDimension
        
        // NavigationBar上导航效果的设置
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 156/255, green: 89/255, blue: 182/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationMenuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: todayTags[selectedTodayTagIndex], items: todayTags)
        navigationMenuView.cellHeight = 50
        navigationMenuView.cellBackgroundColor = self.navigationController?.navigationBar.barTintColor
        navigationMenuView.cellSelectionColor = UIColor(red: 111/255, green:41/255, blue:139/255, alpha: 1.0)
        navigationMenuView.keepSelectedCellColor = true
        navigationMenuView.cellTextLabelColor = UIColor.whiteColor()
        navigationMenuView.cellTextLabelFont = UIFont(name: "HelveticaNeue", size: 17)
        navigationMenuView.cellTextLabelAlignment = .Center
        navigationMenuView.arrowPadding = 15
        navigationMenuView.animationDuration = 0.5
        navigationMenuView.maskBackgroundColor = UIColor.blackColor()
        navigationMenuView.maskBackgroundOpacity = 0.3
        navigationMenuView.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
            self.selectedTodayTagIndex = indexPath
            self.mainTableView.reloadData()
        }
        self.navigationItem.titleView = navigationMenuView
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // tableView最上面稍微空出一点
        let headerView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 10))
        mainTableView.tableHeaderView = headerView
        // 数据初始化
        do {
            try UserAgent.sharedInstance.getData()
            if todayCourses == nil {
                todayCourses = try Course.coursesOnWeekday(CalendarHelper.getWeekdayInt())
                NKNetworkFetchInfo.fetchNowWeek { (nowWeek😈, isVocation😈) in
                    guard let nowWeek = nowWeek😈, isVocation = isVocation😈 else {
                        return
                    }
                    if isVocation {
                        return
                    }
                    self.todayCourses = nowWeek % 2 == 0 ? self.todayCourses?.filter("!((weekOddEven == '单周') || (\(nowWeek) < startWeek) || (\(nowWeek) > endWeek))") : self.todayCourses?.filter("!((weekOddEven == '双周') || (\(nowWeek) < startWeek) || (\(nowWeek) > endWeek))")
                    self.todayCourseCountLabel.text = "今天有\(self.todayCourses?.count ?? 0)节课"
                }
                self.todayCourseCountLabel.text = "今天有\(self.todayCourses?.count ?? 0)节课"
            }
            if thingsToDo == nil {
                thingsToDo = try Task.getLeftTasks()
                self.thingToDoCountLabel.text = "还剩\(self.thingsToDo?.count ?? 0)个任务"
                // 监听Realm事件
                tasksNotificationToken = thingsToDo!.addNotificationBlock { [unowned self] (changes: RealmCollectionChange) in
                    guard let tableView = self.mainTableView else { return }
                    if self.selectedTodayTagIndex == self.LEFT_TASK_SEGMENT {
                        switch changes {
                        case .Initial:
                            // Results are now populated and can be accessed without blocking the UI
                            tableView.reloadData()
                            break
                        case .Update(_, let deletions, let insertions, let modifications):
                            // Query results have changed, so apply them to the UITableView
                            tableView.beginUpdates()
                            tableView.insertRowsAtIndexPaths(insertions.map { NSIndexPath(forRow: $0, inSection: 0) },
                                withRowAnimation: .Automatic)
                            tableView.deleteRowsAtIndexPaths(deletions.map { NSIndexPath(forRow: $0, inSection: 0) },
                                withRowAnimation: .Automatic)
                            tableView.reloadRowsAtIndexPaths(modifications.map { NSIndexPath(forRow: $0, inSection: 0) },
                                withRowAnimation: .Automatic)
                            tableView.endUpdates()
                            break
                        case .Error(let error):
                            // An error occurred while opening the Realm file on the background worker thread
                            fatalError("\(error)")
                            break
                        }
                    }
                    self.thingToDoCountLabel.text = "还剩\(self.thingsToDo?.count ?? 0)个任务"
                }
            }
            // 监听Realm事件（主要处理Course相关的事件，Task相关的事件如上单独监听（不知道为何Course监听无效））
            realm = try Realm()
            realmNotificationToken = realm?.addNotificationBlock({ (notification, realm) in
                if self.selectedTodayTagIndex == self.TODAY_COURSE_SEGMENT {
                    self.mainTableView.reloadData()
                    self.todayCourseCountLabel.text = "今天有\(self.todayCourses?.count ?? 0)节课"
                }
            })
        } catch StoragedDataError.NoUserInStorage {
            self.performSegueWithIdentifier(R.segue.newTodayViewController.login, sender: "TodayViewController")
        } catch StoragedDataError.NoCoursesInStorage {
            self.presentViewController(ErrorHandler.alert(ErrorHandler.CoursesNotExist()), animated: true, completion: nil)
        } catch StoragedDataError.RealmError {
            self.presentViewController(ErrorHandler.alert(ErrorHandler.DataBaseError()), animated: true, completion: nil)
        } catch {
            
        }
    }
    
    deinit {
        tasksNotificationToken?.stop()
        realmNotificationToken?.stop()
    }
    
// MARK: 事件监听
    
    @IBAction func addTaskOfCourse(sender: UIButton) {
        let courseTime = (sender.superview!.superview!.superview as! TodayCourseCell).courseTime
        performSegueWithIdentifier(R.segue.newTodayViewController.addTask, sender: courseTime)
    }
    
// MARK: 页面间跳转
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let typeInfo = R.segue.newTodayViewController.showCourseDetail(segue: segue) {
            let senderCell = sender as! TodayCourseCell
            typeInfo.destinationViewController.courseTime = senderCell.courseTime
        }
        if let typeInfo = R.segue.newTodayViewController.addTask(segue: segue) {
            let controller = typeInfo.destinationViewController.childViewControllers[0] as! NewTaskTableViewController
            if let courseTime = sender as? CourseTime {
                controller.thingType = TaskType.Course
                controller.forCourseTime = courseTime
            } else {
                controller.thingType = TaskType.General
            }
        }
    }
    
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension NewTodayViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedTodayTagIndex {
        case TODAY_SEGMENT:
            return 0
        case TODAY_COURSE_SEGMENT:
            guard let count = todayCourses?.count else {
                return 0
            }
            return count
        case LEFT_TASK_SEGMENT:
            guard let count = thingsToDo?.count else {
                return 0
            }
            return count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch selectedTodayTagIndex {
        case TODAY_SEGMENT:
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.courseTaskCell.identifier) as! CourseTaskCell
            return cell
        case TODAY_COURSE_SEGMENT:
            let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.todayCourseCell.identifier) as! TodayCourseCell
            cell.courseTime = todayCourses![indexPath.row]
            return cell
        case LEFT_TASK_SEGMENT:
            let thing = thingsToDo![indexPath.row]
            switch thing.type {
            case .Course:
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.courseTaskCell.identifier) as! CourseTaskCell
                cell.task = thing
                configureCell(cell, atIndexPath: indexPath, forTask: thing)
                return cell
            case .General:
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.generalTaskCell.identifier) as! GeneralTaskCell
                cell.task = thing
                configureCell(cell, atIndexPath: indexPath, forTask: thing)
                return cell
            }
        default:
            return UITableViewCell()
        }

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
        cell.defaultColor = mainTableView.backgroundView?.backgroundColor
    }
    
}

// MARK: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
extension NewTodayViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        switch selectedTodayTagIndex {
        case 0:
            return NSAttributedString(string: "今天什么事情都没有呢(╯▽╰)", attributes: [NSForegroundColorAttributeName : UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1), NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 15)!])
        case 1:
            return NSAttributedString(string: "今天没有课呢╭(′▽`)╯", attributes: [NSForegroundColorAttributeName : UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1), NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 15)!])
        case 2:
            return NSAttributedString(string: "今天事情都做完了呢╰(￣▽￣)╮", attributes: [NSForegroundColorAttributeName : UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1), NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 15)!])
        default:
            return NSAttributedString(string: "今天什么事情都没有呢(╯▽╰)", attributes: [NSForegroundColorAttributeName : UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1), NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 15)!])
        }
    }
}