//
//  ElasticSearchDestinationTests.swift
//  SwiftyBeaver
//
//  Created by Konstantin Klitenik on 8/27/17.
//  Copyright © 2017 Sebastian Kreutzberger. All rights reserved.
//

import XCTest
@testable import SwiftyBeaver

class ElasticSearchDestinationTests: XCTestCase {
    
    var elastic: ElasticSearchDestination!

    
    override func setUp() {
        super.setUp()
        SwiftyBeaver.removeAllDestinations()
        
        let serverUrl = URL(string: "https://youresurl.com")!
        elastic = ElasticSearchDestination(esServerURL: serverUrl, requestSigner: { request in
            request.addValue("your-api-key", forHTTPHeaderField: "x-api-key")
        })
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testUseElasticSearchDestination() {
        let log = SwiftyBeaver.self
        elastic.minLevel = .verbose
        XCTAssertTrue(log.addDestination(elastic))
    }
    
    func testSend() {
        let msg = "test message\nNewline"
        let thread = ""
        let file = "/file/path.swift"
        let function = "TestFunction()"
        let line = 123
        elastic.showNSLog = true
        let str = elastic.send(.info, msg: msg, thread: thread, file: file, function: function, line: line)
        XCTAssertNotNil(str)
        print(str!)
        if let str = str {
            XCTAssertEqual(str.characters.first, "{")
            XCTAssertEqual(str.characters.last, "}")
            XCTAssertNotNil(str.range(of: "\"line\":123"))
            XCTAssertNotNil(str.range(of: "\"message\":\"test message\\nNewline\""))
            XCTAssertNotNil(str.range(of: "\"fileName\":\"path.swift\""))
            XCTAssertNotNil(str.range(of: "\"timestamp\":"))
            XCTAssertNotNil(str.range(of: "\"level\":2"))
            XCTAssertNotNil(str.range(of: "\"thread\":\"\""))
            XCTAssertNotNil(str.range(of: "\"function\":\"TestFunction()\""))
        }
        
        let expect = expectation(description: "Wait for ElasticSearch send")
        
        XCTWaiter().wait(for: [expect], timeout: 3)
    }
    
    static let allTests = [
        ("testSend", testSend)
    ]
}
