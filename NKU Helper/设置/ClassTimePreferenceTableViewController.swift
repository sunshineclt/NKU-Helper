//
//  ClassTestTimePreferenceTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/27.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import UIKit

class ClassTimePreferenceTableViewController: UITableViewController {

    var courseLoadMethod: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        courseLoadMethod = CourseLoadMethodAgent.sharedInstance.getData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.classTimeTablePreferenceCell.identifier)!
        cell.textLabel?.text = indexPath.row == 0 ? "从课程表获取" : "从选课列表获取"
        cell.accessoryType = courseLoadMethod == indexPath.row ? .Checkmark : .None
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != courseLoadMethod {
            CourseLoadMethodAgent.sharedInstance.saveData(indexPath.row)
            courseLoadMethod = indexPath.row
            self.tableView.reloadData()
        }
    }
    
}
