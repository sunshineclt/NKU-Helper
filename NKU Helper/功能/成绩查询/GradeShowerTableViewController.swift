//
//  GradeShowerTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/2/16.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class GradeShowerTableViewController: FunctionBaseTableViewController, FunctionDelegate, NKNetworkFetchGradeProtocol {

    var gradeResult = [Grade]()
    var GPA:Double = 0
    var whichMethod = 0
    
    @IBOutlet var MajorOrMinorSegmentControl: UISegmentedControl!

    let classType = ["A","B","C","D","E","FC","FD"]
    
    override func doWork() {
        SVProgressHUD.show()
        let gradeGetter = NKNetworkFetchGrade()
        gradeGetter.delegate = self
        gradeGetter.fetchGrade()
    }
    
    override func loginComplete() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        doWork()
    }
    
    func didSuccessToReceiveGradeData(grade grade: [Grade]) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.dismiss()
            self.gradeResult = grade
            self.tableView.reloadData()
        }
    }
    
    func didFailToReceiveGradeData(error: ErrorHandlerProtocol) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.dismiss()
            self.presentViewController(ErrorHandler.alert(error), animated: true, completion: nil)
        }
    }

    @IBAction func majorOrMinorSegmentControlValueDidChange(sender: UISegmentedControl) {
        self.tableView.reloadData()
    }

}

extension GradeShowerTableViewController {
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRectMake(0, 10, UIScreen.mainScreen().bounds.width, 20))
        view.backgroundColor = UIColor(red: 0.9215, green: 0.9215, blue: 0.9450, alpha: 1)
        
        let classTypeLabel = UILabel(frame: CGRectMake(10, 0, UIScreen.mainScreen().bounds.width, 20))
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
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 20))
        view.backgroundColor = UIColor(red: 0.9215, green: 0.9215, blue: 0.9450, alpha: 1)
        
        guard ((MajorOrMinorSegmentControl.selectedSegmentIndex == 0) && (section != 6)) || ((MajorOrMinorSegmentControl.selectedSegmentIndex == 1) && (section != 3)) else {
            let infoLabel = UILabel(frame: CGRectMake(10, 0, UIScreen.mainScreen().bounds.width - 20, 20))
            infoLabel.text = "如发现GPA算法有错误或希望增加GPA算法，请联系开发者"
            infoLabel.textAlignment = NSTextAlignment.Left
            infoLabel.font = UIFont.systemFontOfSize(10)
            infoLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
            view.addSubview(infoLabel)
            return view
        }
        
        guard ((MajorOrMinorSegmentControl.selectedSegmentIndex == 0) && (section != 5)) || ((MajorOrMinorSegmentControl.selectedSegmentIndex == 1) && (section != 2)) else {
            return view
        }
        
        let nowClassType = classType[(MajorOrMinorSegmentControl.selectedSegmentIndex == 0) ? section : section + 5]
        
        let creditString = NSString(format: "%.1lf", Grade.computeCredit(gradeResult, WithCourseType: [nowClassType]))
        let creditLabel = UILabel(frame: CGRectMake(10, 0, UIScreen.mainScreen().bounds.width, 20))
        creditLabel.text = "\(nowClassType)类课总学分：\(creditString)"
        creditLabel.textAlignment = NSTextAlignment.Left
        creditLabel.font = UIFont.systemFontOfSize(14)
        creditLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(creditLabel)
        
        GPA = Grade.computeGradeCreditSum(gradeResult, WithCourseType: [nowClassType], isAverage: false)
        let GPAString = NSString(format: "%.2lf", GPA)
        let gpaLabel = UILabel(frame: CGRectMake(-10, 0, UIScreen.mainScreen().bounds.width, 20))
        gpaLabel.text = "\(nowClassType)类课学分绩：\(GPAString)"
        gpaLabel.textAlignment = NSTextAlignment.Right
        gpaLabel.font = UIFont.systemFontOfSize(14)
        gpaLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(gpaLabel)
        
        return view
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (MajorOrMinorSegmentControl.selectedSegmentIndex == 0) ? 7 : 4
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if MajorOrMinorSegmentControl.selectedSegmentIndex == 0 {
            guard indexPath.section != 5 else {
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.gradeCell.identifier, forIndexPath: indexPath) as! GradeCell
                switch indexPath.row {
                case 0:
                    let grade = Grade.computeGradeCreditSum(gradeResult, WithCourseType: ["A", "B", "C"], isAverage: false)
                    let credit = Grade.computeCredit(gradeResult, WithCourseType: ["A","B","C"])
                    cell.grade = Grade(className: "ABC类课", classType: "ABC", grade: GradeValue.OK(grade: grade, credit: credit))
                case 1:
                    let grade = Grade.computeGradeCreditSum(gradeResult, WithCourseType: ["A", "B", "C", "D"], isAverage: false)
                    let credit = Grade.computeCredit(gradeResult, WithCourseType: ["A","B","C","D"])
                    cell.grade = Grade(className: "ABCD类课", classType: "ABCD", grade: GradeValue.OK(grade: grade, credit: credit))
                case 2:
                    let grade = Grade.computeGradeCreditSum(gradeResult, WithCourseType: ["A", "B", "C", "D", "E"], isAverage: false)
                    let credit = Grade.computeCredit(gradeResult, WithCourseType: ["A","B","C","D","E"])
                    cell.grade = Grade(className: "ABCDE类课", classType: "ABCDE", grade: GradeValue.OK(grade: grade, credit: credit))
                case 3:
                    let grade = Grade.computeGradeCreditSum(gradeResult, WithCourseType: ["B", "C", "D"], isAverage: false)
                    let credit = Grade.computeCredit(gradeResult, WithCourseType: ["B","C","D"])
                    cell.grade = Grade(className: "BCD类课", classType: "BCD", grade: GradeValue.OK(grade: grade, credit: credit))
                case 4:
                    let grade = Grade.computeGradeCreditSum(gradeResult, WithCourseType: ["A", "B", "C", "D", "E"], isAverage: true)
                    let credit = Grade.computeCredit(gradeResult, WithCourseType: ["A", "B", "C", "D", "E"])
                    cell.grade = Grade(className: "ABCDE类课算术平均", classType: "ABCDE", grade: GradeValue.OK(grade: grade, credit: credit))
                default:
                    return cell
                }
                return cell
            }
            guard indexPath.section != 6 else {
                let method = GPACalculateMethod.methods[indexPath.row]
                let grade = Grade.computeGRA(gradeResult, WithGPACalculateMethod: method, AndCourseType: ["A", "B", "C", "D", "E"])
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.gPACell.identifier, forIndexPath: indexPath) as! GPACell
                cell.GPASum = GPACalculateMethod.methodsSum[indexPath.row]
                cell.GPAName = method.methodName
                cell.GPA = grade
                return cell
            }
        }
        else {
            guard indexPath.section != 2 else {
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.gradeCell.identifier, forIndexPath: indexPath) as! GradeCell
                let grade = Grade.computeGradeCreditSum(gradeResult, WithCourseType: ["FC", "FD"], isAverage: false)
                let credit = Grade.computeCredit(gradeResult, WithCourseType: ["FC","FD"])
                cell.grade = Grade(className: "FC、FD类课", classType: "FCFD", grade: GradeValue.OK(grade: grade, credit: credit))
                return cell
            }
            guard indexPath.section != 3 else {
                let method = GPACalculateMethod.methods[indexPath.row]
                let grade = Grade.computeGRA(gradeResult, WithGPACalculateMethod: method, AndCourseType: ["FC", "FD"])
                let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.gPACell.identifier, forIndexPath: indexPath) as! GPACell
                cell.GPASum = GPACalculateMethod.methodsSum[indexPath.row]
                cell.GPAName = method.methodName
                cell.GPA = grade
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.gradeCell.identifier, forIndexPath: indexPath) as! GradeCell
        let nowClassType = classType[(MajorOrMinorSegmentControl.selectedSegmentIndex == 0) ? indexPath.section : indexPath.section + 5]
        let nowGradeSection = gradeResult.filter{ $0.classType == nowClassType}
        let now = nowGradeSection[indexPath.row]
        cell.grade = now
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (MajorOrMinorSegmentControl.selectedSegmentIndex == 0) && (indexPath.section == 6) ||
            (MajorOrMinorSegmentControl.selectedSegmentIndex == 1) && (indexPath.section == 3) {
            whichMethod = indexPath.row
            self.performSegueWithIdentifier(R.segue.gradeShowerTableViewController.showGPACalculateMethod, sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let typeInfo = R.segue.gradeShowerTableViewController.showGPACalculateMethod(segue: segue) {
            typeInfo.destinationViewController.method = GPACalculateMethod.methods[whichMethod]
        }
    }
    
}