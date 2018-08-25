//
//  UIView+Badge.swift
//  BadgeKit
//
//  Created by saucymqin on 2018/8/22.
//  Copyright © 2018年 413132340@qq.com. All rights reserved.
//

import UIKit

private let kRJBadgeDefaultRadius: CGFloat = 4.5
private let kRJBadgeDefaultMaximumBadgeNumber: NSInteger = 99

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
            if type(of: self).isMember(of: nameClass) {
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
                bView.layer.cornerRadius = kRJBadgeDefaultRadius
                bView.layer.masksToBounds = true
                bView.isHidden = true
                bView.contentEdgeInsets = UIEdgeInsets(top: 0, left: kRJBadgeDefaultRadius, bottom: 0, right: kRJBadgeDefaultRadius)
                view.addSubview(bView)
                view.bringSubview(toFront: bView)
                objc_setAssociatedObject(self, &AssociatedKeys.view, bView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                bView.translatesAutoresizingMaskIntoConstraints = false
                bView.heightAnchor.constraint(equalToConstant: kRJBadgeDefaultRadius * 2).isActive = true
                let topConstraint = bView.topAnchor.constraint(equalTo: view.topAnchor, constant: self.badgeOffset.y - kRJBadgeDefaultRadius)
                topConstraint.isActive = true
                topConstraint.priority = .defaultLow
                let leftConstraint = bView.leftAnchor.constraint(equalTo: view.rightAnchor, constant: self.badgeOffset.x - kRJBadgeDefaultRadius)
                leftConstraint.isActive = true
                leftConstraint.priority = .defaultLow
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
                    return CGPoint(x: -kRJBadgeDefaultRadius, y: kRJBadgeDefaultRadius)
                } else {
                    return CGPoint.zero
                }
            }
        }
        set { objc_setAssociatedObject(self, &AssociatedKeys.offset, NSValue(cgPoint: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    public func showBadge(_ withValue: UInt) {
        badgeView?.isHidden = withValue == 0 ? true : false
        let text: String = withValue > kRJBadgeDefaultMaximumBadgeNumber ? "\(kRJBadgeDefaultMaximumBadgeNumber)+" : "\(withValue)"
        badgeView?.setTitle(text, for: .normal)
        badgeView?.heightConstraint?.constant = kRJBadgeDefaultRadius * 2 + 4
        badgeView?.layer.cornerRadius = kRJBadgeDefaultRadius + 2
    }
    
    public func showBadge() {
        badgeView?.setTitle("", for: .normal)
        badgeView?.isHidden = false
        badgeView?.heightConstraint?.constant = kRJBadgeDefaultRadius * 2
        badgeView?.layer.cornerRadius = kRJBadgeDefaultRadius
    }
    
    public func hideBadge() {
        if let bView = objc_getAssociatedObject(self, &AssociatedKeys.view) as? UIButton {
            bView.isHidden = true
        }
    }
}

extension UIView: BadgeProtocol, BadgeProtocol_objc {
    public func objc_badgeView() -> UIButton? {
        return badgeView
    }
    
    public var objcBadgeOffset: CGPoint {
        get { return badgeOffset }
        set { badgeOffset = newValue }
    }
    
    public func objc_showBadge() {
        showBadge()
    }
    
    public func objc_hideBadge() {
        hideBadge()
    }
    
    public var badgeTargetView: UIView? {
        return self
    }
}

extension UIBarButtonItem: BadgeProtocol, BadgeProtocol_objc {
    public func objc_badgeView() -> UIButton? {
        return badgeView
    }
    
    public var objcBadgeOffset: CGPoint {
        get { return badgeOffset }
        set { badgeOffset = newValue }
    }
    
    public func objc_showBadge() {
        showBadge()
    }
    
    public func objc_hideBadge() {
        hideBadge()
    }
    
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

extension UITabBarItem: BadgeProtocol, BadgeProtocol_objc {
    public func objc_badgeView() -> UIButton? {
        return badgeView
    }
    
    public var objcBadgeOffset: CGPoint {
        get { return badgeOffset }
        set { badgeOffset = newValue }
    }
    
    public func objc_showBadge() {
        showBadge()
    }
    
    public func objc_hideBadge() {
        hideBadge()
    }
    
    public var badgeTargetView: UIView? {
        if let view = self.value(forKeyPath: "_view") as? UIView {
            let objView = view.findSubview("UITabBarSwappableImageView")
            return objView
        }
        return nil
    }
}
