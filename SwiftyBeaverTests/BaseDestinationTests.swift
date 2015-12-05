//
//  BaseDestinationTests.swift
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger on 05.12.15.
//  Copyright © 2015 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import XCTest
@testable import SwiftyBeaver

class BaseDestinationTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInit() {
        let obj = BaseDestination()
        XCTAssertNotNil(obj.queue)
    }
    
    func testFormattedDate() {
        // empty format
        var str = BaseDestination().formattedDate("")
        XCTAssertEqual(str, "")
        // no time format
        str = BaseDestination().formattedDate("--")
        XCTAssertGreaterThanOrEqual(str, "--")
        // HH:mm:ss
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let dateStr = formatter.stringFromDate(NSDate())
        str = BaseDestination().formattedDate(formatter.dateFormat)
        XCTAssertEqual(str, dateStr)
    }

    func tesFormattedLevel() {
        let obj = BaseDestination()
        var str = ""
        
        str = obj.formattedLevel(SwiftyBeaver.Level.Verbose)
        XCTAssertNotNil(str, "VERBOSE")
        str = obj.formattedLevel(SwiftyBeaver.Level.Debug)
        XCTAssertNotNil(str, "DEBUG")
        str = obj.formattedLevel(SwiftyBeaver.Level.Info)
        XCTAssertNotNil(str, "INFO")
        str = obj.formattedLevel(SwiftyBeaver.Level.Warning)
        XCTAssertNotNil(str, "WARNING")
        str = obj.formattedLevel(SwiftyBeaver.Level.Error)
        XCTAssertNotNil(str, "ERROR")
    }

    func testFormattedMessage() {
        let obj = BaseDestination()
        var str = ""
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let dateStr = formatter.stringFromDate(NSDate())
        
        str = obj.formattedMessage(dateStr, levelString: "DEBUG", msg: "Hello", path: "/path/to/ViewController.swift", function: "testFunction()", line: 50, detailOutput: false)
        XCTAssertNotNil(str.rangeOfString("[\(dateStr)] DEBUG: Hello"))

        str = obj.formattedMessage(dateStr, levelString: "DEBUG", msg: "Hello", path: "/path/to/ViewController.swift", function: "testFunction()", line: 50, detailOutput: true)
        print(str)
        XCTAssertNotNil(str.rangeOfString("[\(dateStr)] ViewController.testFunction():50 DEBUG: Hello"))

    }
}
