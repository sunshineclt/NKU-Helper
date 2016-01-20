//
//  FunctionTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/1.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class FunctionTableViewController: UITableViewController {

    /// 是否已经输入用户名和密码
    var isLoggedIn:Bool {
        if let _ = UserAgent().getData() {
            return true
        }
        else {
            return false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if UserAgent().getData() == nil {
            self.presentViewController(ErrorHandler.alert(ErrorHandler.NotLoggedIn()), animated: true, completion: nil)
        }
        self.tableView.reloadData()
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let actionType = tableViewActionType {
            if actionType == 0 {
                self.performSegueWithIdentifier(CellIdentifier.notiCenter, sender: nil)
            }
            tableViewActionType = nil
        }
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
