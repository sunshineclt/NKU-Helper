//
//  AppDelegate.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/2/14.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate{

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        JSPatch.start(withAppKey: "bdeda28b488dda55")
        JSPatch.sync()
        
        let rootvc = self.window?.rootViewController as! UITabBarController
        let firstViewController = rootvc.childViewControllers[0]
        
        // To set up Flurry(App Analyse), Fabric.Crashlytics(Crash Analyse), AVOS(Push Service), ShareSDK
        func setUpAllTools() {
            
            Fabric.with([Crashlytics.self])
            
            WXApi.registerApp("wx311e5377578127f1")
            
            ShareSDK.registerApp("f61adcd245a4", activePlatforms: [SSDKPlatformType.typeWechat.rawValue,
                                                                   SSDKPlatformType.typeQQ.rawValue,
                                                                   SSDKPlatformType.typeFacebook.rawValue,
                                                                   SSDKPlatformType.typeMail.rawValue,
                                                                   SSDKPlatformType.typeCopy.rawValue,
                                                                   SSDKPlatformType.typePrint.rawValue],
                                 onImport: { (platform) in
                                    switch platform {
                                    case .typeWechat:
                                        ShareSDKConnector.connectWeChat(WXApi.classForCoder())
                                    case .typeQQ:
                                        ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
                                    default:
                                        break;
                                    }
                }) { (platform, appInfo) in
                    switch platform {
                    case SSDKPlatformType.typeWechat:
                        //设置微信应用信息
                        appInfo?.ssdkSetupWeChat(byAppId: "wx311e5377578127f1", appSecret: "83c6080bc1957d3f8f7306f946eb3667")
                    case SSDKPlatformType.typeQQ:
                        //设置QQ应用信息
                        appInfo?.ssdkSetupQQ(byAppId: "1104934641", appKey: "W66uuRWLP9ZnFlkC", authType: SSDKAuthTypeBoth)
                    case SSDKPlatformType.typeFacebook:
                        //设置Facebook应用信息，其中authType设置为只用SSO形式授权
                        appInfo?.ssdkSetupFacebook(byApiKey: "576897682460678", appSecret: "20c9e13a474f9d603e488272a033d7d9", authType: SSDKAuthTypeSSO)
                    default:
                        break
                    }

            }
        }
        
        // set up App Appearance
        func setUpApperance() {
            UINavigationBar.appearance().barTintColor = UIColor(red: 156/255, green: 89/255, blue: 182/255, alpha: 1)
            UINavigationBar.appearance().tintColor = UIColor.white
            UINavigationBar.appearance().isTranslucent = false
            UIBarButtonItem.appearance().tintColor = UIColor.white
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 17)!]
            UITabBar.appearance().isTranslucent = false
        }
        
        // load Preferred Colors
        func loadPreferredColors() {
            do {
                let _ = try Color.getAllColors()
            } catch StoragedDataError.noColorInStorage {
                do {
                    try Color.copyColorsToDocument()
                } catch {
                    firstViewController.present(ErrorHandler.alert(withError: ErrorHandler.DataBaseError()), animated: true, completion: nil)
                }
            } catch {
                firstViewController.present(ErrorHandler.alert(withError: ErrorHandler.DataBaseError()), animated: true, completion: nil)
            }
        }
        
        // set up notification
        func setUpNotification() {
            let settings = UIUserNotificationSettings(types: [.badge, .alert, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        // 从1.x版本迁移到2.0版本
        func transferFromVersion1ToVersion2() {
            // 迁移preferredColors数据
            let userDefaults = UserDefaults.standard
            if let _ = userDefaults.object(forKey: "preferredColors") {
                userDefaults.removeObject(forKey: "preferredColors")
            }
            // 迁移密码数据
            if let userInfo = userDefaults.object(forKey: UserAgent.sharedInstance.key) as? [String: String] {
                if let _ = userInfo["password"] {
                    userDefaults.removeObject(forKey: UserAgent.sharedInstance.key)
                }
            }
            // 删除原有的课程数据
            if let _ = userDefaults.object(forKey: "courses") as? NSDictionary {
                userDefaults.removeObject(forKey: "courses")
                userDefaults.removeObject(forKey: "courseStatus")
                CourseLoadedAgent.sharedInstance.signCourseToUnloaded()
            }
        }
        
        transferFromVersion1ToVersion2()
        setUpAllTools()
        setUpApperance()
        loadPreferredColors()
        setUpNotification()
        VersionInfoAgent.sharedInstance.saveData()

        // 推送来的消息需要打开哪个页面
        if let launchOption = launchOptions {
            if let notificationPayload = launchOption[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: Any] {
                if let action = notificationPayload["action"] as? [String: Any] {
                    if let actionType1 = action["type1"] as? Int, // 一级TabViewController的导航
                        let actionType2 = action["type2"] as? Int { // 二级TableViewController的导航
                        NKRouter.sharedInstance.action = ["action1": actionType1, "action2": actionType2]
                        let rootvc = self.window?.rootViewController as! UITabBarController
                        rootvc.selectedIndex = actionType1
                    }
                }
            }
        }
        
        try! R.validate()
        // 清理已完成的任务
        try? Task.updateStoredTasks()
        NKNetworkInfoHandler.registerUser()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Register For Remote Notification With Device Token Successfully")
        let token = deviceToken.description.trimmingCharacters(in: CharacterSet(charactersIn: "<>")).replacingOccurrences(of: " ", with: "")
        print("Device Token: ", token)
        NKNetworkInfoHandler.uploadDeviceToken(token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Register For Remote Notification With Device Token Unsuccessfully")
    }
    
    // 推送来的消息需要打开哪个页面
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let action = userInfo["action"] as? [String: Any] {
            if let actionType1 = action["type1"] as? Int, // 一级TabViewController的导航
                let actionType2 = action["type2"] as? Int { // 二级TableViewController的导航
                NKRouter.sharedInstance.action = ["action1": actionType1, "action2": actionType2]
                let rootvc = self.window?.rootViewController as! UITabBarController
                rootvc.selectedIndex = actionType1
            }
        }
    }
    
    func onResp(_ resp: BaseResp!) {
        if resp.isKind(of: type(of: SendMessageToWXResp())) {
            print("分享到微信错误")
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if application.applicationIconBadgeNumber != 0 {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }

}

