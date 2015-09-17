//
//  DetailAccountInfoTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/6.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class DetailAccountInfoTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0 {
            return 5
        }
        else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("accountInfo")!
            let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let accountInfo:NSDictionary = userDefaults.objectForKey("accountInfo") as! NSDictionary
            switch indexPath.row {
            case 0:cell.textLabel?.text = "姓名"
                cell.detailTextLabel?.text = accountInfo.objectForKey("name") as? String
            case 1:cell.textLabel?.text = "学号"
            cell.detailTextLabel?.text = accountInfo.objectForKey("userID") as? String
            case 2:cell.textLabel?.text = "入学时间"
            cell.detailTextLabel?.text = accountInfo.objectForKey("timeEnteringSchool") as? String
            case 3:cell.textLabel?.text = "所在院系"
            cell.detailTextLabel?.text = accountInfo.objectForKey("departmentAdmitted") as? String
            case 4:cell.textLabel?.text = "所在专业"
            cell.detailTextLabel?.text = accountInfo.objectForKey("majorAdmitted") as? String
            default:cell.textLabel?.text = "???"
            }
            return cell
        }
        else {
            let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("logOut")!
            return cell
        }

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.removeObjectForKey("accountInfo")
            userDefaults.removeObjectForKey("courses")
            userDefaults.removeObjectForKey("courseStatus")
            userDefaults.synchronize()
            navigationController?.popToRootViewControllerAnimated(true)
        }
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
