//
//  AboutViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/5/26.
//  Copyright (c) 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit
import MessageUI

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet var aboutTextView: UITextView!
    @IBOutlet var appNameVersionLabel: UILabel!
    
    override func viewDidLoad() {
        let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        appNameVersionLabel.text = "NKU Helper (V\(version))"
    }
    
    @IBAction func mailSetup(sender: UIButton) {
        
        if (!MFMailComposeViewController.canSendMail()) {
            let alertVC = ErrorHandler.alertWithAlertTitle("无法发送邮件", message: "请检查邮件设置", cancelButtonTitle: "好")
            presentViewController(alertVC, animated: true, completion: nil)
        }
        else {
            let mailView = MFMailComposeViewController()
            mailView.title = "NKU Helper的反馈信息"
            mailView.setSubject("NKU Helper的反馈信息")
            mailView.setToRecipients(["sunshinecltzac@gmail.com"])
            mailView.mailComposeDelegate = self
            self.presentViewController(mailView, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func backwardAction(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

}
