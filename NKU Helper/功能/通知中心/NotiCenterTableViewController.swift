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
        footer?.setTitle("点击或上拉刷新", for: .idle)
        footer?.setTitle("正在加载更多通知", for: .refreshing)
        footer?.setTitle("没有更多通知啦", for: .noMoreData)
        footer?.stateLabel?.font = UIFont(name: "HelveticaNeue", size: 15)
        footer?.stateLabel?.textColor = UIColor.white
        footer?.activityIndicatorViewStyle = .white
        footer?.backgroundColor = UIColor(red: 155/255, green: 92/255, blue: 180/255, alpha: 1)
        
        self.tableView.mj_footer = footer
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        fetchMoreData()
        SVProgressHUD.show()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noti.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.notiCell.identifier, for: indexPath) as! NotiTableViewCell
        cell.notiData = noti[indexPath.row]
        return cell
    }

    // data Getting
    func fetchMoreData() {
        if !self.isUpdatingData && !self.isEndOfData {
            self.isUpdatingData = true
            NKNetworkNotiHandler.fetchNoti(onPage: currentPage + 1, WithBlock: { (result) in
                SVProgressHUD.dismiss()
                self.isUpdatingData = false
                self.tableView.mj_footer.endRefreshing()
                self.currentPage += 1
                switch (result) {
                case .success(notis: let notis, totalPages: let totalPages):
                    self.noti.append(contentsOf: notis)
                    self.tableView.reloadData()
                    if totalPages == self.currentPage {
                        self.isEndOfData = true
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    }
                case .fail:
                    self.present(ErrorHandler.alert(withError: ErrorHandler.GetNotiFailed()), animated: true, completion: nil)
                }
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! NotiTableViewCell
        let url = URL(string: cell.notiData.url)!
        self.performSegue(withIdentifier: R.segue.notiCenterTableViewController.showNotiDetail, sender: url)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let typeInfo = R.segue.notiCenterTableViewController.showNotiDetail(segue: segue) {
            typeInfo.destination.url = sender as! URL
        }
    }

}
