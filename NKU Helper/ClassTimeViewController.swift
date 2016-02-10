//
//  ClassTimeViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/1.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit
import Alamofire

class ClassTimeViewController: UIViewController, UIScrollViewDelegate, WXApiDelegate, NKNetworkLoadCourseDelegate {
    
    @IBOutlet var refreshBarButton: UIBarButtonItem!
    
    var classTimeView:ClassTimeView {
        get {
            return ((self.view) as! ClassTimeView)
        }
    }
    
    // MARK: Properties
    
    var testTimeHtml:NSString!
    
    let colors = Colors()
    
    // MARK: General
    
    override func viewDidLoad() {

        self.classTimeView.classScrollView.delegate = self
        self.classTimeView.headScrollView.delegate = self
        self.classTimeView.drawBackground()
        
        if canDrawClassTimeTable() {
            self.classTimeView.drawClassTimeTableOnViewController(self)
        }
        else {
            switch NKNetworkIsLogin.isLoggedin() {
            case .Loggedin:
                self.classTimeView.loadBeginAnimation()
                let courseHandler = NKNetworkLoadCourse()
                courseHandler.delegate = self
                courseHandler.getAllCourse()
            case .NotLoggedin:
                let nc = NSNotificationCenter.defaultCenter()
                nc.addObserver(self, selector: "refreshClassTimeTable:", name: "loginComplete", object: nil)
                self.performSegueWithIdentifier(SegueIdentifier.Login, sender: nil)
            case .UnKnown:
                self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
            }
        }
        
        Alamofire.request(.GET, "http://115.28.141.95/CodeIgniter/index.php/info/week").responseString { (response:Response<String, NSError>) -> Void in
            if let week = response.result.value {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationItem.title = "第\(week)周"
                    let weekInt = (week as NSString).integerValue
                    self.classTimeView.week = weekInt
                    if self.canDrawClassTimeTable() {
                        self.classTimeView.updateClassTimeTableWithWeek(weekInt)
                    }
                })
            }
        }
      
    }
    
    func canDrawClassTimeTable() -> Bool {
        let accountInfo = UserAgent.sharedInstance.getData()
        guard let _ = accountInfo else {
            self.presentViewController(ErrorHandler.alert(ErrorHandler.NotLoggedIn()), animated: true, completion: nil)
            return false
        }
        if CourseAgent.sharedInstance.getData() != nil {
            return true
        }
        else {
            return false
        }
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        self.classTimeView.orientation = toInterfaceOrientation
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.classTimeView.drawBackground()
        self.classTimeView.drawClassTimeTableOnViewController(self)
    }
    
    // MARK: NKNetworkLoadCourseDelegate
    
    func didSuccessToReceiveCourseData() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.classTimeView.loadEndAnimation()
            self.classTimeView.drawClassTimeTableOnViewController(self)
        })
    }
    
    func didFailToReceiveCourseData() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.classTimeView.loadEndAnimation()
            self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
        })
    }
    
    func loadProgressUpdate(progress: Float) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.classTimeView.loadAnimation(progress)
        })
    }
    
    // MARK: Segue
    
    var whichSection:Int!
    
    func showCourseDetail(tapGesture:UITapGestureRecognizer) {
        
        whichSection = tapGesture.view?.tag
        self.performSegueWithIdentifier(SegueIdentifier.ShowCourseDetail, sender: nil)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == SegueIdentifier.ShowCourseDetail {
            let vc:CourseDetailTableViewController = segue.destinationViewController as! CourseDetailTableViewController
            vc.whichCourse = whichSection
        }
        else if segue.identifier == "showTestTime" {
            let vc:TestTimeTableViewController = segue.destinationViewController as! TestTimeTableViewController
            vc.html = testTimeHtml
        }
    }
    
    // MARK: button
    
    @IBAction func refreshClassTimeTable(sender: AnyObject) {
        let nc:NSNotificationCenter = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self)
        guard let _ = UserAgent.sharedInstance.getData() else {
            self.presentViewController(ErrorHandler.alert(ErrorHandler.NotLoggedIn()), animated: true, completion: nil)
            return
        }
        SVProgressHUD.show()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            let loginResult = NKNetworkIsLogin.isLoggedin()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                SVProgressHUD.dismiss()
                switch loginResult {
                case .Loggedin:
                    self.refreshBarButton.enabled = false
                    self.classTimeView.loadBeginAnimation()
                    let courseHandler = NKNetworkLoadCourse()
                    courseHandler.delegate = self
                    courseHandler.getAllCourse()
                    self.refreshBarButton.enabled = true
                case .NotLoggedin:
                    let nc = NSNotificationCenter.defaultCenter()
                    nc.addObserver(self, selector: "refreshClassTimeTable:", name: "loginComplete", object: nil)
                    self.performSegueWithIdentifier(SegueIdentifier.Login, sender: nil)
                case .UnKnown:
                    self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func lookUpTestTime(sender: UIBarButtonItem) {
        SVProgressHUD.show()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            let loginResult = NKNetworkIsLogin.isLoggedin()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                SVProgressHUD.dismiss()
                switch loginResult {
                case .Loggedin:
                    let url:NSURL = NSURL(string: "http://222.30.32.10/xxcx/stdexamarrange/listAction.do")!
                    let data:NSData? = NSData(contentsOfURL: url)
                    if let _ = data {
                        let encoding:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
                        self.testTimeHtml = NSString(data: data!, encoding: encoding)!
                        self.performSegueWithIdentifier("showTestTime", sender: nil)
                    }
                    else {
                        self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
                    }
                case .NotLoggedin:
                    let nc:NSNotificationCenter = NSNotificationCenter.defaultCenter()
                    nc.addObserver(self, selector: "showTestTime", name: "loginComplete", object: nil)
                    self.performSegueWithIdentifier(SegueIdentifier.Login, sender: nil)
                case .UnKnown:
                    self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
                }
            })
        }
    }
    
    func showTestTime() {
        let nc:NSNotificationCenter = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self)
        SVProgressHUD.show()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            let url:NSURL = NSURL(string: "http://222.30.32.10/xxcx/stdexamarrange/listAction.do")!
            let data:NSData? = NSData(contentsOfURL: url)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                SVProgressHUD.dismiss()
                if let _ = data {
                    let encoding:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(0x0632)
                    self.testTimeHtml = NSString(data: data!, encoding: encoding)!
                    self.performSegueWithIdentifier("showTestTime", sender: nil)
                    
                }
                else {
                    self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func shareClassTable(sender: UIBarButtonItem) {
        
        let columnWidth:CGFloat = UIScreen.mainScreen().bounds.width / 6
        
        // 获取星期的headView
        UIGraphicsBeginImageContextWithOptions(self.classTimeView.headScrollView.contentSize, false, 0)
        let savedHeadContentOffset = self.classTimeView.headScrollView.contentOffset
        let savedHeadFrame = self.classTimeView.headScrollView.frame
        self.classTimeView.headScrollView.contentOffset = CGPointZero
        self.classTimeView.headScrollView.frame = CGRectMake(0, 0, self.classTimeView.headScrollView.contentSize.width, self.classTimeView.headScrollView.contentSize.height)
        self.classTimeView.headScrollView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let headImage = UIGraphicsGetImageFromCurrentImageContext()
        self.classTimeView.headScrollView.contentOffset = savedHeadContentOffset
        self.classTimeView.headScrollView.frame = savedHeadFrame
        UIGraphicsEndImageContext()
        
        // 获取课程表
        UIGraphicsBeginImageContextWithOptions(self.classTimeView.classScrollView.contentSize, false, 0)
        let savedContentOffset = self.classTimeView.classScrollView.contentOffset
        let savedFrame = self.classTimeView.classScrollView.frame
        self.classTimeView.classScrollView.contentOffset = CGPointZero
        self.classTimeView.classScrollView.frame = CGRectMake(0, 0, self.classTimeView.classScrollView.contentSize.width, self.classTimeView.classScrollView.contentSize.height)
        self.classTimeView.classScrollView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let classTimeTableImage = UIGraphicsGetImageFromCurrentImageContext()
        self.classTimeView.classScrollView.contentOffset = savedContentOffset
        self.classTimeView.classScrollView.frame = savedFrame
        UIGraphicsEndImageContext()
        
        // 合并星期的HeadView和课程表
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.classTimeView.classScrollView.contentSize.width, self.classTimeView.classScrollView.contentSize.height+self.classTimeView.headScrollView.contentSize.height), false, 0)
        headImage.drawAtPoint(CGPointZero)
        classTimeTableImage.drawAtPoint(CGPointMake(0, self.classTimeView.headScrollView.contentSize.height))
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), UIColor.whiteColor().CGColor)
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, columnWidth, 30))
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 绘制缩略图
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.classTimeView.classScrollView.contentSize.width, self.classTimeView.classScrollView.contentSize.height+self.classTimeView.headScrollView.contentSize.height), false, 1)
        headImage.drawAtPoint(CGPointZero)
        classTimeTableImage.drawAtPoint(CGPointMake(0, self.classTimeView.headScrollView.contentSize.height))
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), UIColor.whiteColor().CGColor)
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, columnWidth, 30))
        let thumbImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 制作微信跳转过去的信息
        let message = WXMediaMessage()
        let ext = WXImageObject()
        ext.imageData = UIImagePNGRepresentation(combinedImage)
        message.mediaObject = ext
        message.title = "课表"
        message.description = "课表"
        message.thumbData = UIImageJPEGRepresentation(thumbImage, 0.1)
        let req = SendMessageToWXReq()
        req.bText = false;
        req.message = message

        let shareParams = NSMutableDictionary()
        shareParams.SSDKSetupShareParamsByText("我的课程表", images: combinedImage, url: nil, title: "课程表", type: SSDKContentType.Image)
        ShareSDK.showShareActionSheet(nil, items: nil, shareParams: shareParams) { (state, platformType, userData, contentEntity, ErrorType, end) -> Void in
            switch (state) {
            case .Success:
                self.presentViewController(ErrorHandler.alertWithAlertTitle("分享成功", message: nil, cancelButtonTitle: "好"), animated: true, completion: nil)
            case .Fail:
                if platformType == .SubTypeQZone {
                    self.presentViewController(ErrorHandler.alertWithAlertTitle("分享失败", message: "QQ空间暂不支持图片分享", cancelButtonTitle: "好"), animated: true, completion: nil)
                }
                else {
                    self.presentViewController(ErrorHandler.alert(ErrorHandler.shareFail()), animated: true, completion: nil)
                }
            case .Cancel:
                break;
            default:
                break;
            }
        }        
    }
    
    // MARK: ScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.tag == 1 {
            self.classTimeView.headScrollView.contentOffset.x = self.classTimeView.classScrollView.contentOffset.x
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
    }
    
}