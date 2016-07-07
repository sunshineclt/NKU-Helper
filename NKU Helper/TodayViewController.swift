//
//  TodayViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/9/18.
//  Copyright © 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

class TodayViewController: UIViewController {

    // MARK: ViewProperty
    @IBOutlet var courseCountLabel: UILabel!
    @IBOutlet var thingCountLabel: UILabel!
    @IBOutlet var plusCircleView: PlusCircleView! {
        didSet {
            plusCircleView.backgroundColor = UIColor.clearColor()
        }
    }
    @IBOutlet var courseTableView: UITableView! {
        didSet {
            self.courseTableView.emptyDataSetSource = self
            self.courseTableView.emptyDataSetDelegate = self
        }
    }
    @IBOutlet var thingsTableView: UITableView! {
        didSet {
            self.thingsTableView.emptyDataSetSource = self
            self.thingsTableView.emptyDataSetDelegate = self;
        }
    }
    
    // MARK: Model
    var todayCourse = [Course]()
    var thingsToDo = [ThingToDo]()
    
    // MARK: ViewControllerLifeCycle
    override func viewDidLoad() {
        
        courseTableView.estimatedRowHeight = 200
        courseTableView.rowHeight = UITableViewAutomaticDimension
        ThingToDo.updateStoredThings()
        thingsToDo = ThingToDo.getThings()
        self.thingsTableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)

    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        newToDo?.becomeFirstResponder()
        self.thingsTableView.reloadData()
        
        guard UserAgent.sharedInstance.getData() != nil else {
            self.performSegueWithIdentifier(SegueIdentifier.Login, sender: "TodayViewController")
            return
        }
        guard let courses = Course.coursesOnWeekday(CalendarConverter.weekdayInt()) else {
            self.presentViewController(ErrorHandler.alert(ErrorHandler.ClassNotExist()), animated: true, completion: nil)
            return
        }
        todayCourse = courses
        self.courseTableView.reloadData()
    }
    
    var isAddMode = false
    var newToDo:UITextField?

    @IBAction func plusButtonClicked(sender: UIButton) {
        isAddMode = true
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.newToDo?.becomeFirstResponder()
        }
        thingsTableView.reloadData()
        CATransaction.commit()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case SegueIdentifier.ShowCourseDetail:
                if let destinationVC = segue.destinationViewController as? CourseDetailTableViewController {
                    let senderCell = sender as! LeftToDoCell
                    destinationVC.course = senderCell.course
                }
            case SegueIdentifier.CreateAlarmedToDo:
                break;
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView.tag == 1 { thingsToDo = ThingToDo.getThings() }
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        courseCountLabel.text = "还剩\(todayCourse.count)节"
        thingCountLabel.text = "还剩\(ThingToDo.getLeftThingsCount())件事"
        return tableView.tag == 0 ? todayCourse.count : (isAddMode ? thingsToDo.count+1 : thingsToDo.count)
    }
    
    func leftToDo(tableView:UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> LeftToDoCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.LeftToDo) as! LeftToDoCell
        cell.course = todayCourse[indexPath.row]
        return cell
    }
    
    func rightShortToDo(tableView:UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> RightShortToDoCell {
        let thing = thingsToDo[(isAddMode ? indexPath.row-1 : indexPath.row)]
            let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.RightShortToDo) as! RightShortToDoCell
            cell.thing = thing
            cell.nameTextField?.enabled = false
            cell.delegate = self
            return cell
    }
    
    func saveCheckState(cell: RightShortToDoCell) {
        
        let indexPath = self.thingsTableView.indexPathForCell(cell)!
        var actualIndexPathRow = isAddMode ? indexPath.row - 1 : indexPath.row
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
    
    func rightAlarmedToDo(tableView:UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> RightShortToDoCell {
        //let thing = thingsToDo[(isAddMode ? indexPath.row-1 : indexPath.row)]
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.RightShortToDo) as! RightShortToDoCell
        return cell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if tableView.tag == 0 {
            let cell = leftToDo(tableView, cellForRowAtIndexPath: indexPath)
            return cell
        } else {
            if isAddMode && (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.RightShortToDo) as! RightShortToDoCell
                cell.nameTextField.text = ""
                cell.nameTextField.becomeFirstResponder()
                cell.nameTextField.enabled = true
                cell.nameTextField.delegate = self
                cell.checkBoxState = false
                cell.checkBox.image = UIImage(named: "CheckBox.png")
                newToDo = cell.nameTextField
                return cell
            }
            let thing = thingsToDo[(isAddMode ? indexPath.row-1 : indexPath.row)]
            switch thing.type {
            case .Short:
                let cell = rightShortToDo(tableView, cellForRowAtIndexPath: indexPath)
                return cell
            case .Alarmed:
                let cell = rightAlarmedToDo(tableView, cellForRowAtIndexPath: indexPath)
                return cell
            }
        }
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
        isAddMode = false
        newToDo = nil
        if textField.text != "" {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let savedThings = (userDefaults.objectForKey("things") as? NSArray) ?? NSArray()
            var beforeThings = savedThings as! [NSData]
            let thing = ThingToDo(name: textField.text ?? "", time: nil, place: nil, type: .Short)
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
