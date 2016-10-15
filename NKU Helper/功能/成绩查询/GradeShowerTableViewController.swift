//
//  GradeShowerTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/2/16.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class GradeShowerTableViewController: FunctionBaseTableViewController, FunctionDelegate {

    var gradeResult = [Grade]()
    var GPA:Double = 0
    var whichMethod = 0
    
    @IBOutlet var MajorOrMinorSegmentControl: UISegmentedControl!

    let classType = ["A","B","C","D","E","FC","FD"]
    
    override func doWork() {
        SVProgressHUD.show()
        let gradeGetter = NKNetworkGradeHandler()
        gradeGetter.fetchGrade { (result) in
            switch result {
            case .success(let grade):
                // TODO: 确认是在主线程上
                SVProgressHUD.dismiss()
                self.gradeResult = grade
                self.tableView.reloadData()
            case .fail(let error):
                SVProgressHUD.dismiss()
                self.present(ErrorHandler.alert(withError: error), animated: true, completion: nil)
            }
        }
    }
    
    override func loginComplete() {
        NotificationCenter.default.removeObserver(self)
        doWork()
    }

    @IBAction func majorOrMinorSegmentControlValueDidChange(_ sender: UISegmentedControl) {
        self.tableView.reloadData()
    }

}

extension GradeShowerTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width, height: 20))
        view.backgroundColor = UIColor(red: 0.9215, green: 0.9215, blue: 0.9450, alpha: 1)
        
        let classTypeLabel = UILabel(frame: CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width, height: 20))
        if MajorOrMinorSegmentControl.selectedSegmentIndex == 0 {
            switch section {
            case 5:classTypeLabel.text = "总计"
            case 6:classTypeLabel.text = "GPA（以ABCDE类课计）"
            default:
                let nowClassType = classType[section]
                classTypeLabel.text = "\(nowClassType)类课"
            }
        }
        else {
            switch section {
            case 2:classTypeLabel.text = "总计"
            case 3:classTypeLabel.text = "GPA（以ABCDE类课计）"
            default:
                let nowClassType = classType[section + 5]
                classTypeLabel.text = "\(nowClassType)类课"
            }
        }
        classTypeLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        classTypeLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(classTypeLabel)
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
        view.backgroundColor = UIColor(red: 0.9215, green: 0.9215, blue: 0.9450, alpha: 1)
        
        guard ((MajorOrMinorSegmentControl.selectedSegmentIndex == 0) && (section != 6)) || ((MajorOrMinorSegmentControl.selectedSegmentIndex == 1) && (section != 3)) else {
            let infoLabel = UILabel(frame: CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width - 20, height: 20))
            infoLabel.text = "如发现GPA算法有错误或希望增加GPA算法，请联系开发者"
            infoLabel.textAlignment = NSTextAlignment.left
            infoLabel.font = UIFont.systemFont(ofSize: 10)
            infoLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
            view.addSubview(infoLabel)
            return view
        }
        
        guard ((MajorOrMinorSegmentControl.selectedSegmentIndex == 0) && (section != 5)) || ((MajorOrMinorSegmentControl.selectedSegmentIndex == 1) && (section != 2)) else {
            return view
        }
        
        let nowClassType = classType[(MajorOrMinorSegmentControl.selectedSegmentIndex == 0) ? section : section + 5]
        
        let creditString = NSString(format: "%.1lf", Grade.computeCredit(gradeResult, WithCourseType: [nowClassType]))
        let creditLabel = UILabel(frame: CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width, height: 20))
        creditLabel.text = "\(nowClassType)类课总学分：\(creditString)"
        creditLabel.textAlignment = NSTextAlignment.left
        creditLabel.font = UIFont.systemFont(ofSize: 14)
        creditLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(creditLabel)
        
        GPA = Grade.computeGradeCreditSum(gradeResult, WithCourseType: [nowClassType], isAverage: false)
        let GPAString = NSString(format: "%.2lf", GPA)
        let gpaLabel = UILabel(frame: CGRect(x: -10, y: 0, width: UIScreen.main.bounds.width, height: 20))
        gpaLabel.text = "\(nowClassType)类课学分绩：\(GPAString)"
        gpaLabel.textAlignment = NSTextAlignment.right
        gpaLabel.font = UIFont.systemFont(ofSize: 14)
        gpaLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(gpaLabel)
        
        return view
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (MajorOrMinorSegmentControl.selectedSegmentIndex == 0) ? 7 : 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if MajorOrMinorSegmentControl.selectedSegmentIndex == 0 {
            switch section {
            case 5:return 5
            case 6:return GPACalculateMethod.methods.count
            default:break
            }
        }
        else {
            switch section {
            case 2:return 1
            case 3:return GPACalculateMethod.methods.count
            default:break
            }
        }
        let nowClassType = classType[(MajorOrMinorSegmentControl.selectedSegmentIndex == 0) ? section : section + 5]
        return gradeResult.filter{ $0.classType == nowClassType }.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if MajorOrMinorSegmentControl.selectedSegmentIndex == 0 {
            guard indexPath.section != 5 else {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.gradeCell.identifier, for: indexPath) as! GradeCell
                switch indexPath.row {
                case 0:
                    let grade = Grade.computeGradeCreditSum(gradeResult, WithCourseType: ["A", "B", "C"], isAverage: false)
                    let credit = Grade.computeCredit(gradeResult, WithCourseType: ["A","B","C"])
                    cell.grade = Grade(className: "ABC类课", classType: "ABC", grade: .ok(grade: grade, credit: credit))
                case 1:
                    let grade = Grade.computeGradeCreditSum(gradeResult, WithCourseType: ["A", "B", "C", "D"], isAverage: false)
                    let credit = Grade.computeCredit(gradeResult, WithCourseType: ["A","B","C","D"])
                    cell.grade = Grade(className: "ABCD类课", classType: "ABCD", grade: .ok(grade: grade, credit: credit))
                case 2:
                    let grade = Grade.computeGradeCreditSum(gradeResult, WithCourseType: ["A", "B", "C", "D", "E"], isAverage: false)
                    let credit = Grade.computeCredit(gradeResult, WithCourseType: ["A","B","C","D","E"])
                    cell.grade = Grade(className: "ABCDE类课", classType: "ABCDE", grade: .ok(grade: grade, credit: credit))
                case 3:
                    let grade = Grade.computeGradeCreditSum(gradeResult, WithCourseType: ["B", "C", "D"], isAverage: false)
                    let credit = Grade.computeCredit(gradeResult, WithCourseType: ["B","C","D"])
                    cell.grade = Grade(className: "BCD类课", classType: "BCD", grade: .ok(grade: grade, credit: credit))
                case 4:
                    let grade = Grade.computeGradeCreditSum(gradeResult, WithCourseType: ["A", "B", "C", "D", "E"], isAverage: true)
                    let credit = Grade.computeCredit(gradeResult, WithCourseType: ["A", "B", "C", "D", "E"])
                    cell.grade = Grade(className: "ABCDE类课算术平均", classType: "ABCDE", grade: .ok(grade: grade, credit: credit))
                default:
                    return cell
                }
                return cell
            }
            guard indexPath.section != 6 else {
                let method = GPACalculateMethod.methods[indexPath.row]
                let grade = Grade.computeGRA(gradeResult, WithGPACalculateMethod: method, AndCourseType: ["A", "B", "C", "D", "E"])
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.gPACell.identifier, for: indexPath) as! GPACell
                cell.GPASum = GPACalculateMethod.methodsSum[indexPath.row]
                cell.GPAName = method.methodName
                cell.GPA = grade
                return cell
            }
        }
        else {
            guard indexPath.section != 2 else {
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.gradeCell.identifier, for: indexPath) as! GradeCell
                let grade = Grade.computeGradeCreditSum(gradeResult, WithCourseType: ["FC", "FD"], isAverage: false)
                let credit = Grade.computeCredit(gradeResult, WithCourseType: ["FC","FD"])
                cell.grade = Grade(className: "FC、FD类课", classType: "FCFD", grade: .ok(grade: grade, credit: credit))
                return cell
            }
            guard indexPath.section != 3 else {
                let method = GPACalculateMethod.methods[indexPath.row]
                let grade = Grade.computeGRA(gradeResult, WithGPACalculateMethod: method, AndCourseType: ["FC", "FD"])
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.gPACell.identifier, for: indexPath) as! GPACell
                cell.GPASum = GPACalculateMethod.methodsSum[indexPath.row]
                cell.GPAName = method.methodName
                cell.GPA = grade
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.gradeCell.identifier, for: indexPath) as! GradeCell
        let nowClassType = classType[(MajorOrMinorSegmentControl.selectedSegmentIndex == 0) ? indexPath.section : indexPath.section + 5]
        let nowGradeSection = gradeResult.filter{ $0.classType == nowClassType}
        let now = nowGradeSection[indexPath.row]
        cell.grade = now
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (MajorOrMinorSegmentControl.selectedSegmentIndex == 0) && (indexPath.section == 6) ||
            (MajorOrMinorSegmentControl.selectedSegmentIndex == 1) && (indexPath.section == 3) {
            whichMethod = indexPath.row
            self.performSegue(withIdentifier: R.segue.gradeShowerTableViewController.showGPACalculateMethod, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typeInfo = R.segue.gradeShowerTableViewController.showGPACalculateMethod(segue: segue) {
            typeInfo.destination.method = GPACalculateMethod.methods[whichMethod]
        }
    }
    
}
