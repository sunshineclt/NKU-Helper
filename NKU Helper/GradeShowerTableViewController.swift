//
//  GradeShowerTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/2/16.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class GradeShowerTableViewController: UITableViewController {

    var gradeResult:NSArray = NSArray()
    var GPA:Float! = 0
    var allCredit:Float! = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view:UIView = UIView(frame: CGRectMake(0, 0, 320, 20))
        view.backgroundColor = UIColor(red: 0.9215, green: 0.9215, blue: 0.9450, alpha: 1)
        
        var classNameLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 70, 20))
        classNameLabel.text = "课程名称"
        classNameLabel.font = UIFont.systemFontOfSize(14)
        classNameLabel.textAlignment = NSTextAlignment.Center
        classNameLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(classNameLabel)
        
        var classTypeLabel:UILabel = UILabel(frame: CGRectMake(145, 0, 80, 20))
        classTypeLabel.font = UIFont.systemFontOfSize(14)
        classTypeLabel.text = "课程类型"
        classTypeLabel.textAlignment = NSTextAlignment.Center
        classTypeLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(classTypeLabel)
        
        var gradeLabel:UILabel = UILabel(frame: CGRectMake(223, 0, 40, 20))
        gradeLabel.text = "分数"
        gradeLabel.font = UIFont.systemFontOfSize(14)
        gradeLabel.textAlignment = NSTextAlignment.Center
        gradeLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(gradeLabel)
        
        var creditLabel:UILabel = UILabel(frame: CGRectMake(272, 0, 40, 20))
        creditLabel.text = "学分"
        creditLabel.font = UIFont.systemFontOfSize(14)
        creditLabel.textAlignment = NSTextAlignment.Center
        creditLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(creditLabel)
        
        return view
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        var view:UIView = UIView(frame: CGRectMake(0, 0, 320, 20))
        view.backgroundColor = UIColor(red: 0.9215, green: 0.9215, blue: 0.9450, alpha: 1)
        
        var creditLabel:UILabel = UILabel(frame: CGRectMake(80, 0, 100, 20))
        creditLabel.text = "总学分：\(allCredit)"
        creditLabel.textAlignment = NSTextAlignment.Right
        creditLabel.font = UIFont.systemFontOfSize(14)
        creditLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(creditLabel)
        
        GPA = GPA / allCredit
        var gpaLabel:UILabel = UILabel(frame: CGRectMake(170, 0, 140, 20))
        gpaLabel.text = "学分绩：\(GPA)"
        gpaLabel.textAlignment = NSTextAlignment.Right
        gpaLabel.font = UIFont.systemFontOfSize(14)
        gpaLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(gpaLabel)
        
        return view
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gradeResult.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cellIndentifier = "GradeCell"
        var cell:GradeCell = tableView.dequeueReusableCellWithIdentifier(cellIndentifier, forIndexPath: indexPath) as GradeCell

        
        var now:NSDictionary = gradeResult.objectAtIndex(indexPath.row) as NSDictionary
        var className:NSString = now.objectForKey("className") as NSString
        var classType:NSString = now.objectForKey("classType") as NSString
        var grade:NSString = now.objectForKey("grade") as NSString
        var credit:NSString = now.objectForKey("credit") as NSString
        
        cell.ClassNameLabel.text = className
        cell.ClassTypeLabel.text = classType
        cell.GradeLabel.text = grade
        cell.CreditLabel.text = credit
        
        var creditNumber:Float = credit.floatValue
        var gradeNumber:Float = grade.floatValue
        GPA = GPA + gradeNumber * creditNumber
        allCredit = allCredit + creditNumber
        
        cell.ClassNameLabel.adjustsFontSizeToFitWidth = true
        
        return cell
        
    }
    
}
