//
//  ColorChooseTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/20.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class ColorChooseTableViewController: UITableViewController {

    let colors:NSArray = [
        UIColor(red: 190/255, green: 150/255, blue: 210/255, alpha: 1),
        UIColor(red: 168/255, green: 239/255, blue: 233/255, alpha: 1),
        UIColor(red: 193/255, green: 233/255, blue: 241/255, alpha: 1),
        UIColor(red: 186/255, green: 241/255, blue: 209/255, alpha: 1),
        UIColor(red: 34/255, green: 202/255, blue: 179/255, alpha: 1),
        UIColor(red: 230/255, green: 225/255, blue: 187/255, alpha: 1),
        UIColor(red: 236/255, green: 206/255, blue: 178/255, alpha: 1),
        UIColor(red: 217/255, green: 189/255, blue: 126/255, alpha: 0.9),
        UIColor(red: 241/255, green: 174/255, blue: 165/255, alpha: 1),
        UIColor(red: 250/255, green: 98/255, blue: 110/255, alpha: 0.8)]
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "勾选你喜欢的颜色，勾掉你不喜欢的颜色喽~\n这些颜色将会用于'今天'界面的Overview哦~"
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:ColorChooseTableViewCell = tableView.dequeueReusableCellWithIdentifier("colorChoose") as! ColorChooseTableViewCell
        cell.colorView.backgroundColor = colors.objectAtIndex(indexPath.row) as? UIColor
        var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var preferredColors:NSMutableArray = userDefaults.objectForKey("preferredColors") as! NSMutableArray
        var isLiked:Int = preferredColors.objectAtIndex(indexPath.row) as! Int
        if  isLiked == 0 {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var cell = self.tableView(self.tableView, cellForRowAtIndexPath: indexPath)
        if cell.accessoryType == UITableViewCellAccessoryType.None {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var preferredColors:NSMutableArray = userDefaults.objectForKey("preferredColors") as! NSMutableArray
            print(indexPath.row)
            var preferredColors1:NSMutableArray = NSMutableArray()
            preferredColors1.addObjectsFromArray(preferredColors as [AnyObject])
            preferredColors1.replaceObjectAtIndex(indexPath.row, withObject: 1)
            userDefaults.removeObjectForKey("preferredColors")
            userDefaults.setObject(preferredColors1, forKey: "preferredColors")
            userDefaults.synchronize()
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.None
            var userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var preferredColors:NSMutableArray = userDefaults.objectForKey("preferredColors") as! NSMutableArray
            print(indexPath.row)
            var preferredColors1:NSMutableArray = NSMutableArray()
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
