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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return method.description.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.gPACalculateMethodCell.identifier)!
        cell.textLabel?.text = method.description[indexPath.row].interval
        cell.detailTextLabel?.text = method.description[indexPath.row].gpa
        return cell
    }
    
}
