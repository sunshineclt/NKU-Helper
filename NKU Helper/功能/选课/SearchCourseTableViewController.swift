//
//  SearchCourseTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 2/29/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import UIKit

class SearchCourseTableViewController: UITableViewController {

    var courseSearchResult: [CourseSelecting]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return courseSearchResult.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCellWithIdentifier("classInfo", forIndexPath: indexPath) as! ClassInfoTableViewCell
        cell.course = courseSearchResult[indexPath.row]
        return cell

    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "searchCourseDetail" {
            if let vc = segue.destinationViewController as? SearchCourseDetailTableViewController {
                if let cell = sender as? ClassInfoTableViewCell {
                    if let indexPath = tableView.indexPathForCell(cell) {
                        vc.courseSelecting = courseSearchResult[indexPath.row]
                    }
                }
            }
        }
    }

}
