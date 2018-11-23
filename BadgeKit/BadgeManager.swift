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

@objc public class BadgeModel: NSObject {
    public let keyPath: String
    public let count: UInt
    public init(keyPath: String, count: UInt) {
        self.keyPath = keyPath
        self.count = count
        super.init()
    }
    public override var description: String {
        return "keyPath: \(keyPath)  count:\(count)"
    }
}

public typealias BadgeNotificationBlock = (BadgeModel, Bool) -> Void

@objc public class BadgeManager: NSObject {
    @objc public static let shared = BadgeManager()
    @objc public static var radius: CGFloat = 4.5
    @objc public static var maxShowNumber: NSInteger = 999
    private var badgeDict = [String: BadgeModel]()  // keyPath : Badge
    private var blockDict = [String: [Any]]()         // keyPath : [BadgeProtocol or BadgeNotificationBlock]
    private var hideDict: [String: NSMutableSet]    // keyPath : [keyPath]
    @objc public var storageURL: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("badgeKit.data") {
        didSet {
            hideDict = BadgeManager.dictFrom(storageURL: storageURL)
        }
    }

    private override init() {
        hideDict = BadgeManager.dictFrom(storageURL: storageURL)
        super.init()
    }

    private static func dictFrom(storageURL: URL) -> [String: NSMutableSet] {
        if let dict = NSKeyedUnarchiver.unarchiveObject(withFile: storageURL.path) as? [String: NSMutableSet] {
            return dict.filter { $1.count != 0 } //remove empty set
        } else {
            do {
                try FileManager.default.removeItem(at: storageURL)
            } catch {
                print(error)
            }
            return [String: NSMutableSet]()
        }
    }
    
    // MARK: - Public
    
    @objc public func setBadgeFor(keyPath: String) {
        DispatchQueue.main.async {
            self.add(badge: BadgeModel(keyPath: keyPath, count: 0))
        }
    }
    
    @objc public func setBadgeFor(keyPath: String, count: UInt) {
        DispatchQueue.main.async {
            self.add(badge: BadgeModel(keyPath: keyPath, count: count))
        }
    }
    
    @objc public func clearBadgeFor(keyPath: String) {
        DispatchQueue.main.async {
            self.clearFor(keyPath: keyPath)
        }
    }
    
    @objc public func clearBadgeAndSaveFor(keyPath: String) { // 清除 并且会记录落地，保证以后相同的key不会再出红点
        DispatchQueue.main.async {
            self.clearFor(keyPath: keyPath)
            UserDefaults.standard.set(true, forKey: self.badgeKeyFor(keyPath: keyPath))
        }
    }
    
    @objc public func clearBadgeFor(prefix: String) {
        DispatchQueue.main.async {
            self.clearFor(prefix: prefix)
        }
    }
    
    @objc public func hideFor(keyPath: String) { // 设置为不显示，记录到磁盘
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
    
    @objc public func observeFor(keyPath: String, badgeView: BadgeProtocol_objc?, block: BadgeNotificationBlock?) {
        if UserDefaults.standard.bool(forKey: badgeKeyFor(keyPath: keyPath)) { // 如果记录了就不在处理
            return
        }
        
        if var array = blockDict[keyPath], array.count > 0 {
            if let badgeView = badgeView {
                array.append(badgeView)
            }
            if let block = block {
                array.append(block)
            }
        } else {
            var array = [Any]()
            if let badgeView = badgeView {
                array.append(badgeView)
            }
            if let block = block {
                array.append(block)
            }
            blockDict[keyPath] = array
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
    
    @objc public func recursiveStatusFor(keyPath: String) -> Bool {
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
    
    @objc public func countFor(keyPath: String) -> UInt {
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
    
    @objc public func recursiveCountFor(keyPath: String) -> UInt {
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
    
    func clearFor(keyPath: String) {
        if let cBadge = badgeDict[keyPath] {
            badgeDict.removeValue(forKey: keyPath)
            recursiveNotificationFor(badge: cBadge, isAdd: false)
        }
        
        hideTableRemove(keyPath: keyPath)
    }
    
    func clearFor(prefix: String) {
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
    
    func hideTableRemove(keyPath: String) {
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
    
    func hideTableRemoveWith(prefix: String) {
        var isChanged = false
        hideDict.forEach { key, keySet in
            if let enumSet: NSSet = keySet.copy() as? NSSet {
                enumSet.forEach { value in
                    if let key = value as? String {
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
    
    func badgeKeyFor(keyPath: String) -> String {
        return "wy_badge_" + (keyPath as String) + "\(storageURL.path.hashValue)"
    }
    
    func add(badge: BadgeModel) {
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
    
    func recursiveNotificationFor(badge: BadgeModel, isAdd: Bool) {
        if let array = blockDict[badge.keyPath], array.count > 0 {
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
        var path: String = badge.keyPath
        while path.contains(".") {
            path = (path as NSString).deletingPathExtension
            refreshFor(keyPath: path)
        }
    }
    
    func refreshFor(keyPath: String) {
        if let array = blockDict[keyPath], array.count > 0 {
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
                    block(BadgeModel(keyPath: keyPath, count: 0), false)
                }
            }
        }
    }
}
