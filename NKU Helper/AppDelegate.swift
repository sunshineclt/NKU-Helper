//
//  AppDelegate.swift
//  NKU Helper
//
//  Created by 陈乐天 on 15/2/14.
//  Copyright (c) 2015年 陈乐天. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIAlertViewDelegate{

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        AVOSCloud.setApplicationId("2Ot4Qst88l7L50oHgGHpRUij", clientKey: "gN4rJ9GizYYRS6tqLPioUBoS")
        AVAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
        UINavigationBar.appearance().tintColor = UIColor.blackColor()
        UIBarButtonItem.appearance().tintColor = UIColor(red: 16/255, green: 128/255, blue: 207/255, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()]

        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var preferredColors:NSMutableArray? = userDefaults.objectForKey("preferredColors") as? NSMutableArray
        if let _ = preferredColors {
            let newPreferredColors = NSMutableArray(array: preferredColors!)
            if Colors.colors.count > preferredColors!.count {
                for _ in 1...Colors.colors.count - preferredColors!.count {
                    newPreferredColors.addObject(1)
                }
                userDefaults.removeObjectForKey("preferredColors")
                userDefaults.setObject(newPreferredColors, forKey: "preferredColors")
                userDefaults.synchronize()
            }
        }
        else {
            preferredColors = NSMutableArray()
            for (var i=0;i<Colors.colors.count;i++) {
                preferredColors?.addObject(1)
            }
            userDefaults.setObject(preferredColors, forKey: "preferredColors")
            userDefaults.synchronize()
        }
        
        let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        if let launchOption = launchOptions {
            
            let notificationPayload:NSDictionary = launchOption[UIApplicationLaunchOptionsRemoteNotificationKey] as! NSDictionary
            let action:NSDictionary = notificationPayload.objectForKey("action") as! NSDictionary
            let actionType:Int = action.objectForKey("type") as! Int
            let rootvc = self.window?.rootViewController as! UITabBarController
            rootvc.selectedIndex = actionType
            
        }
        
        return true
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        print("Register For Remote Notification With Device Token Successfully")
        let currentInstallation = AVInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
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
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        let action:NSDictionary = userInfo["action"] as! NSDictionary
        let type:Int = action.objectForKey("type") as! Int
        let rootvc = self.window?.rootViewController as! UITabBarController
        rootvc.selectedIndex = type
        if application.applicationState != UIApplicationState.Active {
            AVAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
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

