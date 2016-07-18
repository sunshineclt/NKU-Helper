//
//  TestTimeTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/6/7.
//  Copyright (c) 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

class TestTimeTableViewController: FunctionBaseTableViewController, FunctionDelegate {

    var testTime = [[String:String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
    }
    
    override func doWork() {
        SVProgressHUD.show()
        let testTimeGetter = NKNetworkFetchTestTime()
        testTimeGetter.fetchTestTime(fetchTestTimeHandler)
    }
    
    override func loginComplete() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "loginComplete", object: nil)
        doWork()
    }
    
    func fetchTestTimeHandler(result: NKNetworkFetchTestTimeResult) {
        switch result {
        case .Success(testTime: let testTimeResult):
            self.testTime = testTimeResult
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
        case .Fail:
            self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testTime.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:TestTimeTableViewCell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.TestTimeCell) as! TestTimeTableViewCell
        
        cell.classNameLabel.text = testTime[indexPath.row]["className"]
        cell.classroomLabel.text = testTime[indexPath.row]["classroom"]
        cell.startTimeLabel.text = testTime[indexPath.row]["startTime"]
        cell.endTimeLabel.text = testTime[indexPath.row]["endTime"]
        cell.weekdayLabel.text = testTime[indexPath.row]["weekday"]
        return cell
    }
    
}

extension TestTimeTableViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "似乎木有考试信息诶！", attributes: [NSForegroundColorAttributeName : UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1), NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 20)!])

    }
    
}
