//
//  GradeShowerTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/2/16.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class GradeShowerTableViewController: UITableViewController {

    var gradeResult:NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gradeResult.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cellIndentifier = "GradeCell"
        var cell:GradeCell = tableView.dequeueReusableCellWithIdentifier(cellIndentifier, forIndexPath: indexPath) as GradeCell

        
        var now:NSDictionary = gradeResult.objectAtIndex(indexPath.row) as NSDictionary
        var className:NSString = now.objectForKey("className") as NSString
        var classType:NSString = now.objectForKey("classType") as NSString
        var grade:NSString = now.objectForKey("grade") as NSString
        var credit:NSString = now.objectForKey("credit") as NSString
        
        cell.ClassNameLabel.text = className
        cell.ClassTypeLabel.text = classType
        cell.GradeLabel.text = grade
        cell.CreditLabel.text = credit
        
        return cell
        
    }
    
}
