//
//  SBPlatformDestinationTests
//  SwiftyBeaverTests
//
//  Created by Sebastian Kreutzberger on 22.01.16.
//  Copyright © 2016 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation
import XCTest
@testable import SwiftyBeaver

class SBPlatformDestinationTests: XCTestCase {

    var platform = SBPlatformDestination(appID: "", appSecret: "", encryptionKey: "")

    struct SBPlatformCredentials {
        /*
            use environment variables to inject platform credentials into the tests
            set in Terminal via:

            export SBPLATFORM_SERVER_URL=
            export SBPLATFORM_APP_ID=
            export SBPLATFORM_APP_SECRET=
            export SBPLATFORM_ENCRYPTION_KEY=
        */
        static let serverURL = ProcessInfo.processInfo.environment["SBPLATFORM_SERVER_URL"] ?? "https://api.swiftybeaver.com/api/entries/"
        static let appID = ProcessInfo.processInfo.environment["SBPLATFORM_APP_ID"] ?? ""
        static let appSecret = ProcessInfo.processInfo.environment["SBPLATFORM_APP_SECRET"] ?? ""
        static let encryptionKey = ProcessInfo.processInfo.environment["SBPLATFORM_ENCRYPTION_KEY"] ?? ""
    }

    override func setUp() {
        super.setUp()
        SwiftyBeaver.removeAllDestinations()
        platform = SBPlatformDestination(
            appID:          SBPlatformCredentials.appID,
            appSecret:      SBPlatformCredentials.appSecret,
            encryptionKey:  SBPlatformCredentials.encryptionKey,
            serverURL:      URL(string: SBPlatformCredentials.serverURL)
        )
        // uncomment to verify that the env vars "arrive" in the tests
        print("\nTesting SBPlatform using")
        print("Server URL: \(platform.serverURL!)")
        print("App ID: \(platform.appID)")
        print("App Secret: \(platform.appSecret)")
        print("Encryption Key: \(platform.encryptionKey)\n")
    }

    override func tearDown() {
        super.tearDown()
    }

    func testLoggingWithoutDestination() {
        let log = SwiftyBeaver.self
        // no destination was set, yet
        log.verbose("Where do I log to?")
    }

    func testSend() {
        // let dateStr = formatter.stringFromDate(NSDate())
        //let platform = SBPlatformDestination()
        let msg = "test message\nNewlineäößø"
        let thread = ""
        let file = "/file/path.swift"
        let function = "TestFunction()"
        let line = 123
        platform.showNSLog = true
        let str = platform.send(.verbose, msg: msg, thread: thread, file: file, function: function, line: line)
        XCTAssertNotNil(str)
        if let str = str {
            XCTAssertEqual(str.first, "{")
            XCTAssertEqual(str.last, "}")
            XCTAssertNotNil(str.range(of: "\"line\":123"))
            XCTAssertNotNil(str.range(of: "\"message\":\"test message\\nNewlineäößø\""))
            XCTAssertNotNil(str.range(of: "\"fileName\":\"path.swift\""))
            XCTAssertNotNil(str.range(of: "\"timestamp\":"))
            XCTAssertNotNil(str.range(of: "\"level\":0"))
            XCTAssertNotNil(str.range(of: "\"thread\":\"\""))
            XCTAssertNotNil(str.range(of: "\"function\":\"TestFunction()\""))
        }
    }

    func testSendingPointsFromLevel() {
        var points = platform.sendingPointsForLevel(SwiftyBeaver.Level.verbose)
        XCTAssertEqual(points, platform.sendingPoints.verbose)
        points = platform.sendingPointsForLevel(SwiftyBeaver.Level.debug)
        XCTAssertEqual(points, platform.sendingPoints.debug)
        points = platform.sendingPointsForLevel(SwiftyBeaver.Level.info)
        XCTAssertEqual(points, platform.sendingPoints.info)
        points = platform.sendingPointsForLevel(SwiftyBeaver.Level.warning)
        XCTAssertEqual(points, platform.sendingPoints.warning)
        points = platform.sendingPointsForLevel(SwiftyBeaver.Level.error)
        XCTAssertEqual(points, platform.sendingPoints.error)
    }

    func testSendToServerAsync() {
        if platform.appID.isEmpty || platform.appSecret.isEmpty || platform.encryptionKey.isEmpty {
            // leave the test on missing credentials
            print("leaving SBPlatform tests due to empty credentials")
            return
        }

        let jsonStr = "foobar"
        let correctURL = platform.serverURL

        // invalid address
        if let serverURL = URL(string: "https://notexisting.swiftybeaver.com") {
            platform.serverURL = serverURL
        }
        let exp = expectation(description: "returns false due to invalid URL")

        platform.sendToServerAsync(jsonStr) { ok, status in
            XCTAssertFalse(ok)
            XCTAssertEqual(status, 0)
            exp.fulfill()
        }
        waitForExpectations(timeout: 11, handler: nil)

        // invalid app ID
        platform.serverURL = correctURL
        platform.appID = "abc"
        let exp2 = expectation(description: "returns false due to invalid app ID")

        platform.sendToServerAsync(jsonStr) { ok, status in
            XCTAssertFalse(ok)
            XCTAssertEqual(status, 401)
            exp2.fulfill()
        }
        waitForExpectations(timeout: 11, handler: nil)

        // invalid secret
        platform.appID = SBPlatformCredentials.appID
        platform.appSecret += "invalid"
        let exp3 = expectation(description: "returns false due to invalid secret")

        platform.sendToServerAsync(jsonStr) { ok, status in
            XCTAssertFalse(ok)
            XCTAssertEqual(status, 401)
            exp3.fulfill()
        }

        /*
        // that should work. deactivated to avoid "foobar" messages on serverpost
        platform.appID = SBPlatformCredentials.appID
        platform.appSecret = SBPlatformCredentials.appSecret
        platform.encryptionKey = SBPlatformCredentials.encryptionKey
        let exp4 = expectationWithDescription("returns ok on valid request")

        platform.sendToServerAsync(jsonStr) {
            ok, status in
            XCTAssertTrue(ok)
            XCTAssertEqual(status, 200)
            exp4.fulfill()
        }
        */
        waitForExpectations(timeout: 11, handler: nil)

    }

    func testSingleSending() {
        let log = SwiftyBeaver.self

        // add logging to SwiftyBeaver Platform
        platform.showNSLog = true
        //let jsonFile = NSURL(fileURLWithPath: "/tmp/testSBPlatform.json")!
        //deleteFile(NSURL(string: String(jsonFile) + ".send")!)

        if platform.appID.isEmpty || platform.appSecret.isEmpty || platform.encryptionKey.isEmpty {
            // leave the test on missing credentials
            print("leaving SBPlatform test testIntegration() due to empty credentials")
            return
        }

        XCTAssertTrue(log.addDestination(platform))
        //XCTAssertEqual(log.countDestinations(), 2)

        // send logs in chunks, use high threshold value to test performance
        platform.sendingPoints.threshold = 10
        log.verbose("a verbose message 1")
        log.debug("a debug message 2")
        log.info("an info message 3")
        log.error("an error message 4")
        
        print("waiting")
        // do some further waiting for sending to complete
        for _ in 1...platform.sendingPoints.threshold + 3 {
            // simulate work by doing a computing
            var x = 1.0
            for index2 in 1...50000 {
                x = sqrt(Double(index2))
                XCTAssertEqual(x, sqrt(Double(index2)))
            }
        }
        sleep(5)
        print("finished")
    }
    
    func testIntegration() {
        let log = SwiftyBeaver.self
        let formatter = DateFormatter()
        
        // add logging to SwiftyBeaver Platform
        platform.showNSLog = true
        //let jsonFile = NSURL(fileURLWithPath: "/tmp/testSBPlatform.json")!
        //deleteFile(NSURL(string: String(jsonFile) + ".send")!)
        
        if platform.appID.isEmpty || platform.appSecret.isEmpty || platform.encryptionKey.isEmpty {
            // leave the test on missing credentials
            print("leaving SBPlatform test testIntegration() due to empty credentials")
            return
        }
        
        XCTAssertTrue(log.addDestination(platform))
        //XCTAssertEqual(log.countDestinations(), 2)
        
        // send logs in chunks, use high threshold value to test performance
        platform.sendingPoints.threshold = 10
        for index in 1...platform.sendingPoints.threshold + 3 {
            // simulate work by doing a computing
            var x = 1.0
            for index2 in 1...50000 {
                x = sqrt(Double(index2))
                XCTAssertEqual(x, sqrt(Double(index2)))
            }
            
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            let dateStr = formatter.string(from: Date())
            
            log.debug("msg \(index) - \(dateStr)")
        }
        XCTAssertTrue(log.flush(secondTimeout: 3))
        
        // do some further waiting for sending to complete
        for _ in 1...platform.sendingPoints.threshold + 3 {
            // simulate work by doing a computing
            var x = 1.0
            for index2 in 1...50000 {
                x = sqrt(Double(index2))
                XCTAssertEqual(x, sqrt(Double(index2)))
            }
        }
        print("waiting")
        sleep(5)
        print("finished")
    }

    func testDeviceDetails() {
        let device = platform.deviceDetails()
        XCTAssertEqual(device["os"], OS)
        XCTAssertGreaterThan(device["os"]!.length, 0)
        XCTAssertGreaterThan(device["osVersion"]!.length, 4)
        XCTAssertEqual(device["hostName"], ProcessInfo.processInfo.hostName)
        XCTAssertEqual(device["deviceName"], DEVICE_NAME)
        XCTAssertEqual(device["deviceModel"], DEVICE_MODEL)
        //NSLog(stats)
    }

    func testAnalytics() {
        if platform.appID.isEmpty || platform.appSecret.isEmpty || platform.encryptionKey.isEmpty {
            // leave the test on missing credentials or Travis will fail
            return
        }

        let dict = platform.analytics(platform.analyticsFileURL, update: false)
        print(dict)
        if let uuid = dict["uuid"] as? String {
            XCTAssertEqual(uuid.length, 36)
            XCTAssertEqual(uuid, platform.analyticsUUID)
        }
        if let firstStart = dict["firstStart"] as? String {
            XCTAssertEqual(firstStart.length, 23)
        }
        if let lastStart = dict["lastStart"] as? String {
            XCTAssertEqual(lastStart.length, 23)
        }
        if let starts = dict["starts"] as? Int {
            XCTAssertGreaterThanOrEqual(starts, 1)
        }
        if let userName = dict["userName"] as? String {
            XCTAssertEqual(userName, "")
        }

        XCTAssertTrue(platform.saveDictToFile(dict, url: platform.analyticsFileURL))

        // set userName
        platform.analyticsUserName = "foo@bar.com"
        let dict2 = platform.analytics(platform.analyticsFileURL, update: false)
        if let userName = dict2["userName"] as? String {
            XCTAssertEqual(userName, "foo@bar.com")
        }
        XCTAssertEqual(platform.analyticsUserName, "foo@bar.com")
    }

    /// helper function to delete temp file before test
    func deleteFile(url: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url as URL)
            return true
        } catch let error {
            NSLog("Unit test: could not delete file \(url). \(error)")
        }
        return false
    }

    // MARK: Linux allTests

    static let allTests = [
        ("testLoggingWithoutDestination", testLoggingWithoutDestination),
        ("testSend", testSend),
        ("testSendingPointsFromLevel", testSendingPointsFromLevel),
        ("testSendToServerAsync", testSendToServerAsync),
        ("testIntegration", testIntegration),
        ("testDeviceDetails", testDeviceDetails),
        ("testAnalytics", testAnalytics)
    ]
}
