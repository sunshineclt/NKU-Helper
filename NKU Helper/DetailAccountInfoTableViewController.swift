//
//  DetailAccountInfoTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/6.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class DetailAccountInfoTableViewController: UITableViewController {

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        }
        else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("accountInfo")!
            let userInfo = UserDetailInfoAgent.sharedInstance.getData()!
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "姓名"
                cell.detailTextLabel?.text = userInfo.Name
            case 1:
                cell.textLabel?.text = "学号"
                cell.detailTextLabel?.text = userInfo.UserID
            case 2:
                cell.textLabel?.text = "入学时间"
                cell.detailTextLabel?.text = userInfo.TimeEnteringSchool
            case 3:
                cell.textLabel?.text = "所在院系"
                cell.detailTextLabel?.text = userInfo.DepartmentAdmitted
            case 4:
                cell.textLabel?.text = "所在专业"
                cell.detailTextLabel?.text = userInfo.MajorAdmitted
            default:
                break
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("logOut")!
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

}
