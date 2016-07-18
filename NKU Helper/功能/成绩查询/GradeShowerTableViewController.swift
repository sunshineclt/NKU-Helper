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
    var ABCGPA:Double = 0
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
    
    func didSuccessToReceiveGradeData(grade grade: [Grade], abcgpa: Double) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.dismiss()
            self.gradeResult = grade
            self.ABCGPA = abcgpa
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
            if section == 5 {
                classTypeLabel.text = "总计"
            }
            else {
                let nowClassType = classType[section]
                classTypeLabel.text = "\(nowClassType)类课"
            }
        }
        else {
            if section == 2 {
                classTypeLabel.text = "总计"
            }
            else {
                let nowClassTyle = classType[section + 5]
                classTypeLabel.text = "\(nowClassTyle)类课"
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
        
        guard ((MajorOrMinorSegmentControl.selectedSegmentIndex == 0) && (section != 5)) || ((MajorOrMinorSegmentControl.selectedSegmentIndex == 1) && (section != 2)) else {
            return view
        }
        
        let nowClassType = classType[(MajorOrMinorSegmentControl.selectedSegmentIndex == 0) ? section : section + 5]
        
        let creditString = NSString(format: "%.1lf", Grade.computeCredit(gradeResult, WithCourseType: [nowClassType]))
        let creditLabel:UILabel = UILabel(frame: CGRectMake(10, 0, UIScreen.mainScreen().bounds.width, 20))
        creditLabel.text = "\(nowClassType)类课总学分：\(creditString)"
        creditLabel.textAlignment = NSTextAlignment.Left
        creditLabel.font = UIFont.systemFontOfSize(14)
        creditLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(creditLabel)
        
        GPA = Grade.computeGPA(gradeResult, WithCourseType: [nowClassType])
        let GPAString = NSString(format: "%.2lf", GPA)
        let gpaLabel:UILabel = UILabel(frame: CGRectMake(-10, 0, UIScreen.mainScreen().bounds.width, 20))
        gpaLabel.text = "\(nowClassType)类课学分绩：\(GPAString)"
        gpaLabel.textAlignment = NSTextAlignment.Right
        gpaLabel.font = UIFont.systemFontOfSize(14)
        gpaLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(gpaLabel)
        
        return view
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (MajorOrMinorSegmentControl.selectedSegmentIndex == 0) ? 6 : 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if MajorOrMinorSegmentControl.selectedSegmentIndex == 0 {
            if section == 5 {
                return 4
            }
        }
        else {
            if section == 2 {
                return 1
            }
        }
        let nowClassType = classType[(MajorOrMinorSegmentControl.selectedSegmentIndex == 0) ? section : section + 5]
        return gradeResult.filter{ $0.classType == nowClassType }.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        func getGradeImageWithGrade(grade: Double) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 40), false, 0)
            let context = UIGraphicsGetCurrentContext()
            let per = (grade - 60) / 40
            var red: Double = 0, green: Double = 0
            if per < 0.5 {
                red = 1
                green = per / 0.5
            }
            else {
                green = 1
                red = ( 1 - per ) / 0.5
            }
            if per < 0 {
                red = 0
                green = 0
            }
            CGContextSetFillColorWithColor(context, UIColor(red: CGFloat(red * 0.8 + 0.1), green: CGFloat(green * 0.8 + 0.1), blue: 0.1, alpha: 1).CGColor)
            CGContextAddEllipseInRect(context, CGRectMake(10, 10, 20, 20));
            CGContextDrawPath(context, .Fill)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            return image
            
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.GradeCell, forIndexPath: indexPath) as! GradeCell
        
        if MajorOrMinorSegmentControl.selectedSegmentIndex == 0 {
            guard indexPath.section != 5 else {
                var grade:Double = 0
                switch indexPath.row {
                case 0:
                    cell.ClassNameLabel.text = "ABC类课"
                    grade = Grade.computeGPA(gradeResult, WithCourseType: ["A","B","C"])
                    cell.GradeLabel.text = NSString(format: "%.2lf", grade) as String
                    cell.CreditLabel.text = NSString(format: "%.1lf", Grade.computeCredit(gradeResult, WithCourseType: ["A","B","C"])) as String
                case 1:
                    cell.ClassNameLabel.text = "ABCD类课"
                    grade = Grade.computeGPA(gradeResult, WithCourseType: ["A","B","C","D"])
                    cell.GradeLabel.text = NSString(format: "%.2lf", grade) as String
                    cell.CreditLabel.text = NSString(format: "%.1lf", Grade.computeCredit(gradeResult, WithCourseType: ["A","B","C","D"])) as String
                case 2:
                    cell.ClassNameLabel.text = "ABCDE类课"
                    grade = Grade.computeGPA(gradeResult, WithCourseType: ["A","B","C","D","E"])
                    cell.GradeLabel.text = NSString(format: "%.2lf", grade) as String
                    cell.CreditLabel.text = NSString(format: "%.1lf", Grade.computeCredit(gradeResult, WithCourseType: ["A","B","C","D","E"])) as String
                case 3:
                    cell.ClassNameLabel.text = "BCD类课"
                    grade = Grade.computeGPA(gradeResult, WithCourseType: ["B","C","D"])
                    cell.GradeLabel.text = NSString(format: "%.2lf", grade) as String
                    cell.CreditLabel.text = NSString(format: "%.1lf", Grade.computeCredit(gradeResult, WithCourseType: ["B","C","D"])) as String
                default:
                    return cell
                }
                cell.gradeImageView.image = getGradeImageWithGrade(grade)
                return cell
            }
        }
        else {
            guard indexPath.section != 2 else {
                var grade:Double = 0
                cell.ClassNameLabel.text = "FC、FD类课"
                grade = Grade.computeGPA(gradeResult, WithCourseType: ["FC","FC"])
                cell.GradeLabel.text = NSString(format: "%.2lf", grade) as String
                cell.CreditLabel.text = NSString(format: "%.1lf", Grade.computeCredit(gradeResult, WithCourseType: ["FC","FD"])) as String
                cell.gradeImageView.image = getGradeImageWithGrade(grade)
                return cell
            }
        }
        
        let nowClassType = classType[(MajorOrMinorSegmentControl.selectedSegmentIndex == 0) ? indexPath.section : indexPath.section + 5]
        let nowGradeSection = gradeResult.filter{ $0.classType == nowClassType}
        let now = nowGradeSection[indexPath.row]
        cell.ClassNameLabel.text = now.className
        cell.GradeLabel.text = now.gradeString
        cell.CreditLabel.text = now.creditString
        
        cell.gradeImageView.image = getGradeImageWithGrade((now.gradeString as NSString).doubleValue)
        
        cell.ClassNameLabel.adjustsFontSizeToFitWidth = true
        
        return cell
        
    }
    
}