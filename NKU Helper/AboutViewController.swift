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
    
    override func viewDidLoad() {
        aboutTextView.text = "感谢 http://pm25.in/ 对PM2.5数据的支持\n感谢 中国气象局公共气象服务中心对天气数据的支持\n感谢 阿里云云服务器的支持（要是能便宜点就更好了）\n感谢 支付宝快捷支付的支持\n感谢 大家一贯的支持！"
    }
    
    @IBAction func mailSetup(sender: UIButton) {
        
        if (!MFMailComposeViewController.canSendMail()) {
            var alertView:UIAlertView = UIAlertView(title: "无法发送邮件", message: "请检查邮件设置", delegate: nil, cancelButtonTitle: "确定")
            alertView.show()
        }
        else {
            
            var mailView = MFMailComposeViewController()
            mailView.title = "NKU Helper的反馈信息"
            mailView.setSubject("NKU Helper的反馈信息")
            mailView.setToRecipients(["sunshinecltzac@gmail.com"])
            mailView.mailComposeDelegate = self
            self.presentViewController(mailView, animated: true, completion: nil)
        }
        
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func backwardAction(sender: UIButton) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

}
