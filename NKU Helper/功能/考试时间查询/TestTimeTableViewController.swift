//
//  TestTimeTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/6/7.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class TestTimeTableViewController: FunctionBaseTableViewController, FunctionDelegate {

    var testTime = [ClassTestTime]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func doWork() {
        SVProgressHUD.show()
        NKNetworkTestTimeHandler.fetchTestTime(withBlock: fetchTestTimeHandler)
    }
    
    override func loginComplete() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "loginComplete"), object: nil)
        doWork()
    }
    
    func fetchTestTimeHandler(_ result: NKNetworkFetchTestTimeResult) {
        switch result {
        case .success(testTime: let testTimeResult):
            self.testTime = testTimeResult
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
        case .fail:
            self.present(ErrorHandler.alert(withError: ErrorHandler.NetworkError()), animated: true, completion: nil)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return ClassTestTime.getWeekArray(testTime).count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let week = ClassTestTime.getWeekArray(testTime)[section]
        return testTime.filter({ (one) -> Bool in
            return one.week == week
        }).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.testTimeCell.identifier) as! TestTimeTableViewCell
        
        let week = ClassTestTime.getWeekArray(testTime)[indexPath.section]
        let now = testTime.filter({ (one) -> Bool in
            return one.week == week
        })[indexPath.row]
        cell.classNameLabel.text = now.className
        cell.classroomLabel.text = now.classroom
        cell.dayLabel.text = now.getDayString() + " " + CalendarHelper.getWeekdayString(fromWeekday: now.weekday)
        cell.timeLabel.text = now.getTimeString()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let week = ClassTestTime.getWeekArray(testTime)[section]
        return "第\(week)周"
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
}

extension TestTimeTableViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "似乎木有考试信息诶！", attributes: [NSForegroundColorAttributeName : UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1), NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 20)!])

    }
    
}
