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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.classTimeTablePreferenceCell.identifier)!
        cell.textLabel?.text = indexPath.row == 0 ? "从课程表获取" : "从选课列表获取"
        cell.accessoryType = courseLoadMethod == indexPath.row ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != courseLoadMethod {
            CourseLoadMethodAgent.sharedInstance.save(data: indexPath.row)
            courseLoadMethod = indexPath.row
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "选课课程表加载方式"
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "从课程表中获取可以在开启新学期选课系统打开之后依然看到这学期的课表，但若同一时间单双周课程不同会无法加载出双周课程。从选课列表获取可以保证获取的数据均准确，但在新学期选课系统打开之后就只能加载下学期的课表。然而有的时候两个课程表会有一些不同，我表示懵逼，如果你知道是为什么请告诉我🙈"
    }
    
}
