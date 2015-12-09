//
//  FunctionTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/1.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class FunctionTableViewController: UITableViewController {

    var isLoggedIn:Bool {
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("accountInfo") as? NSDictionary {
            return true
        }
        else {
            return false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if NSUserDefaults.standardUserDefaults().objectForKey("accountInfo") as? NSDictionary == nil {
            let alert = UIAlertController(title: ErrorHandler.NotLoggedIn.title, message: ErrorHandler.NotLoggedIn.message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: ErrorHandler.NotLoggedIn.cancelButtonTitle, style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        self.tableView.reloadData()
        super.viewWillAppear(animated)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("noticenter")!
            cell.textLabel?.text = "通知中心"
            cell.userInteractionEnabled = isLoggedIn
            return cell
        case 1:
            let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Functioner")!
            cell.textLabel?.text = "查询成绩"
            cell.userInteractionEnabled = isLoggedIn
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("MoreFunction")!
            cell.textLabel?.text = "更多功能敬请期待（等学校网站开放）"
            cell.userInteractionEnabled = isLoggedIn
            return cell
        default:return UITableViewCell()
        }
    }
    
}
