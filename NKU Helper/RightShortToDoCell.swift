//
//  RightShortToDoCell.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/9/28.
//  Copyright © 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

protocol CheckBoxClickedDelegate {
    func saveCheckState(cell: RightShortToDoCell)
}

class RightShortToDoCell: UITableViewCell {

    @IBOutlet var checkBox: UIImageView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: "CheckBoxClicked")
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            tapGesture.delegate = self
            checkBox.addGestureRecognizer(tapGesture)
            checkBox.image = UIImage(named: "checkBox")
        }
    }
    @IBOutlet var nameTextField: UITextField!

    var thing: ThingToDo! {
        didSet {
            self.nameTextField.text = thing.name
            self.checkBoxState = thing.done
            self.checkBox.image = checkBoxState! ? UIImage(named: "CheckedBox") : UIImage(named: "CheckBox")
        }
    }
    
    var checkBoxState: Bool! = false
    var delegate: CheckBoxClickedDelegate!
    
    func CheckBoxClicked() {
        checkBox.image = checkBoxState! ? UIImage(named: "CheckBox") : UIImage(named: "CheckedBox")
        checkBoxState = !checkBoxState
        delegate?.saveCheckState(self)
    }
    
}
