//
//  TodayViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/9/18.
//  Copyright © 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

class TodayViewController: UIViewController {

    @IBOutlet var courseCountLabel: UILabel!
    @IBOutlet var thingCountLabel: UILabel!
    @IBOutlet var plusCircleView: PlusCircleView! {
        didSet {
            plusCircleView.backgroundColor = UIColor.clearColor()
        }
    }
    
    @IBOutlet var todayTableView: UITableView!
    
    var todayCourse = [Course]()
    
    override func viewDidLoad() {
        
        todayTableView.estimatedRowHeight = 200
        todayTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        todayCourse = Course.coursesOnWeekday(CalendarConverter.weekdayInt())

        self.todayTableView.reloadData()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let accountInfo = userDefaults.objectForKey("accountInfo") as? NSDictionary
        if accountInfo == nil {
            self.performSegueWithIdentifier(SegueIdentifier.Login, sender: nil)
        }
        if todayCourse.isEmpty {
            let alertView = UIAlertController(title: ErrorHandler.ClassNotExist.title, message: ErrorHandler.ClassNotExist.message, preferredStyle: .Alert)
            let cancel = UIAlertAction(title: ErrorHandler.ClassNotExist.cancelButtonTitle, style: .Cancel, handler: nil)
            alertView.addAction(cancel)
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case SegueIdentifier.ShowCourseDetail:
                if let destinationVC = segue.destinationViewController as? CourseDetailTableViewController {
                    let senderCell = sender as! LeftToDoCell
                    destinationVC.course = senderCell.course
                }
            default:break
            }
        }
    }
}


// MARK: TableViewDelegate
extension TodayViewController:UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}


// MARK: TableViewDataSource
extension TodayViewController:UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        courseCountLabel.text = "还剩\(todayCourse.count)节"
        return todayCourse.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.LeftToDo) as! LeftToDoCell
        cell.course = todayCourse[indexPath.row]
        
        return cell
        
    }
}
