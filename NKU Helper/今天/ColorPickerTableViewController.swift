//
//  ColorPickerTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 16/8/1.
//  Copyright © 2016年 陈乐天. All rights reserved.
//

import UIKit
import RealmSwift

class ColorPickerTableViewController: UITableViewController, UINavigationControllerDelegate {

    // MARK: VC状态 property
    
    var nowChoosedColorIndexRow: Int = 0
    
    // MARK: Model
    
    var colors: Results<Color>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        // tableViewCell高度自适应
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        // 数据初始化
        do {
            colors = try Color.getColors().filter("liked == true")
        } catch {
            presentViewController(ErrorHandler.alert(ErrorHandler.DataBaseError()), animated: true, completion: nil)
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard colors != nil else {
            return 0
        }
        return colors.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.taskColorCell.identifier) as! ColorChooseTableViewCell
        let color = colors[indexPath.row]
        cell.colorView.backgroundColor = color.convertToUIColor()
        cell.accessoryType = indexPath.row == nowChoosedColorIndexRow ? .Checkmark : .None
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let preChoosedColorIndexRow = nowChoosedColorIndexRow
        nowChoosedColorIndexRow = indexPath.row
        self.tableView.reloadRowsAtIndexPaths([indexPath, NSIndexPath(forRow: preChoosedColorIndexRow, inSection: 0)], withRowAnimation: .None)
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? NewTaskTableViewController {
            controller.color = colors[nowChoosedColorIndexRow]
        }
    }
    
}
