//
//  AppDelegate.swift
//  BadgeKit-Example
//
//  Created by saucymqin on 2018/11/14.
//  Copyright © 2018 413132340@qq.com. All rights reserved.
//

import UIKit
import BadgeKit

public class First: NSObject { /** < 我页面的一些红点 */
    @objc public static let root    = "first"
    @objc public static let button  = "\(root).button"
    class func button<T>(_ tag: T) -> String {
        return "\(root).button.\(tag)"
    }
}

public class Second: NSObject { /** < 我页面的一些红点 */
    @objc public static let root  = "second"
    @objc public static let button  = "\(root).button"
    class func button<T>(_ tag: T) -> String {
        return "\(root).button.\(tag)"
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if let tab = self.window?.rootViewController as? UITabBarController {
            if let item = tab.tabBar.items?.first {
                BadgeManager.shared.observeFor(keyPath: First.root, badgeView: item, block: nil)
            }
            if let item = tab.tabBar.items?.last {
                BadgeManager.shared.observeFor(keyPath: Second.root, badgeView: item, block: nil)
            }
        }
        return true
    }
}

