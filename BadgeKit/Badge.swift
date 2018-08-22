//
//  Badge.swift
//  BadgeKit
//
//  Created by saucymqin on 2018/8/22.
//  Copyright © 2018年 413132340@qq.com. All rights reserved.
//

import UIKit

public class Badge: NSObject {
    public let keyPath: NSString!
    public let count: UInt
    public init(keyPath: NSString, count: UInt) {
        self.keyPath = keyPath
        self.count = count
        super.init()
    }
}
