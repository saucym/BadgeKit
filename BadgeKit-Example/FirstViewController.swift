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

        BadgeManager.shared.observeFor(keyPath: Badge.firstButton, badgeView: btn, block: nil)

        let btn1 = UIButton(type: .contactAdd)
        btn1.center = CGPoint(x: view.center.x + 100, y: view.center.y + 100)
        view.addSubview(btn1)
        btn1.addTarget(self, action: #selector(buttonActon1), for: .touchUpInside)
        BadgeManager.shared.observeFor(keyPath: Badge.firstButton1, badgeView: btn1, block: nil)
    }

    @objc func buttonActon() {
        BadgeManager.shared.setBadgeFor(keyPath: Badge.firstButton, count: UInt(arc4random() % 99))
    }
    @objc func buttonActon1() {
        BadgeManager.shared.setBadgeFor(keyPath: Badge.firstButton1, count: UInt(arc4random() % 99))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BadgeManager.shared.clearBadgeFor(keyPath: Badge.first)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BadgeManager.shared.clearBadgeFor(keyPath: Badge.first)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            BadgeManager.shared.setBadgeFor(keyPath: Badge.second)
        }
    }
}

