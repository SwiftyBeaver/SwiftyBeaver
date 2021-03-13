//
//  CloudWatchLogStreamTests.swift
//  SwiftyBeaver/CloudWatch
//

#if CLOUD_WATCH

import Foundation
import XCTest
import AWSLogs

@testable import SwiftyBeaver

class CloudWatchLogStreamTests: XCTestCase {
    var group: CloudWatchLogGroup! = nil
    var config: AWSServiceConfigMock! = nil
    var logs: CloudWatchLogsMock! = nil
    var logStream: CloudWatchLogStream! = nil
    
    override func setUp() {
        super.setUp()
        group = CloudWatchLogGroup(name: "/my/log/group")
        config = AWSServiceConfigMock(cognitoPoolId: "12345", regionType: .USWest2).create()
        logs = CloudWatchLogsMock(config: config, clientKey: "myClientKey").initialize()
        logStream = CloudWatchLogStream(cloudWatchLogs: logs, group: group, name: "/my/stream/name")
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInit() {
        XCTAssertEqual(logStream.name, "/my/stream/name")
        XCTAssertNotNil(logStream.group)
        XCTAssertEqual(logStream.group.name, group.name)
    }
    
    func testCreate() {
        logStream.create() { error in
            XCTAssertNil(error)
        }
        
        XCTAssertTrue(logs.createLogStreamCalled)
        XCTAssertNotNil(logs.createStreamRequest!)
        XCTAssertEqual(logs.createStreamRequest?.logGroupName, group.name)
        XCTAssertEqual(logs.createStreamRequest?.logStreamName, logStream.name)
    }
    
    func testSendEvents() {
        let logEvents = CloudWatchLogEvents()
        logEvents.add(message: "This is a log message")
        logEvents.add(message: "This is another log message")
        
        logStream.sendEvents(events: logEvents) { error, resp in
            XCTAssertNil(resp)
            XCTAssertNil(error)
        }
        
        XCTAssertTrue(logs.putEventsCalled)
        XCTAssertNotNil(logs.putEventsRequest!)
        XCTAssertEqual(logs.putEventsRequest?.logGroupName, group.name)
        XCTAssertEqual(logs.putEventsRequest?.logStreamName, logStream.name)
        XCTAssertEqual(logs.putEventsRequest?.logEvents?.count,2)
        XCTAssertEqual(logs.putEventsRequest?.logEvents?[0].message, "This is a log message")
        XCTAssertNotNil(logs.putEventsRequest?.logEvents?[0].timestamp)
        XCTAssertEqual(logs.putEventsRequest?.logEvents?[1].message, "This is another log message")
        XCTAssertNotNil(logs.putEventsRequest?.logEvents?[1].timestamp)
    }

    static var allTests = [
        ("testInit", testInit),
        ("testCreate", testCreate),
        ("testSendEvents", testSendEvents)
    ]

}

#endif
