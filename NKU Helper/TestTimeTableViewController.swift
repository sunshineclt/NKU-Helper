//
//  TestTimeTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/6/7.
//  Copyright (c) 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

class TestTimeTableViewController: UITableViewController {

    var html:NSString!
    var testTime:[[String:String]]! = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        loadHtml()
        
    }
    
    func loadHtml() {
        var regularExp1:NSRegularExpression?
        do{
            try regularExp1 = NSRegularExpression(pattern: "<tr bgcolor=\"#FFFFFF\" >", options: NSRegularExpressionOptions.CaseInsensitive)
        }
        catch {
            
        }
        var resultExp = regularExp1!.matchesInString(html as String, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, html.length))
        for i in 0 ..< resultExp.count {
            let temp:NSString = html.substringWithRange(NSMakeRange(resultExp[i].range.location, 750))
     //       print("\n**********************\n")
     //       print(temp)
            var regularExp2:NSRegularExpression? = nil
            do{
                try regularExp2 = NSRegularExpression(pattern: "(<td align=\"center\" class=\"NavText\">).*?(</td>)", options: NSRegularExpressionOptions.CaseInsensitive)
            }
            catch {
                
            }
            var index = regularExp2!.matchesInString(temp as String, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, temp.length))
            var dictionary:[String:String] = [:]
            for j in 0 ..< index.count {
                switch j {
                case 1,2,4,5:continue
                case 0,3,6,7,8:
                    let exact:NSString = temp.substringWithRange(index[j].range)
                    let firstRange = exact.rangeOfString("NavText\">")
                    let secondRange = exact.rangeOfString("</td>")
                    let exactNeed:NSString = exact.substringWithRange(NSMakeRange(firstRange.location + 9, secondRange.location - firstRange.location - 9))
                    switch j {
                    case 0:
                        dictionary["className"] = exactNeed as String
                    case 3:
                        switch exactNeed {
                        case "1":dictionary["weekday"] = "星期一"
                        case "2":dictionary["weekday"] = "星期二"
                        case "3":dictionary["weekday"] = "星期三"
                        case "4":dictionary["weekday"] = "星期四"
                        case "5":dictionary["weekday"] = "星期五"
                        case "6":dictionary["weekday"] = "星期六"
                        case "7":dictionary["weekday"] = "星期天"
                        default:continue
                        }
                    case 6:dictionary["classroom"] = exactNeed as String
                    case 7:
                        let exactNeedShort = exactNeed.substringWithRange(NSMakeRange(5, 11))
                        dictionary["startTime"] = exactNeedShort
                    case 8:
                        let exactNeedShort = exactNeed.substringWithRange(NSMakeRange(5, 11))
                        dictionary["endTime"] = exactNeedShort
                    default:continue
                    }
                default:continue
                }
            }
            testTime.append(dictionary)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testTime.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:TestTimeTableViewCell = tableView.dequeueReusableCellWithIdentifier("testTime") as! TestTimeTableViewCell
        
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
