//
//  EvaluateTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/21/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

class EvaluateTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "evaluateSubmitDidSuccess", name: "evaluateSubmitSuccess", object: nil)
        SVProgressHUD.show()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            let loginResult = NKNetworkIsLogin.isLoggedin()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                SVProgressHUD.dismiss()
                switch loginResult {
                case .Loggedin:
                    let evaluater = NKNetworkEvaluate()
                    evaluater.delegate = self
                    SVProgressHUD.show()
                    evaluater.getEvaluateList()
                case .NotLoggedin:
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginComplete", name: "loginComplete", object: nil)
                    self.performSegueWithIdentifier(SegueIdentifier.Login, sender: "EvaluateTableViewController")
                case .UnKnown:
                    self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
                }
            })
        }
    }
    
    func loginComplete() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "loginComplete", object: nil)
        let evaluater = NKNetworkEvaluate()
        evaluater.delegate = self
        SVProgressHUD.show()
        evaluater.getEvaluateList()
    }

    func evaluateSubmitDidSuccess() {
        let evaluater = NKNetworkEvaluate()
        evaluater.delegate = self
        SVProgressHUD.show()
        evaluater.getEvaluateList()
    }
    
    var classesToEvaluate = [ClassToEvaluate]()
    
    var selectedIndex: Int?

}

extension EvaluateTableViewController: NKNetworkEvaluateProtocol {
    
    func didNetworkFail() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.dismiss()
            self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
        }
    }
    
    func evaluateSystemNotOpen() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            SVProgressHUD.dismiss()
            self.presentViewController(ErrorHandler.alert(ErrorHandler.EvaluateSystemNotOpen()), animated: true, completion: nil)
        }
    }
    
    func didGetEvaluateList(lessonsToEvaluate: [ClassToEvaluate]) {
        SVProgressHUD.dismiss()
        self.classesToEvaluate = lessonsToEvaluate
        self.tableView.reloadData()
    }

}

extension EvaluateTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classesToEvaluate.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.classToEvaluate) as! ClassToEvaluateTableViewCell
        cell.classToEvaluate = classesToEvaluate[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ClassToEvaluateTableViewCell
        selectedIndex = cell.classToEvaluate.index
        if !cell.classToEvaluate.hasEvaluated {
            self.performSegueWithIdentifier(SegueIdentifier.evaluateDetail, sender: nil)
        }
        else {
            self.presentViewController(ErrorHandler.alert(ErrorHandler.EvaluateHasDone()), animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == SegueIdentifier.evaluateDetail {
            let destinationVC = segue.destinationViewController as! EvaluateDetailTableViewController
            destinationVC.classIndexToEvaluate = selectedIndex
        }
    }
    
}

extension EvaluateTableViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "没有评教信息", attributes: [NSForegroundColorAttributeName : UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1), NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 15)!])

    }
}
