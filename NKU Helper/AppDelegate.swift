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

var tableViewActionType:Int? = nil

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIAlertViewDelegate, WXApiDelegate{

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // To set up Flurry(App Analyse), Fabric.Crashlytics(Crash Analyse), AVOS(Push Service), ShareSDK
        func setUpAllTools() {
            
            Fabric.with([Crashlytics.self])
            
            AVOSCloud.setApplicationId("2Ot4Qst88l7L50oHgGHpRUij", clientKey: "gN4rJ9GizYYRS6tqLPioUBoS")
            AVAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            
            WXApi.registerApp("wx311e5377578127f1")
            
            ShareSDK.registerApp("f61adcd245a4", activePlatforms: [SSDKPlatformType.TypeWechat.rawValue,
                                                                    SSDKPlatformType.TypeQQ.rawValue,
                                                                    SSDKPlatformType.TypeFacebook.rawValue,
                                                                    SSDKPlatformType.TypeMail.rawValue,
                                                                    SSDKPlatformType.TypeCopy.rawValue,
                                                                    SSDKPlatformType.TypePrint.rawValue]
                , onImport: { (platform: SSDKPlatformType) -> Void in
                    switch platform {
                    case .TypeWechat:
                        ShareSDKConnector.connectWeChat(WXApi.classForCoder())
                    case .TypeQQ:
                        ShareSDKConnector.connectQQ(QQApiInterface.classForCoder(), tencentOAuthClass: TencentOAuth.classForCoder())
                    default:
                        break;
                    }
                }) { (platform: SSDKPlatformType, appInfo: NSMutableDictionary!) -> Void in
                    switch platform {
                    case SSDKPlatformType.TypeWechat:
                        //设置微信应用信息
                        appInfo.SSDKSetupWeChatByAppId("wx311e5377578127f1", appSecret: "83c6080bc1957d3f8f7306f946eb3667")
                    case SSDKPlatformType.TypeQQ:
                        //设置QQ应用信息
                        appInfo.SSDKSetupQQByAppId("1104934641", appKey: "W66uuRWLP9ZnFlkC", authType: SSDKAuthTypeBoth)
                    case SSDKPlatformType.TypeFacebook:
                        //设置Facebook应用信息，其中authType设置为只用SSO形式授权
                        appInfo.SSDKSetupFacebookByApiKey("576897682460678", appSecret: "20c9e13a474f9d603e488272a033d7d9", authType: SSDKAuthTypeSSO)
                    default:
                        break
                    }
            }
        }
        
        // set up App Appearance
        func setUpApperance() {
            UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
            UINavigationBar.appearance().tintColor = UIColor.blackColor()
            UIBarButtonItem.appearance().tintColor = UIColor(red: 16/255, green: 128/255, blue: 207/255, alpha: 1)
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]
        }
        
        // load Preferred Colors
        func loadPreferredColors() {
            let rootvc = self.window?.rootViewController as! UITabBarController
            let firstViewController = rootvc.childViewControllers[0]
            do {
                try Color.getColors()
            } catch StoragedDataError.NoColorInStorage {
                do {
                    try Color.copyColorsToDocument()
                } catch {
                    firstViewController.presentViewController(ErrorHandler.alert(ErrorHandler.StorageNotEnough()), animated: true, completion: nil)
                }
            } catch {
                firstViewController.presentViewController(ErrorHandler.alert(ErrorHandler.StorageNotEnough()), animated: true, completion: nil)
            }

        }
        
        // set up notification
        func setUpNotification() {
            let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        
        // 从1.x版本迁移到2.x版本
        func transferFromVersion1ToVersion2() {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            if let _ = userDefaults.objectForKey("preferredColors") {
                userDefaults.removeObjectForKey("preferredColors")
            }
        }
        
        setUpAllTools()
        setUpApperance()
        loadPreferredColors()
        setUpNotification()
        transferFromVersion1ToVersion2()

        // 推送来的消息需要打开哪个页面
        if let launchOption = launchOptions {
            
            let notificationPayload = launchOption[UIApplicationLaunchOptionsRemoteNotificationKey] as! NSDictionary
            if let action = notificationPayload.objectForKey("action") as? NSDictionary {
                let actionType1 = action.objectForKey("type1") as? Int  // 一级TabViewController的导航
                let actionType2 = action.objectForKey("type2") as? Int  // 二级TableViewController的导航
                if let _ = actionType1 {
                    let rootvc = self.window?.rootViewController as! UITabBarController
                    rootvc.selectedIndex = actionType1!
                    if let _ = actionType2 {
                        tableViewActionType = actionType2!
                    }
                }
            }
        }
        
        R.assertValid()
        
        return true
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        print("Register For Remote Notification With Device Token Successfully")
        let currentInstallation = AVInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        print(deviceToken)
        currentInstallation.saveInBackgroundWithBlock { (succeeded, error) -> Void in
            if succeeded {
                print("Save Device Token Successfully")
            }
            else {
                print("Save Device Token Unsuccessfully")
            }
        }
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Register For Remote Notification With Device Token Unsuccessfully")
    }
    
    // 推送来的消息需要打开哪个页面
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if let action = userInfo["action"] as? NSDictionary {
            let actionType1 = action.objectForKey("type1") as? Int  // 一级TabViewController的导航
            let actionType2 = action.objectForKey("type2") as? Int  // 二级TableViewController的导航
            if let _ = actionType1 {
                let rootvc = self.window?.rootViewController as! UITabBarController
                rootvc.selectedIndex = actionType1!
                if application.applicationState != UIApplicationState.Active {
                    AVAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
                }
                if let _ = actionType2 {
                    tableViewActionType = actionType2!
                }
            }
        }
    }
    
    func onResp(resp: BaseResp!) {
        if resp.isKindOfClass(SendMessageToWXResp().dynamicType) {
            print("分享到微信错误")
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if application.applicationIconBadgeNumber != 0 {
            
            let currentInstallation = AVInstallation.currentInstallation()
            currentInstallation.badge = 0
            currentInstallation.saveEventually()
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            
        }
        
    }

}

