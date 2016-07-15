//
//  ColorChooseTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/20.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class ColorChooseTableViewController: UITableViewController {
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "勾选你喜欢的颜色，勾掉你不喜欢的颜色喽~\n这些颜色将会用于课程表页面哦~"
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Colors.colors.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ColorChooseTableViewCell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.PreferredColorCell) as! ColorChooseTableViewCell
        cell.colorView.backgroundColor = Colors.colors[indexPath.row]
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let preferredColors:NSMutableArray = userDefaults.objectForKey("preferredColors") as! NSMutableArray
        let isLiked:Int = preferredColors.objectAtIndex(indexPath.row) as! Int
        if  isLiked == 0 {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = self.tableView(self.tableView, cellForRowAtIndexPath: indexPath)
        if cell.accessoryType == UITableViewCellAccessoryType.None {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let preferredColors:NSMutableArray = userDefaults.objectForKey("preferredColors") as! NSMutableArray
            print(indexPath.row, terminator: "")
            let preferredColors1:NSMutableArray = NSMutableArray()
            preferredColors1.addObjectsFromArray(preferredColors as [AnyObject])
            preferredColors1.replaceObjectAtIndex(indexPath.row, withObject: 1)
            userDefaults.removeObjectForKey("preferredColors")
            userDefaults.setObject(preferredColors1, forKey: "preferredColors")
            userDefaults.synchronize()
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.None
            let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let preferredColors:NSMutableArray = userDefaults.objectForKey("preferredColors") as! NSMutableArray
            print(indexPath.row, terminator: "")
            let preferredColors1:NSMutableArray = NSMutableArray()
            preferredColors1.addObjectsFromArray(preferredColors as [AnyObject])
            preferredColors1.replaceObjectAtIndex(indexPath.row, withObject: 0)
            userDefaults.removeObjectForKey("preferredColors")
            userDefaults.setObject(preferredColors1, forKey: "preferredColors")
            userDefaults.synchronize()
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        self.tableView.reloadData()
    }
    
}
