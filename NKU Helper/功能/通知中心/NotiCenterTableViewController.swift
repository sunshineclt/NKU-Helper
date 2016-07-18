//
//  NotiCenterTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/12/8.
//  Copyright © 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit
import Alamofire

class NotiCenterTableViewController: UITableViewController {
    
    var noti:[Notification] = []
    
    var isUpdatingData:Bool! = false
    var currentPage:Int = 0
    var isEndOfData:Bool! = false

    var progressHud:MBProgressHUD!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(NotiCenterTableViewController.fetchMoreData))
        footer.setTitle("正在加载更多通知", forState: MJRefreshState.Refreshing)
        footer.setTitle("没有更多通知啦", forState: MJRefreshState.NoMoreData)
        footer.stateLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        footer.stateLabel?.textColor = UIColor.whiteColor()
        footer.activityIndicatorViewStyle = .White
        footer.backgroundColor = UIColor(red: 155/255, green: 92/255, blue: 180/255, alpha: 1)
        
        self.tableView.mj_footer = footer
        
        fetchMoreData()
        
        progressHud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noti.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.NotiCell, forIndexPath: indexPath) as! NotiTableViewCell
        cell.notiData = noti[indexPath.row]
        cell.displayView.layer.cornerRadius = 10
        return cell
    }

    // data Getting
    func fetchMoreData() {
        if !self.isUpdatingData && !self.isEndOfData {
            self.isUpdatingData = true
            let notiFetcher = NKNetworkFetchNoti()
            notiFetcher.fetchNotiOnPage(currentPage, WithBlock: { (result:NKNetworkFetchNotiResult) -> Void in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.isUpdatingData = false
                self.tableView.mj_footer.endRefreshing()
                self.currentPage += 1
                switch (result) {
                case .Success(notis: let notis):
                    self.noti = notis
                    self.tableView.reloadData()
                case .End:
                    self.isEndOfData = true
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                case .Fail:
                    self.presentViewController(ErrorHandler.alert(ErrorHandler.GetNotiFailed()), animated: true, completion: nil)
                }
            })
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! NotiTableViewCell
        let url = NSURL(string: cell.notiData.url)!
        self.performSegueWithIdentifier(SegueIdentifier.ShowNotiDetail, sender: url)
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? NotiDetailViewController {
            vc.url = sender as! NSURL
        }
    }

}
