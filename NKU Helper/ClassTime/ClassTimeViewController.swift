//
//  ClassTimeViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/1.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit
import Alamofire

class ClassTimeViewController: UIViewController, WXApiDelegate, NKNetworkLoadCourseDelegate {
    
// MARK: View Property
    
    @IBOutlet var refreshBarButton: UIBarButtonItem!
    var classTimeView:ClassTimeView {
        get {
            return ((self.view) as! ClassTimeView)
        }
    }
    
// MARK: Property
    
    var testTimeHtml:NSString!
    
// MARK: VC Life Cycle
    
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
                nc.addObserver(self, selector: #selector(ClassTimeViewController.refreshClassTimeTable(_:)), name: "loginComplete", object: nil)
                self.performSegueWithIdentifier(SegueIdentifier.Login, sender: nil)
            case .UnKnown:
                self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
            }
        }
      
    }
    
    override func viewWillAppear(animated: Bool) {
        NKNetworkFetchInfo.fetchNowWeek { (nowWeek😈) in
            guard let nowWeek = nowWeek😈 else {
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.navigationItem.title = "第\(nowWeek)周"
                self.classTimeView.week = nowWeek
                if self.canDrawClassTimeTable() {
                    self.classTimeView.updateClassTimeTableWithWeek(nowWeek)
                }
            })
        }
    }
    
// MARK: 事件监听
    
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
    
// MARK: 事件监听
    
    @IBAction func refreshClassTimeTable(sender: AnyObject) {
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self)
        do {
            try UserAgent.sharedInstance.getData()
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
                        nc.addObserver(self, selector: #selector(ClassTimeViewController.refreshClassTimeTable(_:)), name: "loginComplete", object: nil)
                        self.performSegueWithIdentifier(SegueIdentifier.Login, sender: nil)
                    case .UnKnown:
                        self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
                    }
                })
            }
        } catch {
            self.presentViewController(ErrorHandler.alert(ErrorHandler.NotLoggedIn()), animated: true, completion: nil)
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
                        self.performSegueWithIdentifier(SegueIdentifier.ShowTestTime, sender: nil)
                    }
                    else {
                        self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
                    }
                case .NotLoggedin:
                    let nc:NSNotificationCenter = NSNotificationCenter.defaultCenter()
                    nc.addObserver(self, selector: #selector(ClassTimeViewController.showTestTime), name: "loginComplete", object: nil)
                    self.performSegueWithIdentifier(SegueIdentifier.Login, sender: nil)
                case .UnKnown:
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
        
        // 制作跳转过去的信息
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

// MARK: 页面间跳转
    
    var whichSection:Int!
    
    func showCourseDetail(tapGesture:UITapGestureRecognizer) {
        
        whichSection = tapGesture.view?.tag
        self.performSegueWithIdentifier(SegueIdentifier.ShowCourseDetail, sender: nil)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier {
            switch identifier {
            case SegueIdentifier.ShowCourseDetail:
                let vc = segue.destinationViewController as! CourseDetailTableViewController
                vc.whichCourse = whichSection
            case SegueIdentifier.ShowTestTime:
                let vc = segue.destinationViewController as! TestTimeTableViewController
                vc.html = testTimeHtml
            default:
                break
            }
        }
        
    }
    
// MARK: 私有方法
    
    private func canDrawClassTimeTable() -> Bool {
        
        do {
            try UserAgent.sharedInstance.getData()
            try CourseAgent.sharedInstance.getData()
            return true
        } catch StoragedDataError.NoUserInStorage {
            self.presentViewController(ErrorHandler.alert(ErrorHandler.NotLoggedIn()), animated: true, completion: nil)
            return false
        } catch StoragedDataError.NoClassesInStorage {
            return false
        } catch {
            return false
        }
        
    }
    
    @objc
    private func showTestTime() {
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
                    self.performSegueWithIdentifier(SegueIdentifier.ShowTestTime, sender: nil)
                    
                }
                else {
                    self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
                }
            })
        }
    }
}

// MARK: ScrollViewDelegate

extension ClassTimeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.tag == 1 {
            self.classTimeView.headScrollView.contentOffset.x = self.classTimeView.classScrollView.contentOffset.x
            self.classTimeView.timeScrollView.contentOffset.y = self.classTimeView.classScrollView.contentOffset.y
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
    }
}