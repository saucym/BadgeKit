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
        var rect = view.bounds.insetBy(dx: 30, dy: 150)
        rect.origin.y += 150
        rect.size.height = 80
        (0..<2).forEach { (section) in
            let stackView = UIStackView(frame: rect)
            stackView.alignment    = .center
            stackView.distribution = .equalSpacing
            stackView.axis         = .horizontal;
            stackView.spacing      = 40;
            view.addSubview(stackView)
            
            (0..<4).forEach { (index) in
                let tag = section * 1000 + index
                let btn = UIButton(type: .contactAdd)
                btn.tag = tag
                btn.addTarget(self, action: #selector(buttonActon(_:)), for: .touchUpInside)
                stackView.addArrangedSubview(btn)
                
                BadgeManager.shared.observeFor(keyPath: First.button(tag), badgeView: btn, changedBlock: { (modle, isAdd) in
                    print("\(modle), isAdd: \(isAdd)")
                })
                BadgeManager.shared.setBadgeFor(keyPath: First.button(tag), count: UInt(arc4random() % 99))
            }
            rect.origin.y += rect.size.height
        }
    }

    @objc func buttonActon(_ sender: UIButton) {
        if BadgeManager.shared.recursiveStatusFor(keyPath: First.button(sender.tag)) == true {
            BadgeManager.shared.clearBadgeFor(keyPath: First.button(sender.tag))
        } else {
            BadgeManager.shared.setBadgeFor(keyPath: First.button(sender.tag), count: UInt(arc4random() % 1999))
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

