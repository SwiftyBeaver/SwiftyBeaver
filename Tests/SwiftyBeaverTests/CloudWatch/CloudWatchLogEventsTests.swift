//
//  CloudWatchLogEventsTests.swift
//  SwiftyBeaver/CloudWatch
//

#if CLOUD_WATCH

import Foundation
import XCTest
@testable import SwiftyBeaver

class CloudWatchLogEventsTests: XCTestCase {
    var logEvents: CloudWatchLogEvents! = nil

    override func setUp() {
        super.setUp()
        logEvents = CloudWatchLogEvents()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testInit() {
        XCTAssertNotNil(logEvents.request)
        XCTAssertEqual(logEvents.request.logEvents, [])
    }
    
    func testEvents() {
        XCTAssertEqual(logEvents.events, [])
    }
    
    func testAdd() {
        logEvents.add(message: "This is a log message")
        logEvents.add(message: "This is another log message")
        
        XCTAssertEqual(logEvents.events.count,2)
        XCTAssertEqual(logEvents.events[0].message, "This is a log message")
        XCTAssertNotNil(logEvents.events[0].timestamp)
        XCTAssertEqual(logEvents.events[1].message, "This is another log message")
        XCTAssertNotNil(logEvents.events[1].timestamp)
    }

    static var allTests = [
        ("testInit", testInit),
        ("testEvents", testEvents),
        ("testAdd", testAdd)
    ]

}

#endif
