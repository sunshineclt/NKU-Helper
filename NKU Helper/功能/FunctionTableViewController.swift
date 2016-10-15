//
//  FunctionTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/1.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class FunctionTableViewController: UITableViewController {

    /// 是否已经输入用户名和密码
    var isLoggedIn:Bool {
        do {
            let _ =  try UserAgent.sharedInstance.getUserInfo()
            return true
        } catch {
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 150
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        do {
            let _ = try UserAgent.sharedInstance.getUserInfo()
            self.tableView.reloadData()
            super.viewWillAppear(animated)
        } catch {
            self.present(ErrorHandler.alert(withError: ErrorHandler.NotLoggedIn()), animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let action = NKRouter.sharedInstance.action {
            if action["type2"]! as Int == 0 {
                self.performSegue(withIdentifier: R.segue.functionTableViewController.showNotiCenter.identifier, sender: nil)
            }
            NKRouter.sharedInstance.action = nil
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: //查询成绩
            cell.backgroundColor = UIColor(red: 131/255, green: 176/255, blue: 252/255, alpha: 1)
        case 1: //通知中心
            cell.backgroundColor = UIColor(red: 173/255, green: 114/255, blue: 195/255, alpha: 1)
//        case 2: // 选课
//            cell.backgroundColor = UIColor(red: 154/255, green: 202/255, blue: 39/255, alpha: 1)
        case 2: //评教
            cell.backgroundColor = UIColor(red: 255/255, green: 110/255, blue: 0/255, alpha: 1)
        case 3: //查询考试时间
            cell.backgroundColor = UIColor(red: 58/255, green: 153/255, blue: 216/255, alpha: 1)
        case 4: //更多
            cell.backgroundColor = UIColor(red: 250/255, green: 191/255, blue: 131/255, alpha: 1)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: //查询成绩
            let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.gradeShowerCell.identifier)!
            cell.isUserInteractionEnabled = isLoggedIn
            return cell
        case 1: //通知中心
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.notiCenterCell.identifier)!
            cell.isUserInteractionEnabled = isLoggedIn
            return cell
//        case 2: // 选课
//            let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.selectCourseCenterCell.identifier)!
//            cell.userInteractionEnabled = isLoggedIn
//            return cell
        case 2: //评教
            let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.evaluateCenterCell.identifier)!
            cell.isUserInteractionEnabled = isLoggedIn
            return cell
        case 3: //查询考试时间
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.testTimeSearchCell.identifier)!
            cell.isUserInteractionEnabled = isLoggedIn
            return cell
        case 4: //更多
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.moreFunctionCell.identifier)!
            cell.isUserInteractionEnabled = isLoggedIn
            return cell
        default:return UITableViewCell()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.hidesBottomBarWhenPushed = true
    }
    
}
