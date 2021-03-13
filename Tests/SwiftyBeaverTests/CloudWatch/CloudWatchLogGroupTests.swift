//
//  CloudWatchLogGroupTests.swift
//  SwiftyBeaver/CloudWatch
//

#if CLOUD_WATCH

import Foundation
import XCTest
@testable import SwiftyBeaver

class CloudWatchLogGroupTests: XCTestCase {
    var group: CloudWatchLogGroup! = nil

    override func setUp() {
        super.setUp()
        group = CloudWatchLogGroup(name: "/my/log/group")
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInit() {
        XCTAssertEqual(group.name, "/my/log/group")
    }

   
    static var allTests = [
        ("testInit", testInit)
    ]

}

#endif
