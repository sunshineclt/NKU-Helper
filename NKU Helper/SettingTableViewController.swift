//
//  SettingTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/1.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection:Int = 1
        return numberOfRowsInSection
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        switch indexPath.section {
        case 0:
            var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var accountInfo:NSDictionary? = userDefaults.objectForKey("accountInfo") as NSDictionary?
            if let temp = accountInfo {
                cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Account")

                var userID:String = accountInfo!.objectForKey("userID") as String
                cell.textLabel?.text = userID
                cell.detailTextLabel?.text = "欢迎登陆"
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            }
            else {
                cell = tableView.dequeueReusableCellWithIdentifier("AddAccount") as UITableViewCell

                cell.textLabel?.text = "请先登录！"
                cell.detailTextLabel?.text = "欢迎使用NKU Helper！"
            }
            //case 1:
            
            //cell = tableView.dequeueReusableCellWithIdentifier("1234") as UITableViewCell
            
        default:cell = tableView.dequeueReusableCellWithIdentifier("1234") as UITableViewCell
            
            
        }
        return cell
    }
    
    
}
