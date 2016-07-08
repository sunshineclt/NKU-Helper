//
//  TodayViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/9/18.
//  Copyright © 2015年 陈乐天. All rights reserved.
//

import UIKit

class TodayViewController: UIViewController {

    // MARK: View Property
    @IBOutlet var courseCountLabel: UILabel!
    @IBOutlet var thingCountLabel: UILabel!
    @IBOutlet var plusCircleView: PlusCircleView! {
        didSet {
            plusCircleView.backgroundColor = UIColor.clearColor()
        }
    }
    @IBOutlet var courseTableView: UITableView! {
        // 设置无课时的显示
        didSet {
            self.courseTableView.emptyDataSetSource = self
            self.courseTableView.emptyDataSetDelegate = self
        }
    }
    @IBOutlet var thingsTableView: UITableView! {
        // 设置无Things时的显示
        didSet {
            self.thingsTableView.emptyDataSetSource = self
            self.thingsTableView.emptyDataSetDelegate = self;
        }
    }
    
    // MARK: Model
    var todayCourse = [Course]()
    var thingsToDo = [ThingToDo]()
    
    // MARK: VCLifeCycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        courseTableView.estimatedRowHeight = 200
        courseTableView.rowHeight = UITableViewAutomaticDimension
        ThingToDo.updateStoredThings()
        thingsToDo = ThingToDo.getThings()
        self.thingsTableView.tableFooterView = UIView()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        newToDo?.becomeFirstResponder()
        self.thingsTableView.reloadData()
        
        do {
            try UserAgent.sharedInstance.getData()
            let courses = try Course.coursesOnWeekday(CalendarHelper.getWeekdayInt())
            todayCourse = courses
            self.courseTableView.reloadData()
        } catch StoragedDataError.NoUserInStorage {
            self.performSegueWithIdentifier(SegueIdentifier.Login, sender: "TodayViewController")
        } catch StoragedDataError.NoClassesInStorage {
            self.presentViewController(ErrorHandler.alert(ErrorHandler.ClassNotExist()), animated: true, completion: nil)
        } catch {
            
        }
        
    }
    
    // MARK: 状态Property
    
    // 是否处在添加Thins的模式
    var isAddThingMode = false
    var newToDo:UITextField?

    // MARK: 事件监听
    
    @IBAction func plusButtonClicked(sender: UIButton) {
        isAddThingMode = true
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.newToDo?.becomeFirstResponder()
        }
        thingsTableView.reloadData()
        CATransaction.commit()
    }
    
    // MARK: 页面间跳转
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case SegueIdentifier.ShowCourseDetail:
                if let destinationVC = segue.destinationViewController as? CourseDetailTableViewController {
                    let senderCell = sender as! CourseCell
                    destinationVC.course = senderCell.course
                }
            default:break
            }
        }
    }
}


// MARK: TableViewDelegate
extension TodayViewController:UITableViewDelegate {
}


// MARK: TableViewDataSource
extension TodayViewController:UITableViewDataSource, CheckBoxClickedDelegate {
    
    /*
     tag = 0代表是course的tableView
     tag = 1代表是things的tableView
     */
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 更新Things列表
        if tableView.tag == 1 {
            thingsToDo = ThingToDo.getThings()
        }
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        courseCountLabel.text = "今天有\(todayCourse.count)节课"
        thingCountLabel.text = "还剩\(ThingToDo.getLeftThingsCount())件事"
        return tableView.tag == 0 ? todayCourse.count : (isAddThingMode ? thingsToDo.count+1 : thingsToDo.count)
    }
    
    func getCourseCell(tableView:UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> CourseCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.CourseCell) as! CourseCell
        cell.course = todayCourse[indexPath.row]
        return cell
    }
    
    func getToDoCell(tableView:UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> ToDoCell {
        let thing = thingsToDo[(isAddThingMode ? indexPath.row-1 : indexPath.row)]
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.ToDoCell) as! ToDoCell
        cell.thing = thing
        cell.nameTextField?.enabled = false
        cell.delegate = self
        return cell
    }

    func getNewToDoCell(tableView:UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> ToDoCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.ToDoCell) as! ToDoCell
        cell.nameTextField.text = ""
        cell.nameTextField.becomeFirstResponder()
        cell.nameTextField.enabled = true
        cell.nameTextField.delegate = self
        cell.checkBoxState = false
        cell.checkBox.image = UIImage(named: "CheckBox.png")
        newToDo = cell.nameTextField
        return cell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView.tag == 0 {
            let cell = getCourseCell(tableView, cellForRowAtIndexPath: indexPath)
            return cell
        } else {
            if isAddThingMode && (indexPath.row == 0) {
                let cell = getNewToDoCell(tableView, cellForRowAtIndexPath: indexPath)
                return cell
            }
            let thing = thingsToDo[(isAddThingMode ? indexPath.row-1 : indexPath.row)]
            switch thing.type {
            case .Normal:
                let cell = getToDoCell(tableView, cellForRowAtIndexPath: indexPath)
                return cell
            }
        }
    }
    
    func saveCheckState(cell: ToDoCell) {
        let indexPath = self.thingsTableView.indexPathForCell(cell)!
        var actualIndexPathRow = isAddThingMode ? indexPath.row - 1 : indexPath.row
        if actualIndexPathRow >= 0 {
            actualIndexPathRow = tableView(thingsTableView, numberOfRowsInSection: 0) - actualIndexPathRow - 1
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let savedThings = (userDefaults.objectForKey("things") as! NSArray)
            var beforeThings = savedThings as! [NSData]
            let thing = NSKeyedUnarchiver.unarchiveObjectWithData(beforeThings[actualIndexPathRow]) as! ThingToDo
            thing.done = cell.checkBoxState
            let data = NSKeyedArchiver.archivedDataWithRootObject(thing)
            beforeThings[actualIndexPathRow] = data
            let thingsToSave:NSArray = beforeThings
            userDefaults.removeObjectForKey("things")
            userDefaults.setObject(thingsToSave, forKey: "things")
            userDefaults.synchronize()
        }
        thingsTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
}

extension TodayViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        if scrollView.tag == 0 {
            return NSAttributedString(string: "今天木有课呢", attributes: [NSForegroundColorAttributeName : UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1), NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 15)!])
        } else {
            return NSAttributedString(string: "暂时木有事情要做", attributes: [NSForegroundColorAttributeName : UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1), NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 15)!])
        }
    }
}

extension TodayViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        isAddThingMode = false
        newToDo = nil
        if textField.text != "" {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let savedThings = (userDefaults.objectForKey("things") as? NSArray) ?? NSArray()
            var beforeThings = savedThings as! [NSData]
            let thing = ThingToDo(name: textField.text ?? "", time: nil, place: nil, type: .Normal)
            let data = NSKeyedArchiver.archivedDataWithRootObject(thing)
            beforeThings.append(data)
            let thingsToSave:NSArray = beforeThings
            userDefaults.removeObjectForKey("things")
            userDefaults.setObject(thingsToSave, forKey: "things")
            userDefaults.synchronize()
        }
        self.thingsTableView.reloadData()
        return true
    }
    
}
