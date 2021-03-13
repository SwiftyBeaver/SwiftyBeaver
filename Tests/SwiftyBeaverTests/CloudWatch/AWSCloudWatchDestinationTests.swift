//
//  AWSCloudWatchDestinationTests.swift
//  SwiftyBeaver/CloudWatch
//

#if CLOUD_WATCH

import Foundation
import XCTest
import AWSCore
@testable import SwiftyBeaver

class AWSCloudWatchDestinationTests: XCTestCase {
    var destination: AWSCloudWatchDestination! = nil
    var logs: CloudWatchLogsMock! = nil
    var group: CloudWatchLogGroup! = nil
    var logStream: CloudWatchLogStream! = nil

    override func setUp() {
        super.setUp()
        group = CloudWatchLogGroup(name: "/my/log/group")
        let config = AWSServiceConfigMock(cognitoPoolId: "12345", regionType: .USWest2).create()
        logs = CloudWatchLogsMock(config: config, clientKey: "myClientKey").initialize()
        logStream = CloudWatchLogStream(cloudWatchLogs: logs, group: group, name: "/my/stream/name")
        destination = AWSCloudWatchDestination(logStream: logStream)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInit() {
        XCTAssertNotNil(destination.logStream)
    }
    
    func testSend() {
        let message = destination.send(.debug, msg: "This is a log message", thread: "",
                         file: "AWSCloudWatchDestinationTests", function: "testSend", line: 38, context: nil)
        
        XCTAssertEqual(message!, "{\"level\":\"debug\",\"message\":\"This is a log message\",\"function\":\"testSend\",\"fileName\":\"AWSCloudWatchDestinationTests\",\"line\":38}")
        
        let expectation = self.expectation(description: "foo")

        DispatchQueue.main.asyncAfter(deadline: .now() + 11.0) {
            XCTAssertTrue(self.logs.putEventsCalled)
            XCTAssertNotNil(self.logs.putEventsRequest!)
            XCTAssertEqual(self.logs.putEventsRequest?.logGroupName, self.group.name)
            XCTAssertEqual(self.logs.putEventsRequest?.logStreamName, self.logStream.name)
            XCTAssertEqual(self.logs.putEventsRequest?.logEvents?.count,1)
            XCTAssertEqual(self.logs.putEventsRequest?.logEvents?[0].message, "{\"level\":\"debug\",\"message\":\"This is a log message\",\"function\":\"testSend\",\"fileName\":\"AWSCloudWatchDestinationTests\",\"line\":38}")
            XCTAssertNotNil(self.logs.putEventsRequest?.logEvents?[0].timestamp)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 15.0)
    }

   
    static var allTests = [
        ("testInit", testInit),
        ("testSend", testSend)
    ]

}

#endif
