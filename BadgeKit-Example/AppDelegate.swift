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
}

