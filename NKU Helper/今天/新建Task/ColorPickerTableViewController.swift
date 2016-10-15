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
            colors = try Color.getAllColors().filter("liked == true")
        } catch {
            present(ErrorHandler.alert(withError: ErrorHandler.DataBaseError()), animated: true, completion: nil)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard colors != nil else {
            return 0
        }
        return colors.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.taskColorCell.identifier) as! ColorChooseTableViewCell
        let color = colors[indexPath.row]
        cell.colorView.backgroundColor = color.convertToUIColor()
        cell.accessoryType = indexPath.row == nowChoosedColorIndexRow ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let preChoosedColorIndexRow = nowChoosedColorIndexRow
        nowChoosedColorIndexRow = indexPath.row
        self.tableView.reloadRows(at: [indexPath, IndexPath(row: preChoosedColorIndexRow, section: 0)], with: .none)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? NewTaskTableViewController {
            controller.color = colors[nowChoosedColorIndexRow]
        }
    }
    
}
