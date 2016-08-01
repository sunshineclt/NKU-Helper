//
//  ClassTimeViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/3/1.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit
import RealmSwift

class ClassTimeViewController: UIViewController, WXApiDelegate, NKNetworkLoadCourseDelegate {
    
// MARK: View Property
    
    @IBOutlet var refreshBarButton: UIBarButtonItem!
    var classTimeView:ClassTimeView {
        get {
            return ((self.view) as! ClassTimeView)
        }
    }
    
// MARK: VC Life Cycle
    
    override func viewDidLoad() {

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.hasLogout), name: "logout", object: nil)
        
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
                nc.addObserver(self, selector: #selector(ClassTimeViewController.doRefresh), name: "loginComplete", object: nil)
                self.performSegueWithIdentifier(R.segue.classTimeViewController.login, sender: nil)
            case .UnKnown:
                self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
            }
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        classTimeView.drawClassTimeTableOnViewController(self)
        NKNetworkFetchInfo.fetchNowWeek { (nowWeek😈, isVocation😈) in
            guard let nowWeek = nowWeek😈, isVocation = isVocation😈 else {
                return
            }
            if isVocation {
                self.navigationItem.title = "假期"
                return
            }
            self.navigationItem.title = "第\(nowWeek)周"
            self.classTimeView.week = nowWeek
            if self.canDrawClassTimeTable() {
                self.classTimeView.updateClassTimeTableWithWeek(nowWeek)
            }
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
    
    func hasLogout() {
        self.classTimeView.drawBackground()
    }
    
// MARK: NKNetworkLoadCourseDelegate
    
    func didSuccessToReceiveCourseData() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.classTimeView.loadEndAnimation()
            
            // 给每个课程分配一个颜色
            // 初始化颜色的使用
            var isColorUsed = [Bool]()
            for _ in 0 ..< Color.getColorCount() {
                isColorUsed.append(false)
            }
            do {
                let colors = try Color.getColors()
                /**
                 为课程获取合适的颜色（若已有过，则使用那个颜色，否则随机出一个没用过的颜色）
                 
                 - parameter classID: 课程ID
                 
                 - returns: 合适的颜色
                 */
                func findProperColorForCourse(classID: String) -> Color {
                    var count = 0
                    var colorIndex = Int(arc4random_uniform(UInt32(colors.count)))
                    
                    while (isColorUsed[colorIndex]) || (!colors[colorIndex].liked) {
                        colorIndex = Int(arc4random_uniform(UInt32(colors.count)))
                        count += 1
                        if count > 100 {
                            break
                        }
                    }
                    isColorUsed[colorIndex] = true
                    return colors[colorIndex]
                }
                let courses = try CourseAgent.sharedInstance.getData()
                for i in 0 ..< courses.count {
                    let current = courses[i]
                    let classID = current.ID
                    try Realm().write({ 
                        current.color = findProperColorForCourse(classID)
                    })
                }
            } catch {
            }
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
    
    func didFailToSaveCourseData() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.classTimeView.loadEndAnimation()
            self.presentViewController(ErrorHandler.alert(ErrorHandler.DataBaseError()), animated: true, completion: nil)
        })
    }
    
// MARK: 事件监听
    
    @IBAction func refreshClassTimeTable(sender: AnyObject) {
        let alert = UIAlertController(title: "刷新课表确认", message: "若刷新课表，则原来记录的课程作业都会被删除，确定要继续吗？", preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: "是", style: .Destructive) { (action) in
            self.doRefresh()
        }
        let noAction = UIAlertAction(title: "否", style: .Cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func doRefresh() {
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
                        nc.addObserver(self, selector: #selector(ClassTimeViewController.doRefresh), name: "loginComplete", object: nil)
                        self.performSegueWithIdentifier(R.segue.classTimeViewController.login, sender: nil)
                    case .UnKnown:
                        self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
                    }
                })
            }
        } catch {
            self.presentViewController(ErrorHandler.alert(ErrorHandler.NotLoggedIn()), animated: true, completion: nil)
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
    
    func showCourseDetail(tapGesture:UITapGestureRecognizer) {
        
        self.performSegueWithIdentifier(R.segue.classTimeViewController.showCourseDetail, sender: (tapGesture.view as! ClassView).courseTime)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let typeInfo = R.segue.classTimeViewController.showCourseDetail(segue: segue) {
            if let whichCourse = sender as? CourseTime {
                typeInfo.destinationViewController.courseTime = whichCourse
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
        } catch StoragedDataError.NoCoursesInStorage {
            return false
        } catch {
            return false
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