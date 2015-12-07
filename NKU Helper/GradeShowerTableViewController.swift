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
    var GPA:Float = 0
    var ABCGPA:String!
    var ABCDGPA:Float = 0
    var allCredit:Float = 0
    var ABCDCredit:Float = 0
    
    override func viewDidLoad() {
        
        for (var i=0; i < gradeResult.count; i++) {
            let now:NSDictionary = gradeResult.objectAtIndex(i) as! NSDictionary
            let grade:NSString = now.objectForKey("grade") as! NSString
            let credit:NSString = now.objectForKey("credit") as! NSString
            let creditNumber:Float = credit.floatValue
            let gradeNumber:Float = grade.floatValue
            GPA = GPA + gradeNumber * creditNumber
            let classType = now.objectForKey("classType") as! String
            if ((classType == "A") || (classType == "B") || (classType == "C") || (classType == "D")) {
                ABCDGPA += gradeNumber * creditNumber
                ABCDCredit += creditNumber
            }
            allCredit = allCredit + creditNumber
        }
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view:UIView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 20))
        view.backgroundColor = UIColor(red: 0.9215, green: 0.9215, blue: 0.9450, alpha: 1)
        
        let classNameLabel:UILabel = UILabel(frame: CGRectMake(10, 0, 70, 20))
        classNameLabel.text = "课程名称"
        classNameLabel.font = UIFont.systemFontOfSize(14)
        classNameLabel.textAlignment = NSTextAlignment.Center
        classNameLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(classNameLabel)
        
        let classTypeLabel:UILabel = UILabel(frame: CGRectMake(UIScreen.mainScreen().bounds.width - 175, 0, 80, 20))
        classTypeLabel.font = UIFont.systemFontOfSize(14)
        classTypeLabel.text = "课程类型"
        classTypeLabel.textAlignment = NSTextAlignment.Center
        classTypeLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(classTypeLabel)
        
        let gradeLabel:UILabel = UILabel(frame: CGRectMake(UIScreen.mainScreen().bounds.width - 100, 0, 40, 20))
        gradeLabel.text = "分数"
        gradeLabel.font = UIFont.systemFontOfSize(14)
        gradeLabel.textAlignment = NSTextAlignment.Center
        gradeLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(gradeLabel)
        
        let creditLabel:UILabel = UILabel(frame: CGRectMake(UIScreen.mainScreen().bounds.width - 50, 0, 40, 20))
        creditLabel.text = "学分"
        creditLabel.font = UIFont.systemFontOfSize(14)
        creditLabel.textAlignment = NSTextAlignment.Center
        creditLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(creditLabel)
        
        return view
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view:UIView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 40))
        view.backgroundColor = UIColor(red: 0.9215, green: 0.9215, blue: 0.9450, alpha: 1)
        
        let creditLabel:UILabel = UILabel(frame: CGRectMake(10, 0, 100, 20))
        creditLabel.text = "总学分：\(allCredit)"
        creditLabel.textAlignment = NSTextAlignment.Left
        creditLabel.font = UIFont.systemFontOfSize(14)
        creditLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(creditLabel)
        
        GPA = Float(Int(GPA / allCredit * 100)) / 100
        let gpaLabel:UILabel = UILabel(frame: CGRectMake(10, 20, 190, 20))
        gpaLabel.text = "学分绩：\(GPA)"
        gpaLabel.textAlignment = NSTextAlignment.Left
        gpaLabel.font = UIFont.systemFontOfSize(14)
        gpaLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(gpaLabel)
        
        var ABCGPACut = ABCGPA as NSString
        let index = ABCGPACut.rangeOfString(".")
        ABCGPACut = ABCGPACut.substringWithRange(NSMakeRange(0, index.location + 3))
        let abcgpaLabel:UILabel = UILabel(frame: CGRectMake(UIScreen.mainScreen().bounds.width - 150, 0, 140, 20))
        abcgpaLabel.text = "ABC类学分绩：" + (ABCGPACut as String)
        abcgpaLabel.textAlignment = NSTextAlignment.Right
        abcgpaLabel.font = UIFont.systemFontOfSize(14)
        abcgpaLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(abcgpaLabel)
        
        ABCDGPA = Float(Int(ABCDGPA / ABCDCredit * 100)) / 100
        let abcdgpaLabel:UILabel = UILabel(frame: CGRectMake(UIScreen.mainScreen().bounds.width - 200, 20, 190, 20))
        abcdgpaLabel.text = "ABCD类学分绩：\(ABCDGPA)"
        abcdgpaLabel.textAlignment = NSTextAlignment.Right
        abcdgpaLabel.font = UIFont.systemFontOfSize(14)
        abcdgpaLabel.textColor = UIColor(red: 0.3529, green: 0.3529, blue: 0.3725, alpha: 1)
        view.addSubview(abcdgpaLabel)
        
        return view
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gradeResult.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIndentifier = "GradeCell"
        let cell:GradeCell = tableView.dequeueReusableCellWithIdentifier(cellIndentifier, forIndexPath: indexPath) as! GradeCell

        
        let now:NSDictionary = gradeResult.objectAtIndex(indexPath.row) as! NSDictionary
        let className:NSString = now.objectForKey("className") as! NSString
        let classType:NSString = now.objectForKey("classType") as! NSString
        let grade:NSString = now.objectForKey("grade") as! NSString
        let credit:NSString = now.objectForKey("credit") as! NSString
        
        cell.ClassNameLabel.text = className as String
        cell.ClassTypeLabel.text = classType as String
        cell.GradeLabel.text = grade as String
        cell.CreditLabel.text = credit as String
        
        cell.ClassNameLabel.adjustsFontSizeToFitWidth = true
        
        return cell
        
    }
    
}
