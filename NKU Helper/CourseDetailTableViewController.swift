//
//  CourseDetailTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/4/7.
//  Copyright (c) 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

class CourseDetailTableViewController: UITableViewController {

    var whichCourse:Int!
    var course:NSDictionary!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let courses:NSArray = userDefaults.objectForKey("courses") as! NSArray
        course = courses.objectAtIndex(whichCourse) as! NSDictionary
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 6
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("courseDetail", forIndexPath: indexPath) 
        
        
        
        switch indexPath.row {
        case 0:
            let classID = course.objectForKey("classID") as! String
            cell.textLabel?.text = "选课序号"
            cell.detailTextLabel?.text = classID
        case 1:
            let classNumber = course.objectForKey("classNumber") as! String
            cell.textLabel?.text = "课程编号"
            cell.detailTextLabel?.text = classNumber
        case 2:
            let className = course.objectForKey("className") as! String
            cell.textLabel?.text = "课程名称"
            cell.detailTextLabel?.text = className
        case 3:
            let classOddEven = course.objectForKey("weekOddEven") as! String
            cell.textLabel?.text = "单双周"
            cell.detailTextLabel?.text = classOddEven
        case 4:
            let classroom = course.objectForKey("classroom") as! String
            cell.textLabel?.text = "教室"
            cell.detailTextLabel?.text = classroom
        default:
            let teacherName = course.objectForKey("teacherName") as! String
            cell.textLabel?.text = "教师姓名"
            cell.detailTextLabel?.text = teacherName
        }
        
        return cell
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
