//
//  SBPlatformDestinationTests
//  SwiftyBeaverTests
//
//  Created by Sebastian Kreutzberger on 22.01.16.
//  Copyright © 2016 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import XCTest
@testable import SwiftyBeaver


class SBPlatformDestinationTests: XCTestCase {

    var platform = SBPlatformDestination(appID: "", appSecret: "", encryptionKey: "")

    struct SBPlatformCredentials {
        var appID = ""
        var appSecret = ""
        var encryptionKey = ""
    }

    override func setUp() {
        super.setUp()
        SwiftyBeaver.removeAllDestinations()

        /*
         ====================================
         IMPORTANT!


         Protect your own platform credentials which are required for the tests:

         1. Create a copy of SecretsExample.swift and name it Secrets.swift
         2. uncomment the Secrets struct which you can find in Secrets.swift
         3. add your credentials to the Secrets struct in Secrets.swift


         It is safe to store your credentials in Secrets.swift because it
         is covered by .gitignore and is not added to Git SCM


         NEVER ADD CREDENTIALS TO GIT, especially on open-source!
         ====================================
        */

        platform = SBPlatformDestination(appID: Secrets.Platform.appID,
            appSecret: Secrets.Platform.appSecret,
            encryptionKey: Secrets.Platform.encryptionKey)
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
        let str = platform.send(.verbose, msg: msg, thread: thread, file: file, function: function, line: line)
        XCTAssertNotNil(str)
        if let str = str {
            XCTAssertEqual(str.characters.first, "{")
            XCTAssertEqual(str.characters.last, "}")
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
        platform.appID = Secrets.Platform.appID
        platform.appSecret = Secrets.Platform.appSecret
        platform.encryptionKey = Secrets.Platform.encryptionKey

        if platform.appID.isEmpty || platform.appSecret.isEmpty || platform.encryptionKey.isEmpty {
            // leave the test on missing credentials
            return
        }

        let jsonStr = "foobar"
        let correctURL = platform.serverURL

        // invalid address
        platform.serverURL = NSURL(string: "https://notexisting.swiftybeaver.com")! as URL
        let exp = expectation(description: "returns false due to invalid URL")

        platform.sendToServerAsync(jsonStr) {
            ok, status in
            XCTAssertFalse(ok)
            XCTAssertEqual(status, 0)
            exp.fulfill()
        }

        // invalid app ID
        platform.serverURL = correctURL
        platform.appID = "abc"
        let exp2 = expectation(description: "returns false due to invalid app ID")

        platform.sendToServerAsync(jsonStr) {
            ok, status in
            XCTAssertFalse(ok)
            XCTAssertEqual(status, 401)
            exp2.fulfill()
        }

        // invalid secret
        platform.appID = Secrets.Platform.appID
        platform.appSecret += "invalid"
        let exp3 = expectation(description: "returns false due to invalid secret")

        platform.sendToServerAsync(jsonStr) {
            ok, status in
            XCTAssertFalse(ok)
            XCTAssertEqual(status, 401)
            exp3.fulfill()
        }

        /*
        // that should work. deactivated to avoid "foobar" messages on serverpost
        platform.appID = Secrets.Platform.appID
        platform.appSecret = Secrets.Platform.appSecret
        platform.encryptionKey = Secrets.Platform.encryptionKey
        let exp4 = expectationWithDescription("returns ok on valid request")

        platform.sendToServerAsync(jsonStr) {
            ok, status in
            XCTAssertTrue(ok)
            XCTAssertEqual(status, 200)
            exp4.fulfill()
        }
        */
        waitForExpectations(timeout: 5, handler: nil)

    }

    func testIntegration() {
        let log = SwiftyBeaver.self
        let formatter = DateFormatter()

        // add logging to SwiftyBeaver Platform
        platform.showNSLog = true
        //let jsonFile = NSURL(string: "file:///tmp/testSBPlatform.json")!
        //deleteFile(NSURL(string: String(jsonFile) + ".send")!)

        platform.appID = Secrets.Platform.appID
        platform.appSecret = Secrets.Platform.appSecret
        platform.encryptionKey = Secrets.Platform.encryptionKey

        if platform.appID.isEmpty || platform.appSecret.isEmpty || platform.encryptionKey.isEmpty {
            // leave the test on missing credentials
            return
        }

        XCTAssertTrue(log.addDestination(platform))
        //XCTAssertEqual(log.countDestinations(), 2)

        // send logs in chunks, use high threshold value to test performance
        platform.sendingPoints.threshold = 20
        for index in 1...platform.sendingPoints.threshold + 3 {
            // simulate work by doing a computing
            var x = 1.0
            for index2 in 1...50000 {
                x = sqrt(Double(index2))
                XCTAssertEqual(x, sqrt(Double(index2)))
            }

            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            let dateStr = formatter.string(from: NSDate() as Date)

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
    }

    func testDeviceDetails() {
        let device = platform.deviceDetails()
        XCTAssertEqual(device["os"], OS)
        XCTAssertGreaterThan(device["os"]!.characters.count, 0)
        XCTAssertGreaterThan(device["osVersion"]!.characters.count, 4)
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

        let dict = platform.analytics(platform.analyticsFileURL!, update: false)
        print(dict)
        if let uuid = dict["uuid"] as? String {
            XCTAssertEqual(uuid.characters.count, 36)
            XCTAssertEqual(uuid, platform.analyticsUUID)
        }
        if let firstStart = dict["firstStart"] as? String {
            XCTAssertEqual(firstStart.characters.count, 23)
        }
        if let lastStart = dict["lastStart"] as? String {
            XCTAssertEqual(lastStart.characters.count, 23)
        }
        if let starts = dict["starts"] as? Int {
            XCTAssertGreaterThanOrEqual(starts, 1)
        }
        if let userName = dict["userName"] as? String {
            XCTAssertEqual(userName, "")
        }

        XCTAssertTrue(platform.saveDictToFile(dict, url: platform.analyticsFileURL!))

        // set userName
        platform.analyticsUserName = "foo@bar.com"
        let dict2 = platform.analytics(platform.analyticsFileURL!, update: false)
        if let userName = dict2["userName"] as? String {
            XCTAssertEqual(userName, "foo@bar.com")
        }
        XCTAssertEqual(platform.analyticsUserName, "foo@bar.com")
    }



    /// helper function to delete temp file before test
    func deleteFile(url: NSURL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url as URL)
            return true
        } catch let error {
            NSLog("Unit test: could not delete file \(url). \(error)")
        }
        return false
    }
}
