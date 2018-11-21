//
//  AppDelegate.swift
//  BadgeKit-Example
//
//  Created by saucymqin on 2018/11/14.
//  Copyright © 2018 413132340@qq.com. All rights reserved.
//

import UIKit
import BadgeKit

public class BadgeFirst: NSObject { /** < 我页面的一些红点 */
    @objc public static let root: NSString  = "first"
    @objc public static let button0: NSString  = "first.button0"
    @objc public static let button1: NSString  = "first.button1"
    @objc public static let button2: NSString  = "first.button2"
}

public class BadgeSecond: NSObject { /** < 我页面的一些红点 */
    @objc public static let root: NSString  = "second"
    @objc public static let button0: NSString  = "second.button0"
    @objc public static let button1: NSString  = "second.button1"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if let tab = self.window?.rootViewController as? UITabBarController {
            if let item = tab.tabBar.items?.first {
                BadgeManager.shared.observeFor(keyPath: BadgeFirst.root, badgeView: item, block: nil)
            }
            if let item = tab.tabBar.items?.last {
                BadgeManager.shared.observeFor(keyPath: BadgeSecond.root, badgeView: item, block: nil)
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

