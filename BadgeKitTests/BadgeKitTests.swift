//
//  BadgeKitTests.swift
//  BadgeKitTests
//
//  Created by saucymqin on 2018/8/22.
//  Copyright © 2018年 413132340@qq.com. All rights reserved.
//

import XCTest
@testable import BadgeKit

class BadgeKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBadgeManager() {
        BadgeManager.shared.setBadgeFor(keyPath: "abc")
        BadgeManager.shared.setBadgeFor(keyPath: "ddd", count: 12)
        DispatchQueue.main.async {
            XCTAssert(BadgeManager.shared.recursiveStatusFor(keyPath: "abc"))
            XCTAssert(BadgeManager.shared.recursiveStatusFor(keyPath: "ddd"))
            XCTAssert(BadgeManager.shared.recursiveCountFor(keyPath: "ddd") == 12)
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
