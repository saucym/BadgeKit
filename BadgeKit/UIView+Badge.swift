//
//  UIView+Badge.swift
//  BadgeKit
//
//  Created by saucymqin on 2018/8/22.
//  Copyright © 2018年 413132340@qq.com. All rights reserved.
//

import UIKit

private struct AssociatedKeys {
    static var view = "badgeView"
    static var offset = "badgeOffset"
}

extension UIView {
    var heightConstraint: NSLayoutConstraint? {
        return self.constraints.lazy.filter{ $0.firstAttribute == .height }.first
    }
    
    func findSubview(_ name: String) -> UIView? {
        if let nameClass = NSClassFromString(name) {
            if type(of: self) == nameClass {
                return self
            } else {
                return self.subviews.lazy.filter{ $0.findSubview(name) != nil }.first
            }
        }
        return nil
    }
}

extension BadgeProtocol {
    public var badgeView: UIButton? {
        get {
            if let bView = objc_getAssociatedObject(self, &AssociatedKeys.view) as? UIButton {
                return bView
            } else if let view = self.badgeTargetView {
                view.clipsToBounds = false
                let bView = UIButton(frame: view.bounds)
                bView.isUserInteractionEnabled = false
                bView.titleLabel?.textAlignment = .center
                bView.titleLabel?.font = UIFont.boldSystemFont(ofSize: 9)
                bView.backgroundColor = UIColor(red: 1, green: 0x4c / 255.0, blue: 0x22 / 255.0, alpha: 1)
                bView.setTitleColor(UIColor.white, for: .normal)
                bView.layer.cornerRadius = BadgeManager.radius
                bView.layer.masksToBounds = true
                bView.isHidden = true
                bView.contentEdgeInsets = UIEdgeInsets(top: 0, left: BadgeManager.radius, bottom: 0, right: BadgeManager.radius)
                view.addSubview(bView)
                view.bringSubviewToFront(bView)
                objc_setAssociatedObject(self, &AssociatedKeys.view, bView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                bView.translatesAutoresizingMaskIntoConstraints = false
                bView.heightAnchor.constraint(equalToConstant: BadgeManager.radius * 2).isActive = true
                let topConstraint = bView.topAnchor.constraint(equalTo: view.topAnchor, constant: self.badgeOffset.y - BadgeManager.radius)
                topConstraint.priority = .defaultLow
                topConstraint.isActive = true
                let leftConstraint = bView.leftAnchor.constraint(equalTo: view.rightAnchor, constant: self.badgeOffset.x - BadgeManager.radius)
                leftConstraint.priority = .defaultLow
                leftConstraint.isActive = true
                return bView
            } else {
                return nil
            }
        }
        set { objc_setAssociatedObject(self, &AssociatedKeys.view, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    public var badgeOffset: CGPoint {
        get {
            if let number = objc_getAssociatedObject(self, &AssociatedKeys.offset) as? NSValue {
                return number.cgPointValue
            } else {
                if (self as? UITabBarItem) != nil {
                    return CGPoint(x: -BadgeManager.radius, y: BadgeManager.radius)
                } else {
                    return CGPoint.zero
                }
            }
        }
        set { objc_setAssociatedObject(self, &AssociatedKeys.offset, NSValue(cgPoint: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    public func showBadge(_ withValue: UInt) {
        if let bView = badgeView {
            bView.isHidden = withValue == 0 ? true : false
            let text: String = withValue > BadgeManager.maxShowNumber ? "\(BadgeManager.maxShowNumber)+" : "\(withValue)"
            bView.setTitle(text, for: .normal)
            bView.heightConstraint?.constant = BadgeManager.radius * 2 + 4
            bView.layer.cornerRadius = BadgeManager.radius + 2
        }
    }
    
    public func showBadge() {
        if let bView = badgeView {
            bView.setTitle("", for: .normal)
            bView.isHidden = false
            bView.heightConstraint?.constant = BadgeManager.radius * 2
            bView.layer.cornerRadius = BadgeManager.radius
        }
    }
    
    public func hideBadge() {
        if let bView = objc_getAssociatedObject(self, &AssociatedKeys.view) as? UIButton {
            bView.isHidden = true
        }
    }
}

extension UIView: BadgeProtocol {
    public var badgeTargetView: UIView? {
        return self
    }
}

extension UIBarButtonItem: BadgeProtocol {
    public var badgeTargetView: UIView? {
        let view = value(forKeyPath: "_view") as? UIView
        if view?.isMember(of: UIButton.self) == true {
            if let button: UIButton = view as? UIButton {
                if button.currentImage != nil {
                    return button.imageView
                } else if button.currentTitle != nil {
                    return button.titleLabel
                }
            }
        } else if let objView = view?.findSubview("UIButtonLabel") {
            return objView
        } else if let objView = view?.findSubview("UIImageView") as? UIImageView {
            if objView.image != nil {
                return objView
            }
        }
        return view
    }
}

extension UITabBarItem: BadgeProtocol {
    public var badgeTargetView: UIView? {
        if let view = self.value(forKeyPath: "_view") as? UIView {
            let objView = view.findSubview("UITabBarSwappableImageView")
            return objView
        }
        return nil
    }
}

// MARK: - 下面是objc兼容代码，如果不支持objc可以不要
extension UIBarButtonItem: BadgeProtocol_objc {
    public var objc_badgeTargetView: UIView? {
        return badgeTargetView
    }
    
    public var objc_badgeView: UIButton? {
        get { return badgeView }
        set { badgeView = newValue }
    }
    
    public var objc_badgeOffset: CGPoint {
        get { return badgeOffset }
        set { badgeOffset = newValue }
    }
    
    public func objc_showBadge() {
        showBadge()
    }
    
    public func objc_showBadge(_ withValue: UInt) {
        showBadge(withValue)
    }
    
    public func objc_hideBadge() {
        hideBadge()
    }
}

extension UITabBarItem: BadgeProtocol_objc {
    public var objc_badgeTargetView: UIView? {
        return badgeTargetView
    }
    
    public var objc_badgeView: UIButton? {
        get { return badgeView }
        set { badgeView = newValue }
    }
    
    public var objc_badgeOffset: CGPoint {
        get { return badgeOffset }
        set { badgeOffset = newValue }
    }
    
    public func objc_showBadge() {
        showBadge()
    }
    
    public func objc_showBadge(_ withValue: UInt) {
        showBadge(withValue)
    }
    
    public func objc_hideBadge() {
        hideBadge()
    }
}

extension UIView: BadgeProtocol_objc {
    public var objc_badgeTargetView: UIView? {
        return badgeTargetView
    }
    
    public var objc_badgeView: UIButton? {
        get { return badgeView }
        set { badgeView = newValue }
    }
    
    public var objc_badgeOffset: CGPoint {
        get { return badgeOffset }
        set { badgeOffset = newValue }
    }
    
    public func objc_showBadge() {
        showBadge()
    }
    
    public func objc_showBadge(_ withValue: UInt) {
        showBadge(withValue)
    }
    
    public func objc_hideBadge() {
        hideBadge()
    }
}
