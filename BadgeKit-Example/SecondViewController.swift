//
//  SecondViewController.swift
//  BadgeKit-Example
//
//  Created by saucymqin on 2018/11/14.
//  Copyright © 2018 413132340@qq.com. All rights reserved.
//

import UIKit
import BadgeKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BadgeManager.shared.clearBadgeFor(keyPath: Second.root)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BadgeManager.shared.clearBadgeFor(keyPath: Second.root)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            BadgeManager.shared.setBadgeFor(keyPath: First.button(0))
        }
    }
}

