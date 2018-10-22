//
//  Manager.swift
//  BadgeKit
//
//  Created by saucymqin on 2018/8/22.
//  Copyright © 2018年 413132340@qq.com. All rights reserved.
//

import UIKit

@objc public protocol BadgeProtocol_objc: class { // 外界objc需要使用的属性或方法 这里必须这样转发一下，不然没法搞
    var objc_badgeTargetView: UIView? { get }
    var objc_badgeView: UIButton? { get set }
    var objc_badgeOffset: CGPoint { get set }
    func objc_showBadge()
    func objc_showBadge(_ withValue: UInt)
    func objc_hideBadge()
}

public protocol BadgeProtocol: class {
    var badgeTargetView: UIView? { get }
    var badgeView: UIButton? { get set }
    var badgeOffset: CGPoint { get set }
    func showBadge()
    func showBadge(_ withValue: UInt)
    func hideBadge()
}

public typealias BadgeNotificationBlock = (Badge, Bool) -> Void

class BadgeManager: NSObject {
    @objc public static let shared = BadgeManager()
    var badgeDict = [NSString: Badge]() // keyPath : Badge
    let blockDict = NSMutableDictionary() // keyPath : [BadgeProtocol or BadgeNotificationBlock]
    var hideDict: [NSString: NSMutableSet] // keyPath : [keyPath]
    public var storageURL: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("badgeKit.data") {
        didSet {
            hideDict = BadgeManager.dictFrom(storageURL: storageURL)
        }
    }

    private override init() {
        hideDict = BadgeManager.dictFrom(storageURL: storageURL)
        super.init()
    }

    private static func dictFrom(storageURL: URL) -> [NSString: NSMutableSet] {
        if let dict = NSKeyedUnarchiver.unarchiveObject(withFile: storageURL.path) as? [NSString: NSMutableSet] {
            return dict.filter { $1.count != 0 } //remove empty set
        } else {
            do {
                try FileManager.default.removeItem(at: storageURL)
            } catch {
                print(error)
            }
            return [NSString: NSMutableSet]()
        }
    }
    
    // MARK: - Public
    
    @objc public func setBadgeFor(keyPath: NSString) {
        DispatchQueue.main.async {
            self.add(badge: Badge(keyPath: keyPath, count: 0))
        }
    }
    
    @objc public func setBadgeFor(keyPath: NSString, count: UInt) {
        DispatchQueue.main.async {
            self.add(badge: Badge(keyPath: keyPath, count: count))
        }
    }
    
    @objc public func clearBadgeFor(keyPath: NSString) {
        DispatchQueue.main.async {
            self.clearFor(keyPath: keyPath)
        }
    }
    
    @objc public func clearBadgeAndSaveFor(keyPath: NSString) { // 清除 并且会记录落地，保证以后相同的key不会再出红点
        DispatchQueue.main.async {
            self.clearFor(keyPath: keyPath)
            UserDefaults.standard.set(true, forKey: self.badgeKeyFor(keyPath: keyPath))
        }
    }
    
    @objc public func clearBadgeFor(prefix: NSString) {
        DispatchQueue.main.async {
            self.clearFor(prefix: prefix)
        }
    }
    
    @objc public func hideFor(keyPath: NSString) { // 设置为不显示，记录到磁盘
        DispatchQueue.main.async {
            let subKeys = NSMutableSet()
            self.badgeDict.forEach({ key, _ in
                if key.hasPrefix(keyPath as String) {
                    subKeys.add(key)
                }
            })
            if subKeys.count > 0 {
                var isChanged = true
                if let keys = self.hideDict[keyPath] {
                    let count = keys.count
                    keys.union(subKeys as Set)
                    if count == keys.count {
                        isChanged = false
                    }
                } else {
                    self.hideDict[keyPath] = subKeys
                }
                
                if isChanged {
                    self.saveHideTable()
                }
            }
            
            self.refreshFor(keyPath: keyPath)
        }
    }
    
    public func observeFor(keyPath: NSString, badgeView: BadgeProtocol_objc?, block: BadgeNotificationBlock?) {
        if UserDefaults.standard.bool(forKey: badgeKeyFor(keyPath: keyPath)) { // 如果记录了就不在处理
            return
        }
        
        if let array = blockDict.object(forKey: keyPath) as? NSMutableArray {
            if badgeView != nil {
                array.add(badgeView as Any)
            }
            if block != nil {
                array.add(block as Any)
            }
        } else {
            let array = NSMutableArray(object: block as Any)
            if badgeView != nil {
                array.add(badgeView as Any)
            }
            blockDict.setObject(array, forKey: keyPath)
        }
        
        if badgeView != nil {
            DispatchQueue.main.async { // async一下，避免当前页面还没显示导致莫名其妙的红点透明了
                if let bView = badgeView as? BadgeProtocol {
                    let count = self.recursiveCountFor(keyPath: keyPath)
                    if count > 0 {
                        bView.showBadge(count)
                    } else if self.recursiveStatusFor(keyPath: keyPath) {
                        bView.showBadge()
                    }
                } else {
                    assertionFailure("badgeView must as BadgeProtocol")
                }
            }
        }
    }
    
    @objc public func recursiveStatusFor(keyPath: NSString) -> Bool {
        let keys = badgeDict.keys
        for key in keys {
            if let subKeys = hideDict[keyPath] {
                if subKeys.contains(key) {
                    continue
                }
            }
            
            if key.hasPrefix(keyPath as String) {
                return true
            }
        }
        return false
    }
    
    @objc public func countFor(keyPath: NSString) -> UInt {
        if let subKeys = hideDict[keyPath] {
            if subKeys.contains(keyPath) {
                return 0
            }
        }
        
        if let cBadge = badgeDict[keyPath] {
            return cBadge.count
        }
        return 0
    }
    
    @objc public func recursiveCountFor(keyPath: NSString) -> UInt {
        var count: UInt = 0
        let keys = badgeDict.keys
        for key in keys {
            if let subKeys = hideDict[keyPath] {
                if subKeys.contains(key) {
                    continue
                }
            }
            
            if key.hasPrefix(keyPath as String) {
                if let cBadge = badgeDict[key] {
                    count += cBadge.count
                }
            }
        }
        return count
    }
    
    // MARK: - Private
    
    func clearFor(keyPath: NSString) {
        if let cBadge = badgeDict[keyPath] {
            badgeDict.removeValue(forKey: keyPath)
            recursiveNotificationFor(badge: cBadge, isAdd: false)
        }
        
        hideTableRemove(keyPath: keyPath)
    }
    
    func clearFor(prefix: NSString) {
        let keys = badgeDict.keys
        for keyPath in keys {
            if keyPath.hasPrefix(prefix as String) {
                if let cBadge = badgeDict[keyPath] {
                    badgeDict.removeValue(forKey: keyPath)
                    recursiveNotificationFor(badge: cBadge, isAdd: false)
                }
            }
        }
        
        hideTableRemoveWith(prefix: prefix)
    }
    
    func hideTableRemove(keyPath: NSString) {
        var isChanged = false
        hideDict.forEach { _, keySet in
            if keySet.contains(keyPath) {
                isChanged = true
            }
            
            keySet.remove(keyPath)
        }
        
        if isChanged {
            saveHideTable()
        }
    }
    
    func hideTableRemoveWith(prefix: NSString) {
        var isChanged = false
        hideDict.forEach { key, keySet in
            if let enumSet: NSSet = keySet.copy() as? NSSet {
                enumSet.forEach { value in
                    if let key = value as? NSString {
                        if key.hasPrefix(prefix as String) {
                            keySet.remove(key)
                            isChanged = true
                        }
                    }
                }
            }
        }
        
        if isChanged {
            saveHideTable()
        }
    }
    
    func saveHideTable() {
        let table = hideDict
        DispatchQueue.global().async {
            NSKeyedArchiver.archiveRootObject(table, toFile: self.storageURL.path)
        }
    }
    
    func badgeKeyFor(keyPath: NSString) -> String {
        return "wy_badge_" + (keyPath as String) + "\(storageURL.path.hashValue)"
    }
    
    func add(badge: Badge) {
        if UserDefaults.standard.bool(forKey: badgeKeyFor(keyPath: badge.keyPath)) { // 如果记录了就不在处理
            return
        }
        
        if let cBadge = badgeDict[badge.keyPath] {
            if cBadge.count != badge.count {
                badgeDict[badge.keyPath] = badge
                recursiveNotificationFor(badge: badge, isAdd: true)
            }
        } else {
            badgeDict[badge.keyPath] = badge
            recursiveNotificationFor(badge: badge, isAdd: true)
        }
    }
    
    func recursiveNotificationFor(badge: Badge, isAdd: Bool) {
        if let array = blockDict.object(forKey: badge.keyPath) as? [Any] {
            for obj in array {
                if let block = obj as? BadgeNotificationBlock {
                    block(badge, isAdd)
                } else if let bView = obj as? BadgeProtocol {
                    if isAdd {
                        if let subKeys = hideDict[badge.keyPath] {
                            if subKeys.contains(badge.keyPath) {
                                continue
                            }
                        }
                        
                        if badge.count > 0 {
                            bView.showBadge(badge.count)
                        } else {
                            bView.showBadge()
                        }
                    } else {
                        bView.hideBadge()
                    }
                }
            }
        }
        
        // 通知到所有父节点
        var path: NSString = badge.keyPath
        while path.contains(".") {
            path = path.deletingPathExtension as NSString
            refreshFor(keyPath: path)
        }
    }
    
    func refreshFor(keyPath: NSString) {
        if let array = blockDict.object(forKey: keyPath) as? [Any] {
            for obj in array {
                if let bView = obj as? BadgeProtocol {
                    if let subKeys = hideDict[keyPath] {
                        if subKeys.contains(keyPath) {
                            continue
                        }
                    }
                    
                    let count = recursiveCountFor(keyPath: keyPath)
                    if count > 0 {
                        bView.showBadge(count)
                    } else if recursiveStatusFor(keyPath: keyPath) {
                        bView.showBadge()
                    } else {
                        bView.hideBadge()
                    }
                } else if let block = obj as? BadgeNotificationBlock {
                    block(Badge(keyPath: keyPath, count: 0), false)
                }
            }
        }
    }
}
