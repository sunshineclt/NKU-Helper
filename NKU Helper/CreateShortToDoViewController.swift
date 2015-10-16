//
//  CreateShortToDoViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/9/28.
//  Copyright © 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

class CreateShortToDoViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var nameField: UITextField!
    
    var popoverController: UIPopoverController!
    
    override var preferredContentSize:CGSize {
        get {
            if nameField != nil && presentingViewController != nil {
                return CGSizeMake(200, nameField.frame.maxY + 10)
            }
            else {
                return super.preferredContentSize
            }
        }
        set {
            super.preferredContentSize = newValue
        }
    }
    
    @IBAction func thingsCreated(sender: UITextField) {
        
        if (nameField.text != nil) && (nameField.text != "") {
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let beforeThings = (userDefaults.objectForKey("things") as? NSMutableArray) ?? NSMutableArray()
            let thing = ThingToDo(name: nameField.text ?? "", time: nil, place: nil, type: .Short)
            let data = NSKeyedArchiver.archivedDataWithRootObject(thing)
            beforeThings.addObject(data)
            let thingsToSave:NSArray = beforeThings
            userDefaults.removeObjectForKey("things")
            userDefaults.setObject(thingsToSave, forKey: "things")
            
        }
        popoverController.dismissPopoverAnimated(true)
    }
    
    
}
