//
//  FunctionTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/1.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class FunctionTableViewController: UITableViewController {

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Functioner")!
            cell.textLabel?.text = "查询成绩"
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("MoreFunction")!
            cell.textLabel?.text = "更多功能敬请期待（等学校网站开放）"
            return cell
        default:return UITableViewCell()
        }
    }
    
}
