//
//  FirstViewController.swift
//  BadgeKit-Example
//
//  Created by saucymqin on 2018/11/14.
//  Copyright © 2018 413132340@qq.com. All rights reserved.
//

import UIKit
import BadgeKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let btn = UIButton(type: .contactAdd)
        btn.center = CGPoint(x: view.center.x, y: view.center.y + 100)
        view.addSubview(btn)
        btn.addTarget(self, action: #selector(buttonActon), for: .touchUpInside)

        BadgeManager.shared.observeFor(keyPath: BadgeFirst.button0, badgeView: btn, block: nil)

        let btn1 = UIButton(type: .contactAdd)
        btn1.center = CGPoint(x: view.center.x + 100, y: view.center.y + 100)
        view.addSubview(btn1)
        btn1.addTarget(self, action: #selector(buttonActon1), for: .touchUpInside)
        BadgeManager.shared.observeFor(keyPath: BadgeFirst.button1, badgeView: btn1, block: nil)

        BadgeManager.shared.setBadgeFor(keyPath: BadgeFirst.button0, count: UInt(arc4random() % 9))
        BadgeManager.shared.setBadgeFor(keyPath: BadgeFirst.button1, count: UInt(arc4random() % 9))
    }

    @objc func buttonActon() {
        if BadgeManager.shared.countFor(keyPath: BadgeFirst.button0) > 0 {
            BadgeManager.shared.clearBadgeFor(keyPath: BadgeFirst.button0)
        } else {
            BadgeManager.shared.setBadgeFor(keyPath: BadgeFirst.button0, count: UInt(arc4random() % 9))
        }
    }
    @objc func buttonActon1() {
        if BadgeManager.shared.countFor(keyPath: BadgeFirst.button1) > 0 {
            BadgeManager.shared.clearBadgeFor(keyPath: BadgeFirst.button1)
        } else {
            BadgeManager.shared.setBadgeFor(keyPath: BadgeFirst.button1, count: UInt(arc4random() % 9))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BadgeManager.shared.clearBadgeFor(keyPath: BadgeFirst.root)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BadgeManager.shared.clearBadgeFor(keyPath: BadgeFirst.root)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            BadgeManager.shared.setBadgeFor(keyPath: BadgeSecond.button1)
        }
    }
}

