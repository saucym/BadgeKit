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
        
        var rect = view.bounds.insetBy(dx: 15, dy: 150)
        rect.origin.y += 150
        let stackView = UIStackView(frame: rect)
        stackView.alignment    = .center
        stackView.distribution = .equalSpacing
        stackView.axis         = .horizontal;
        stackView.spacing      = 40;
        view.addSubview(stackView)
        
        (0..<6).forEach { (index) in
            let btn = UIButton(type: .contactAdd)
            btn.center = CGPoint(x: view.center.x, y: view.center.y + 100)
            btn.tag = index
            btn.addTarget(self, action: #selector(buttonActon(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(btn)
            
            BadgeManager.shared.observeFor(keyPath: First.button(index), badgeView: btn, block: nil)
            BadgeManager.shared.setBadgeFor(keyPath: First.button(index), count: UInt(arc4random() % 9))
        }
    }

    @objc func buttonActon(_ sender: UIButton) {
        if BadgeManager.shared.countFor(keyPath: First.button(sender.tag)) > 0 {
            BadgeManager.shared.clearBadgeFor(keyPath: First.button(sender.tag))
        } else {
            BadgeManager.shared.setBadgeFor(keyPath: First.button(sender.tag), count: UInt(arc4random() % 9))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BadgeManager.shared.clearBadgeFor(keyPath: First.root)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BadgeManager.shared.clearBadgeFor(keyPath: First.root)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            BadgeManager.shared.setBadgeFor(keyPath: Second.button(1))
        }
    }
}

