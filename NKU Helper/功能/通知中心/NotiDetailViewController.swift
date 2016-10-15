//
//  NotiDetailViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/12/9.
//  Copyright © 2015年 陈乐天. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

class NotiDetailViewController: UIViewController, NJKWebViewProgressDelegate, UIWebViewDelegate {
    
    var url:URL!
    var webView = UIWebView()
    var progressProxy: NJKWebViewProgress!
    var progressView: NJKWebViewProgressView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        progressProxy = NJKWebViewProgress()
        progressProxy.progressDelegate = self
        progressProxy.webViewProxyDelegate = self
        
        webView = UIWebView()
        self.view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        }
        webView.delegate = progressProxy
        
        progressView = NJKWebViewProgressView()
        self.view.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.snp.left).offset(0)
            make.right.equalTo(self.view.snp.right).offset(0)
            make.top.equalTo(self.view.snp.top).offset(0)
            make.height.equalTo(2)
        }
        progressView.setProgress(0, animated: true)
        
        webView.loadRequest(URLRequest(url: url))
        
    }
    
    func webViewProgress(_ webViewProgress: NJKWebViewProgress!, updateProgress progress: Float) {
        progressView.setProgress(progress, animated: true)
        self.title = webView.stringByEvaluatingJavaScript(from: "document.title")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        progressView.removeFromSuperview()
    }
    
}
