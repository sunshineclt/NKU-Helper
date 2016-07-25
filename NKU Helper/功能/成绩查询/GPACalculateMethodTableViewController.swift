//
//  GPACalculateMethodTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/7/18.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import UIKit

class GPACalculateMethodTableViewController: UITableViewController {

    var method: GPACalculateMethod!
    
    override func viewDidLoad() {
        self.navigationItem.title = method.methodName
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return method.description.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.gPACalculateMethodCell.identifier)!
        cell.textLabel?.text = method.description[indexPath.row].interval
        cell.detailTextLabel?.text = method.description[indexPath.row].gpa
        return cell
    }
    
}
