//
//  EvaluateTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/21/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import UIKit

class EvaluateTableViewController: FunctionBaseTableViewController, FunctionDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(EvaluateTableViewController.doWork), name: NSNotification.Name(rawValue: "evaluateSubmitSuccess"), object: nil)
    }
    
    override func doWork() {
        SVProgressHUD.show()
        NKNetworkCourseEvaluateHandler.getEvaluateList { (result) in
            switch result {
            case .success(let coursesToEvaluate):
                SVProgressHUD.dismiss()
                self.coursesToEvaluate = coursesToEvaluate
                self.tableView.reloadData()
            case .evaluateSystemNotOpen:
                SVProgressHUD.dismiss()
                self.present(ErrorHandler.alert(withError: ErrorHandler.EvaluateSystemNotOpen()), animated: true, completion: nil)
            case .fail:
                SVProgressHUD.dismiss()
                self.present(ErrorHandler.alert(withError: ErrorHandler.NetworkError()), animated: true, completion: nil)
            }
        }
    }
    
    override func loginComplete() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "loginComplete"), object: nil)
        doWork()
    }
    
    var coursesToEvaluate = [CourseToEvaluate]()
    
    var selectedIndex: Int?

}

extension EvaluateTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coursesToEvaluate.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.classToEvaluateCell.identifier) as! ClassToEvaluateTableViewCell
        cell.courseToEvaluate = coursesToEvaluate[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ClassToEvaluateTableViewCell
        selectedIndex = cell.courseToEvaluate.index
        if !cell.courseToEvaluate.hasEvaluated {
            self.performSegue(withIdentifier: R.segue.evaluateTableViewController.showEvaluateDetail.identifier, sender: nil)
        }
        else {
            self.present(ErrorHandler.alert(withError: ErrorHandler.EvaluateHasDone()), animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typeInfo = R.segue.evaluateTableViewController.showEvaluateDetail(segue: segue) {
            typeInfo.destination.courseIndexToEvaluate = selectedIndex
        }
    }
    
}

extension EvaluateTableViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "没有评教信息", attributes: [NSForegroundColorAttributeName : UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1), NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 20)!])
    }
}
