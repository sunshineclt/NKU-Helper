//
//  AboutViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/5/26.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit
import MessageUI

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet var appNameVersionLabel: UILabel!
    
    override func viewDidLoad() {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        appNameVersionLabel.text = "NKU Helper (V\(version))"
    }
    
    @IBAction func mailSetup(_ sender: UIButton) {
        if (!MFMailComposeViewController.canSendMail()) {
            let alertVC = ErrorHandler.alertWith(title: "无法发送邮件", message: "请检查邮件设置", cancelButtonTitle: "好")
            present(alertVC, animated: true, completion: nil)
        }
        else {
            let mailView = MFMailComposeViewController()
            mailView.title = "NKU Helper的反馈信息"
            mailView.setSubject("NKU Helper的反馈信息")
            mailView.setToRecipients(["sunshinecltzac@gmail.com"])
            mailView.mailComposeDelegate = self
            self.present(mailView, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openOpenSourceURL(_ sender: UIButton) {
        UIApplication.shared.openURL(URL(string: "https://github.com/sunshineclt/NKU-Helper")!)
    }
    
    @IBAction func backwardAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
