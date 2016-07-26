//
//  ToDoCell.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/9/28.
//  Copyright © 2015年 陈乐天. All rights reserved.
//

import UIKit

protocol CheckBoxClickedDelegate {
    func saveCheckState(cell: ToDoCell)
}

class ToDoCell: UITableViewCell {

    @IBOutlet var checkBox: UIImageView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ToDoCell.CheckBoxClicked))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            tapGesture.delegate = self
            checkBox.addGestureRecognizer(tapGesture)
            checkBox.image = R.image.checkBox()
        }
    }
    @IBOutlet var nameTextField: UITextField!

    var thing: ThingToDo! {
        didSet {
            self.nameTextField.text = thing.name
            self.checkBoxState = thing.done
            self.checkBox.image = checkBoxState! ? R.image.checkedBox() : R.image.checkBox()
        }
    }
    
    var checkBoxState: Bool! = false
    var delegate: CheckBoxClickedDelegate!
    
    func CheckBoxClicked() {
        checkBox.image = checkBoxState! ? R.image.checkBox() : R.image.checkedBox()
        checkBoxState = !checkBoxState
        delegate?.saveCheckState(self)
    }
    
}
