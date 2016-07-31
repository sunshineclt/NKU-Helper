//
//  NotiCenterTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/12/8.
//  Copyright © 2015年 陈乐天. All rights reserved.
//

import UIKit
import Alamofire

class NotiCenterTableViewController: UITableViewController {
    
    var noti = [Notification]()
    
    var isUpdatingData = false
    var currentPage = 0
    var isEndOfData = false

    var progressHud:MBProgressHUD!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(NotiCenterTableViewController.fetchMoreData))
        footer.setTitle("点击或上拉刷新", forState: .Idle)
        footer.setTitle("正在加载更多通知", forState: .Refreshing)
        footer.setTitle("没有更多通知啦", forState: .NoMoreData)
        footer.stateLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        footer.stateLabel?.textColor = UIColor.whiteColor()
        footer.activityIndicatorViewStyle = .White
        footer.backgroundColor = UIColor(red: 155/255, green: 92/255, blue: 180/255, alpha: 1)
        
        self.tableView.mj_footer = footer
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        fetchMoreData()
        SVProgressHUD.show()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noti.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.notiCell.identifier, forIndexPath: indexPath) as! NotiTableViewCell
        cell.notiData = noti[indexPath.row]
        return cell
    }

    // data Getting
    func fetchMoreData() {
        if !self.isUpdatingData && !self.isEndOfData {
            self.isUpdatingData = true
            let notiFetcher = NKNetworkFetchNoti()
            notiFetcher.fetchNotiOnPage(currentPage + 1, WithBlock: { (result:NKNetworkFetchNotiResult) -> Void in
                SVProgressHUD.dismiss()
                self.isUpdatingData = false
                self.tableView.mj_footer.endRefreshing()
                self.currentPage += 1
                switch (result) {
                case .Success(notis: let notis, totalPages: let totalPages):
                    self.noti.appendContentsOf(notis)
                    self.tableView.reloadData()
                    if totalPages == self.currentPage {
                        self.isEndOfData = true
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    }
                case .Fail:
                    self.presentViewController(ErrorHandler.alert(ErrorHandler.GetNotiFailed()), animated: true, completion: nil)
                }
            })
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! NotiTableViewCell
        let url = NSURL(string: cell.notiData.url)!
        self.performSegueWithIdentifier(R.segue.notiCenterTableViewController.showNotiDetail, sender: url)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let typeInfo = R.segue.notiCenterTableViewController.showNotiDetail(segue: segue) {
            typeInfo.destinationViewController.url = sender as! NSURL
        }
    }

}
