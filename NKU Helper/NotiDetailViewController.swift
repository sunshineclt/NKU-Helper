//
//  NotiDetailViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/12/9.
//  Copyright © 2015年 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit
import WebKit

class NotiDetailViewController: UIViewController, NJKWebViewProgressDelegate, UIWebViewDelegate {
    
    var url:NSURL!
    var webView = UIWebView()
    var progressProxy:NJKWebViewProgress!
    var progressView:NJKWebViewProgressView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        progressProxy = NJKWebViewProgress()
        progressProxy.progressDelegate = self
        progressProxy.webViewProxyDelegate = self
        let navBounds = self.navigationController!.navigationBar.bounds
        let barFrame = CGRectMake(0, navBounds.size.height - 2, navBounds.size.width, 2)
        progressView = NJKWebViewProgressView(frame: barFrame)
        progressView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleTopMargin]
        progressView.setProgress(0, animated: true)
        self.navigationController?.navigationBar.addSubview(progressView)
        
        webView = UIWebView(frame: self.view.frame)
        webView.delegate = progressProxy
        webView.loadRequest(NSURLRequest(URL: url))
        self.view.addSubview(webView)
        
    }
    
    func webViewProgress(webViewProgress: NJKWebViewProgress!, updateProgress progress: Float) {
        progressView.setProgress(progress, animated: true)
        self.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
    }
    
}
