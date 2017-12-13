//
//  GoogleCloudDestinationTests.swift
//  SwiftyBeaver
//
//  Created by Laurent Gaches on 10/04/2017.
//  Copyright © 2017 Sebastian Kreutzberger. All rights reserved.
//
import Foundation
import XCTest
@testable import SwiftyBeaver

class GoogleCloudDestinationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        SwiftyBeaver.removeAllDestinations()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testUseGoogleCloudPDestination() {
        let log = SwiftyBeaver.self
        let gcpDestination = GoogleCloudDestination(serviceName: "TEST")
        gcpDestination.minLevel = .verbose
        XCTAssertTrue(log.addDestination(gcpDestination))
    }

    func testSend() {
        // let dateStr = formatter.stringFromDate(NSDate())
        //let platform = SBPlatformDestination()
        let msg = "test message\nNewlineäößø"
        let thread = ""
        let file = "/file/path.swift"
        let function = "TestFunction()"
        let line = 123

        let gcpDestination = GoogleCloudDestination(serviceName: "TEST")
        let str = gcpDestination.send(.verbose, msg: msg, thread: thread, file: file, function: function, line: line)
        XCTAssertNotNil(str)
        if let str = str {
            XCTAssertEqual(str.firstChar, "{")
            XCTAssertEqual(str.lastChar, "}")
            XCTAssertNotNil(str.range(of: "{\"service\":\"TEST\"}"))
            XCTAssertNotNil(str.range(of: "\"severity\":\"DEBUG\""))
            XCTAssertNotNil(str.range(of: "\"message\":\"test message\\nNewlineäößø\""))
            XCTAssertNotNil(str.range(of: "\"functionName\":\"TestFunction()\""))
        }
    }

    func testContextMessage() {
        let msg = "test message\nNewlineäößø"
        let thread = ""
        let file = "/file/path.swift"
        let function = "TestFunction()"
        let line = 123

        let gcd = GoogleCloudDestination(serviceName: "SwiftyBeaver")

        let str = gcd.send(.verbose, msg: msg, thread: thread, file: file, function: function, line: line,
                           context:  ["user": "Beaver", "httpRequest": ["method": "GET", "responseStatusCode": 200]])

        XCTAssertNotNil(str)
        if let str = str {
            XCTAssertEqual(str.firstChar, "{")
            XCTAssertEqual(str.lastChar, "}")
            XCTAssertNotNil(str.range(of: "{\"service\":\"SwiftyBeaver\"}"))
            XCTAssertNotNil(str.range(of: "\"severity\":\"DEBUG\""))
            XCTAssertNotNil(str.range(of: "\"message\":\"test message\\nNewlineäößø\""))
            XCTAssertNotNil(str.range(of: "\"functionName\":\"TestFunction()\""))
            XCTAssertNotNil(str.range(of: "\"user\":\"Beaver\""))
            XCTAssertNotNil(str.range(of: "\"method\":\"GET\""))
            XCTAssertNotNil(str.range(of: "\"responseStatusCode\":200"))
        }

    }

    static var allTests = [
        ("testUseGoogleCloudPDestination", testUseGoogleCloudPDestination),
        ("testSend", testSend),
        ("testContextMessage", testContextMessage)
    ]

}
