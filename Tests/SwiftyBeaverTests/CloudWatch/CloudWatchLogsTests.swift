//
//  CloudWatchLogsTests.swift
//  SwiftyBeaver/CloudWatch
//

#if CLOUD_WATCH

import Foundation
import XCTest
import AWSCore
import AWSLogs
@testable import SwiftyBeaver

class CloudWatchLogsTests: XCTestCase {
    var config: AWSServiceConfigMock! = nil
    var awsConfiguration: AWSServiceConfiguration! = nil
    var logs: CloudWatchLogs! = nil
    
    override func setUp() {
        super.setUp()
        config = AWSServiceConfigMock(cognitoPoolId: "12345", regionType: .USWest2).create()
        awsConfiguration = config.configuration
        logs = CloudWatchLogs(config: config, clientKey: "myClientKey")
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInit() {
        XCTAssertEqual(logs.clientKey, "myClientKey")
        XCTAssertEqual(logs.configuration, awsConfiguration)
    }
    
    func testInitialize() {
        _ = logs.initialize()
        XCTAssertEqual(logs.clientKey, "myClientKey")
        XCTAssertEqual(logs.configuration, awsConfiguration)
        XCTAssertNotNil(logs.logs)
    }

    func testCreateLogStream() {
        _ = logs.initialize()
        let logStreamRequest = AWSLogsCreateLogStreamRequest()!
        logStreamRequest.logGroupName = "/my/group/name"
        logStreamRequest.logStreamName = "/my/stream/name"
        logs.createLogStream(logStreamRequest) { error in
            XCTAssertNil(error)
        }
    }
    
    func testPutLogEvents() {
        _ = logs.initialize()
        let request = AWSLogsPutLogEventsRequest()!
        request.logEvents = []
        let event = AWSLogsInputLogEvent()!
        event.message = "This is a log message"
        event.timestamp = NSNumber(value: Date().timeIntervalSince1970 * 1000)
        request.logEvents?.append(event)
        logs.putLogEvents(request) { resp, error in
            XCTAssertNil(resp)
            XCTAssertNil(error)
        }
    }

   
    static var allTests = [
        ("testInit", testInit),
        ("testInitialize", testInitialize),
        ("testCreateLogStream", testCreateLogStream),
        ("testPutLogEvents", testPutLogEvents)
    ]

}

#endif
