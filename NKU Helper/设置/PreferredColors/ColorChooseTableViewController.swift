//
//  ColorChooseTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/20.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit
import RealmSwift

class ColorChooseTableViewController: UITableViewController {
    
    var colors: Results<Color>!
    
    override func viewDidLoad() {
        do {
            colors = try Color.getColors()
        } catch {
            presentViewController(ErrorHandler.alert(ErrorHandler.StorageNotEnough()), animated: true, completion: nil)
        }
    }
    
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
        return Color.getColorCount()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.PreferredColorCell) as! ColorChooseTableViewCell
        let color = colors[indexPath.row]
        cell.colorView.backgroundColor = color.convertToUIColor()
        cell.accessoryType = color.liked ? .Checkmark : .None
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = self.tableView(self.tableView, cellForRowAtIndexPath: indexPath)
        if cell.accessoryType == UITableViewCellAccessoryType.None {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            colors[indexPath.row].toggleLike()
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.None
            colors[indexPath.row].toggleLike()
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
}
