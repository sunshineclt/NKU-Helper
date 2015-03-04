//
//  SettingTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/1.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        if indexPath.section == 0 {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "account")
            var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var accountInfo:NSDictionary = userDefaults.objectForKey("accountInfo") as NSDictionary
            var userID:String = accountInfo.objectForKey("userID") as String
            cell.textLabel?.text = userID
            cell.detailTextLabel?.text = "欢迎登陆"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        else
        {
            cell = tableView.dequeueReusableCellWithIdentifier("1234") as UITableViewCell
        }
        return cell
    }
    
}
