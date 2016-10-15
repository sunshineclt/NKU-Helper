//
//  ColorChooseTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/20.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit
import RealmSwift

class ColorChooseTableViewController: UITableViewController {
    
    var colors: Results<Color>!
    
    override func viewDidLoad() {
        do {
            colors = try Color.getAllColors()
        } catch {
            present(ErrorHandler.alert(withError: ErrorHandler.DataBaseError()), animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "勾选你喜欢的颜色，勾掉你不喜欢的颜色喽~\n这些颜色将会用于课程和任务颜色的选择哦~"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Color.getColorCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.preferredColorCell.identifier) as! ColorChooseTableViewCell
        let color = colors[indexPath.row]
        cell.colorView.backgroundColor = color.convertToUIColor()
        cell.accessoryType = color.liked ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView(self.tableView, cellForRowAt: indexPath)
        if cell.accessoryType == UITableViewCellAccessoryType.none {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            colors[indexPath.row].toggleLike()
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.none
            colors[indexPath.row].toggleLike()
        }
        self.tableView.deselectRow(at: indexPath, animated: false)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}
