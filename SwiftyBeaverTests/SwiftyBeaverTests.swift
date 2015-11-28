//
//  SwiftyBeaverTests.swift
//  SwiftyBeaverTests
//
//  Created by Sebastian Kreutzberger (Twitter @skreutzb) on 28.11.15.
//  Copyright © 2015 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import XCTest
@testable import SwiftyBeaver

class SwiftyBeaverTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFormattedDate () {
        // empty format
        var str = SwiftyBeaver.formattedDate("")
        XCTAssertEqual(str, "")
        // no time format
        str = SwiftyBeaver.formattedDate("--")
        XCTAssertGreaterThanOrEqual(str, "--")
        // year
        str = SwiftyBeaver.formattedDate("yyyy")
        XCTAssertGreaterThanOrEqual(Int(str)!, 2015)
    }
    
}
