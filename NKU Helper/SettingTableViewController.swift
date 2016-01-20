//
//  SettingTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/1.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
        case 0:return "账户信息"
        case 1:return "偏好设置"
        case 2:return "支持NKU Helper"
        case 3:return "关于NKU Helper"
        default:return ""
        }
    }

    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch (section) {
        case 0:return "NKU Helper只在本地保存您的用户信息，请放心填写"
        case 2:return "NKU Helper本身是完全免费的，但开发和运营都需要投入。如果您觉得好用并想鼓励我们做得更好，不妨通过捐赠来支持我们的团队。无论多少，我们都非常感谢！"
        case 3:return "如果大家对NKU Helper的使用有吐槽，或是希望有什么功能，欢迎大家到“关于”页面中戳我的邮箱，您的意见将是我们前进的动力！我将尽快给您回复！"
        case 4:return "NKU Helper是非跨平台的，我们对此感到抱歉，如果有同学希望开发其他平台的应用，可以在“关于”页面中找到我的联系方式，欢迎所有希望为大家提供便利的同学一起努力，为大家提供服务！"
        default:return ""
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0,1,2,3:
            return 1
        case 4:
            return 0
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let accountInfo = UserDetailInfoAgent.sharedInstance.getData()
            if let user = accountInfo {
                let cell = tableView.dequeueReusableCellWithIdentifier("Account") as! AccountTableViewCell
                let timeEnteringSchool = (user.TimeEnteringSchool as NSString).substringWithRange(NSMakeRange(2, 2))
                cell.nameLabel.text = user.Name
                cell.userIDLabel.text = user.UserID
                cell.departmentLabel.text = user.DepartmentAdmitted + (timeEnteringSchool as String) + "级本科生"
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier("AddAccount")!
                cell.textLabel?.text = "请先登录！"
                cell.detailTextLabel?.text = "欢迎使用NKU Helper！"
                return cell
            }
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("color")!
            return cell
        case 2:
            let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("support")!
            cell.textLabel?.text = "请开发团队喝一杯咖啡"
            return cell
        case 3:
            let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("about")!
            cell.textLabel?.text = "关于"
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("1234")!
            return cell
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            let url:NSURL = NSURL(string: "https://qr.alipay.com/ae5g3m2kfloxr5tte5")!
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
}
