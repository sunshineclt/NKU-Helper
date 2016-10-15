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
    var classTimeView: ClassTimeView {
        get {
            return ((self.view) as! ClassTimeView)
        }
    }
    
// MARK: VC Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.hasLogout), name: NSNotification.Name(rawValue: "logout"), object: nil)
        
        self.classTimeView.classScrollView.delegate = self
        self.classTimeView.headScrollView.delegate = self
        self.classTimeView.drawBackground()
        
        if canDrawClassTimeTable() {
            self.classTimeView.drawClassTimeTableOnViewController(self)
        }
        else {
            switch NKNetworkIsLogin.isLoggedin() {
            case .loggedin:
                self.classTimeView.loadBeginAnimation()
                let courseHandler = NKNetworkCourseHandler()
                courseHandler.delegate = self
                courseHandler.getAllCourses()
            case .notLoggedin:
                let nc = NotificationCenter.default
                nc.addObserver(self, selector: #selector(ClassTimeViewController.doRefresh), name: NSNotification.Name(rawValue: "loginComplete"), object: nil)
                self.performSegue(withIdentifier: R.segue.classTimeViewController.login, sender: nil)
            case .unKnown:
                self.present(ErrorHandler.alert(withError: ErrorHandler.NetworkError()), animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        classTimeView.drawClassTimeTableOnViewController(self)
        NKNetworkInfoHandler.fetchNowWeek { (nowWeek, isVocation) in
            guard let nowWeek = nowWeek, let isVocation = isVocation else {
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
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.classTimeView.orientation = toInterfaceOrientation
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.classTimeView.drawBackground()
        self.classTimeView.drawClassTimeTableOnViewController(self)
    }
    
    func hasLogout() {
        self.classTimeView.drawBackground()
    }
    
// MARK: NKNetworkLoadCourseDelegate
    
    func didSuccessToReceiveCourseData() {
        DispatchQueue.main.async(execute: { () -> Void in
            self.classTimeView.loadEndAnimation()
            
            // 给每个课程分配一个颜色
            // 初始化颜色的使用
            var isColorUsed = [Bool]()
            for _ in 0 ..< Color.getColorCount() {
                isColorUsed.append(false)
            }
            do {
                let colors = try Color.getAllColors()
                /**
                 为课程获取合适的颜色（若已有过，则使用那个颜色，否则随机出一个没用过的颜色）
                 
                 - parameter classID: 课程ID
                 
                 - returns: 合适的颜色
                 */
                func findProperColorForCourse(_ classID: String) -> Color {
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
                let courses = try Course.getAllCourses()
                // TODO: 不是每次都要重新分配颜色吧？
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
        DispatchQueue.main.async(execute: { () -> Void in
            self.classTimeView.loadEndAnimation()
            self.present(ErrorHandler.alert(withError: ErrorHandler.NetworkError()), animated: true, completion: nil)
        })
    }
    
    func updateLoadProgress(_ progress: Float) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.classTimeView.loadAnimation(progress)
        })
    }
    
    func didFailToSaveCourseData() {
        DispatchQueue.main.async(execute: { () -> Void in
            self.classTimeView.loadEndAnimation()
            self.present(ErrorHandler.alert(withError: ErrorHandler.DataBaseError()), animated: true, completion: nil)
        })
    }
    
// MARK: 事件监听
    
    @IBAction func refreshClassTimeTable(_ sender: AnyObject) {
        let alert = UIAlertController(title: "刷新课表确认", message: "若刷新课表，则原来记录的课程作业都会被删除，确定要继续吗？", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "是", style: .destructive) { (action) in
            self.doRefresh()
        }
        let noAction = UIAlertAction(title: "否", style: .cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
    }
    
    func doRefresh() {
        let nc = NotificationCenter.default
        nc.removeObserver(self)
        do {
            let _ = try UserAgent.sharedInstance.getUserInfo()
            SVProgressHUD.show()
            DispatchQueue.global().async { () -> Void in
                let loginResult = NKNetworkIsLogin.isLoggedin()
                DispatchQueue.main.async(execute: { () -> Void in
                    SVProgressHUD.dismiss()
                    switch loginResult {
                    case .loggedin:
                        self.refreshBarButton.isEnabled = false
                        self.classTimeView.loadBeginAnimation()
                        let courseHandler = NKNetworkCourseHandler()
                        courseHandler.delegate = self
                        courseHandler.getAllCourses()
                        self.refreshBarButton.isEnabled = true
                    case .notLoggedin:
                        let nc = NotificationCenter.default
                        nc.addObserver(self, selector: #selector(ClassTimeViewController.doRefresh), name: NSNotification.Name(rawValue: "loginComplete"), object: nil)
                        self.performSegue(withIdentifier: R.segue.classTimeViewController.login, sender: nil)
                    case .unKnown:
                        self.present(ErrorHandler.alert(withError: ErrorHandler.NetworkError()), animated: true, completion: nil)
                    }
                })
            }
        } catch {
            self.present(ErrorHandler.alert(withError: ErrorHandler.NotLoggedIn()), animated: true, completion: nil)
        }

    }
    
    @IBAction func shareClassTable(_ sender: UIBarButtonItem) {
        
        let columnWidth:CGFloat = UIScreen.main.bounds.width / 6
        
        // 获取星期的headView
        UIGraphicsBeginImageContextWithOptions(self.classTimeView.headScrollView.contentSize, false, 0)
        let savedHeadContentOffset = self.classTimeView.headScrollView.contentOffset
        let savedHeadFrame = self.classTimeView.headScrollView.frame
        self.classTimeView.headScrollView.contentOffset = CGPoint.zero
        self.classTimeView.headScrollView.frame = CGRect(x: 0, y: 0, width: self.classTimeView.headScrollView.contentSize.width, height: self.classTimeView.headScrollView.contentSize.height)
        self.classTimeView.headScrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let headImage = UIGraphicsGetImageFromCurrentImageContext()!
        self.classTimeView.headScrollView.contentOffset = savedHeadContentOffset
        self.classTimeView.headScrollView.frame = savedHeadFrame
        UIGraphicsEndImageContext()
        
        // 获取时间的view
        UIGraphicsBeginImageContextWithOptions(self.classTimeView.timeScrollView.contentSize, false, 0)
        let savedTimeContentOffset = self.classTimeView.timeScrollView.contentOffset
        let savedTimeFrame = self.classTimeView.timeScrollView.frame
        self.classTimeView.timeScrollView.contentOffset = CGPoint.zero
        self.classTimeView.timeScrollView.frame = CGRect(x: 0, y: 0, width: self.classTimeView.timeScrollView.contentSize.width, height: self.classTimeView.timeScrollView.contentSize.height)
        self.classTimeView.timeScrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let timeImage = UIGraphicsGetImageFromCurrentImageContext()!
        self.classTimeView.timeScrollView.contentOffset = savedTimeContentOffset
        self.classTimeView.timeScrollView.frame = savedTimeFrame
        UIGraphicsEndImageContext()
        
        // 获取课程表
        UIGraphicsBeginImageContextWithOptions(self.classTimeView.classScrollView.contentSize, false, 0)
        let savedContentOffset = self.classTimeView.classScrollView.contentOffset
        let savedFrame = self.classTimeView.classScrollView.frame
        self.classTimeView.classScrollView.contentOffset = CGPoint.zero
        self.classTimeView.classScrollView.frame = CGRect(x: 0, y: 0, width: self.classTimeView.classScrollView.contentSize.width, height: self.classTimeView.classScrollView.contentSize.height)
        self.classTimeView.classScrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let classTimeTableImage = UIGraphicsGetImageFromCurrentImageContext()!
        self.classTimeView.classScrollView.contentOffset = savedContentOffset
        self.classTimeView.classScrollView.frame = savedFrame
        UIGraphicsEndImageContext()
        
        // 合并星期的HeadView和课程表
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.classTimeView.classScrollView.contentSize.width + self.classTimeView.timeScrollView.contentSize.width, height: self.classTimeView.classScrollView.contentSize.height + self.classTimeView.headScrollView.contentSize.height), false, 0)
        headImage.draw(at: CGPoint(x: self.classTimeView.timeScrollView.contentSize.width, y: 0))
        classTimeTableImage.draw(at: CGPoint(x: self.classTimeView.timeScrollView.contentSize.width, y: self.classTimeView.headScrollView.contentSize.height))
        timeImage.draw(at: CGPoint(x: 0, y: self.classTimeView.headScrollView.contentSize.height))
        UIGraphicsGetCurrentContext()?.setFillColor(UIColor.white.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: columnWidth, height: 30))
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // 绘制缩略图
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.classTimeView.classScrollView.contentSize.width, height: self.classTimeView.classScrollView.contentSize.height+self.classTimeView.headScrollView.contentSize.height), false, 1)
        headImage.draw(at: CGPoint.zero)
        classTimeTableImage.draw(at: CGPoint(x: 0, y: self.classTimeView.headScrollView.contentSize.height))
        UIGraphicsGetCurrentContext()?.setFillColor(UIColor.white.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: columnWidth, height: 30))
        let thumbImage = UIGraphicsGetImageFromCurrentImageContext()!
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
        shareParams.ssdkSetupShareParams(byText: "我的课程表", images: combinedImage, url: nil, title: "课程表", type: SSDKContentType.image)
        ShareSDK.showShareActionSheet(nil, items: nil, shareParams: shareParams) { (state, platformType, userData, contentEntity, ErrorType, end) -> Void in
            switch (state) {
            case .success:
                self.present(ErrorHandler.alertWith(title: "分享成功", message: nil, cancelButtonTitle: "好"), animated: true, completion: nil)
            case .fail:
                if platformType == .subTypeQZone {
                    self.present(ErrorHandler.alertWith(title: "分享失败", message: "QQ空间暂时不支持图片分享", cancelButtonTitle: "好"), animated: true, completion: nil)
                }
                else {
                    self.present(ErrorHandler.alert(withError: ErrorHandler.shareFail()), animated: true, completion: nil)
                }
            case .cancel:
                break;
            default:
                break;
            }
        }        
    }

// MARK: 页面间跳转
    
    func showCourseDetail(_ tapGesture:UITapGestureRecognizer) {
        self.performSegue(withIdentifier: R.segue.classTimeViewController.showCourseDetail, sender: (tapGesture.view as! ClassView).courseTime)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.hidesBottomBarWhenPushed = true
        if let typeInfo = R.segue.classTimeViewController.showCourseDetail(segue: segue) {
            if let whichCourse = sender as? CourseTime {
                typeInfo.destination.courseTime = whichCourse
            }
        }
    }
    
// MARK: 私有方法
    
    private func canDrawClassTimeTable() -> Bool {
        do {
            let _ = try UserAgent.sharedInstance.getUserInfo()
            let _ = try Course.getAllCourses()
            return true
        } catch StoragedDataError.noUserInStorage {
            self.present(ErrorHandler.alert(withError: ErrorHandler.NotLoggedIn()), animated: true, completion: nil)
            return false
        } catch {
            return false
        }
    }

}

// MARK: ScrollViewDelegate

extension ClassTimeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 1 {
            self.classTimeView.headScrollView.contentOffset.x = self.classTimeView.classScrollView.contentOffset.x
            self.classTimeView.timeScrollView.contentOffset.y = self.classTimeView.classScrollView.contentOffset.y
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
}
