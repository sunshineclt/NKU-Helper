//
//  EvaluateDetailTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/21/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import UIKit

class EvaluateDetailTableViewController: UITableViewController {

    var classIndexToEvaluate: Int!
    
    var detailEvaluateList = [DetailEvaluateSection]() {
        didSet {
            for section in detailEvaluateList {
                for question in section.question {
                    detailEvaluateGrade.append("\(question.grade)")
                }
            }
            
        }
    }
    var detailEvaluateGrade = [String]()
    var detailEvaluateGradeIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 140
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let evaluateDetailGetter = NKNetworkEvaluateDetail()
        evaluateDetailGetter.delegate = self
        SVProgressHUD.show()
        evaluateDetailGetter.getDetailEvaluateItem(classIndexToEvaluate)
    }

}

extension EvaluateDetailTableViewController: NKNetworkEvaluateDetailProtocol {
    
    func didNetworkFail() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.dismiss()
            self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
        }
    }
    
    func didSuccess(detailEvaluateList: [DetailEvaluateSection]) {
        SVProgressHUD.dismiss()
        self.detailEvaluateList = detailEvaluateList
        self.tableView.reloadData()
    }
}

extension EvaluateDetailTableViewController: EvaluateDetailStepperProtocol {
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < detailEvaluateList.count {
            return detailEvaluateList[section].title
        }
        else {
            return ""
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return detailEvaluateList.count + 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < detailEvaluateList.count {
            return detailEvaluateList[section].question.count
        }
        else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard indexPath.section < detailEvaluateList.count else {
            if indexPath.section == detailEvaluateList.count {
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.evaluateOpinionCell.identifier) as! EvaluateOpinionTableViewCell
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.evaluateSubmitCell.identifier)!
                return cell
            }
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.evaluateDetailCell.identifier) as! EvaluateDetailTableViewCell
        cell.delegate = self
        cell.evaluateContentLabel.text = detailEvaluateList[indexPath.section].question[indexPath.row].content
        cell.pointLabel.text = "\(detailEvaluateList[indexPath.section].question[indexPath.row].grade)"
        cell.maxValue = Double(detailEvaluateList[indexPath.section].question[indexPath.row].grade)
        
        return cell
    }
    
    func getQuestionIndexFromIndexPath(indexPath: NSIndexPath) -> Int {
        var index = 0
        for i in 0 ..< indexPath.section {
            index += detailEvaluateList[i].question.count
        }
        index += indexPath.row
        return index
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section > detailEvaluateList.count {
            let opinionIndexPath = NSIndexPath(forRow: 0, inSection: indexPath.section - 1)
            let opinionCell = tableView.cellForRowAtIndexPath(opinionIndexPath) as! EvaluateOpinionTableViewCell
            var opinion = (opinionCell.opinionTextField.text ?? "")
            if (opinion as NSString).length > 150 {
                opinion = (opinion as NSString).substringToIndex(150)
            }
            let index = classIndexToEvaluate
            let evaluateSubmitter = NKNetworkEvaluateSubmit()
            evaluateSubmitter.delegate = self
            SVProgressHUD.show()
            evaluateSubmitter.submit(detailEvaluateGrade, opinion: opinion, index: index)
        }
    }
    
    func stepperDidChangeOnCell(cell: EvaluateDetailTableViewCell, toValue value: String) {
        let indexPath = self.tableView.indexPathForCell(cell)!
        let index = getQuestionIndexFromIndexPath(indexPath)
        detailEvaluateGrade[index] = value
    }
    
}

extension EvaluateDetailTableViewController: NKNetworkEvaluateSubmitProtocol {
    
    func didFailToSubmit() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.dismiss()
            self.presentViewController(ErrorHandler.alert(ErrorHandler.EvaluateSubmitFail()), animated: true, completion: nil)
        }
    }
    
    func didSuccessToSubmit() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.dismiss()
            NSNotificationCenter.defaultCenter().postNotificationName("evaluateSubmitSuccess", object: nil)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
}