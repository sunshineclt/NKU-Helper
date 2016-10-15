//
//  EvaluateDetailTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/21/16.
//  Copyright © 2016 陈乐天. All rights reserved.
//

import UIKit

class EvaluateDetailTableViewController: UITableViewController {

    var courseIndexToEvaluate: Int!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SVProgressHUD.show()
        NKNetworkEvaluateDetailHandler.getDetailEvaluateInfo(forIndex: courseIndexToEvaluate) { (result) in
            switch result {
            case .success(let detailEvaluateList):
                SVProgressHUD.dismiss()
                self.detailEvaluateList = detailEvaluateList
                self.tableView.reloadData()
            case .fail:
                SVProgressHUD.dismiss()
                self.present(ErrorHandler.alert(withError: ErrorHandler.NetworkError()), animated: true, completion: nil)
            }
        }
    }

}

extension EvaluateDetailTableViewController: EvaluateDetailStepperProtocol {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < detailEvaluateList.count {
            return detailEvaluateList[section].title
        }
        else {
            return ""
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return detailEvaluateList.count + 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < detailEvaluateList.count {
            return detailEvaluateList[section].question.count
        }
        else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section < detailEvaluateList.count else {
            if indexPath.section == detailEvaluateList.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.evaluateOpinionCell.identifier) as! EvaluateOpinionTableViewCell
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.evaluateSubmitCell.identifier)!
                return cell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.evaluateDetailCell.identifier) as! EvaluateDetailTableViewCell
        cell.delegate = self
        cell.evaluateContentLabel.text = detailEvaluateList[indexPath.section].question[indexPath.row].content
        cell.pointLabel.text = "\(detailEvaluateList[indexPath.section].question[indexPath.row].grade)"
        cell.maxValue = Double(detailEvaluateList[indexPath.section].question[indexPath.row].grade)
        
        return cell
    }
    
    func getQuestionIndexFromIndexPath(_ indexPath: IndexPath) -> Int {
        var index = 0
        for i in 0 ..< indexPath.section {
            index += detailEvaluateList[i].question.count
        }
        index += indexPath.row
        return index
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section > detailEvaluateList.count {
            let opinionIndexPath = IndexPath(row: 0, section: indexPath.section - 1)
            let opinionCell = tableView.cellForRow(at: opinionIndexPath) as! EvaluateOpinionTableViewCell
            var opinion = (opinionCell.opinionTextField.text ?? "")
            if (opinion as NSString).length > 150 {
                opinion = (opinion as NSString).substring(to: 150)
            }
            let index = courseIndexToEvaluate
            SVProgressHUD.show()
            NKNetworkEvaluateSubmitHandler.submit(grades: detailEvaluateGrade, opinion: opinion, index: index!, withBlock: { (result) in
                switch result {
                case .success:
                    SVProgressHUD.dismiss()
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "evaluateSubmitSuccess"), object: nil)
                    let _ = self.navigationController?.popViewController(animated: true)
                case .fail:
                    SVProgressHUD.dismiss()
                    self.present(ErrorHandler.alert(withError: ErrorHandler.EvaluateSubmitFail()), animated: true, completion: nil)
                }
            })
        }
    }
    
    func stepperDidChangeOnCell(_ cell: EvaluateDetailTableViewCell, toValue value: String) {
        let indexPath = self.tableView.indexPath(for: cell)!
        let index = getQuestionIndexFromIndexPath(indexPath)
        detailEvaluateGrade[index] = value
    }
    
}
