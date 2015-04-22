//
//  SettingTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/1.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
        case 0:return "账户信息"
        case 1:return "偏好设置"
        default:return ""
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:return 1
        case 1:return 1
        default:return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var accountInfo:NSDictionary? = userDefaults.objectForKey("accountInfo") as! NSDictionary?
            if let temp = accountInfo {
                var cell:AccountTableViewCell = tableView.dequeueReusableCellWithIdentifier("Account") as! AccountTableViewCell
                var userID:String = accountInfo!.objectForKey("userID") as! String
                var name:String = accountInfo?.objectForKey("name") as! String
                var departmentAdmitted:String = accountInfo?.objectForKey("departmentAdmitted") as! String
                
                var timeEnteringSchool:NSString = accountInfo?.objectForKey("timeEnteringSchool") as! NSString
                timeEnteringSchool = timeEnteringSchool.substringWithRange(NSMakeRange(2, 2))
                cell.nameLabel.text = name
                cell.userIDLabel.text = userID
                cell.departmentLabel.text = departmentAdmitted + (timeEnteringSchool as String) + "级本科生"
                return cell

            }
            else {
                var cell = tableView.dequeueReusableCellWithIdentifier("AddAccount") as! UITableViewCell
                
                cell.textLabel?.text = "请先登录！"
                cell.detailTextLabel?.text = "欢迎使用NKU Helper！"
                return cell

            }
        case 1:
            var cell = tableView.dequeueReusableCellWithIdentifier("color") as! ColorTableViewCell
            return cell
        default: var cell = tableView.dequeueReusableCellWithIdentifier("1234") as! UITableViewCell
        return cell

            
            
        }
    }
    
    
}
