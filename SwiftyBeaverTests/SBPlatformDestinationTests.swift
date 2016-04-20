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
        let path = "/file/path.swift"
        let function = "TestFunction()"
        let line = 123
        let str = platform.send(.Verbose, msg: msg, thread: thread, path: path, function: function, line: line)
        XCTAssertNotNil(str)
        if let str = str {
            XCTAssertEqual(str.characters.first, "{")
            XCTAssertEqual(str.characters.last, "}")
            XCTAssertNotNil(str.rangeOfString("\"line\":123"))
            XCTAssertNotNil(str.rangeOfString("\"message\":\"test message\\nNewlineäößø\""))
            XCTAssertNotNil(str.rangeOfString("\"fileName\":\"path.swift\""))
            XCTAssertNotNil(str.rangeOfString("\"timestamp\":"))
            XCTAssertNotNil(str.rangeOfString("\"level\":0"))
            XCTAssertNotNil(str.rangeOfString("\"thread\":\"\""))
            XCTAssertNotNil(str.rangeOfString("\"function\":\"TestFunction()\""))
        }
    }

    func testSendingPointsFromLevel() {
        var points = platform.sendingPointsForLevel(SwiftyBeaver.Level.Verbose)
        XCTAssertEqual(points, platform.sendingPoints.Verbose)
        points = platform.sendingPointsForLevel(SwiftyBeaver.Level.Debug)
        XCTAssertEqual(points, platform.sendingPoints.Debug)
        points = platform.sendingPointsForLevel(SwiftyBeaver.Level.Info)
        XCTAssertEqual(points, platform.sendingPoints.Info)
        points = platform.sendingPointsForLevel(SwiftyBeaver.Level.Warning)
        XCTAssertEqual(points, platform.sendingPoints.Warning)
        points = platform.sendingPointsForLevel(SwiftyBeaver.Level.Error)
        XCTAssertEqual(points, platform.sendingPoints.Error)
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
        platform.serverURL = NSURL(string: "https://notexisting.swiftybeaver.com")!
        let exp = expectationWithDescription("returns false due to invalid URL")

        platform.sendToServerAsync(jsonStr) {
            ok, status in
            XCTAssertFalse(ok)
            XCTAssertEqual(status, 0)
            exp.fulfill()
        }

        // invalid app ID
        platform.serverURL = correctURL
        platform.appID = "abc"
        let exp2 = expectationWithDescription("returns false due to invalid app ID")

        platform.sendToServerAsync(jsonStr) {
            ok, status in
            XCTAssertFalse(ok)
            XCTAssertEqual(status, 401)
            exp2.fulfill()
        }

        // invalid secret
        platform.appID = Secrets.Platform.appID
        platform.appSecret += "invalid"
        let exp3 = expectationWithDescription("returns false due to invalid secret")

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
        waitForExpectationsWithTimeout(5, handler: nil)
    }

    func testIntegration() {
        let log = SwiftyBeaver.self
        let formatter = NSDateFormatter()

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

        log.addDestination(platform)
        //XCTAssertEqual(log.countDestinations(), 2)

        // send logs in chunks, use high threshold value to test performance
        platform.sendingPoints.Threshold = 20
        for index in 1...platform.sendingPoints.Threshold + 3 {
            // simulate work by doing a computing
            var x = 1.0
            for index2 in 1...50000 {
                x = sqrt(Double(index2))
                XCTAssertEqual(x, sqrt(Double(index2)))
            }

            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            let dateStr = formatter.stringFromDate(NSDate())
            log.debug("msg \(index) - \(dateStr)")
        }
        log.flush(3)
        // do some further waiting for sending to complete
        for _ in 1...platform.sendingPoints.Threshold + 3 {
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
        XCTAssertEqual(device["hostName"], NSProcessInfo.processInfo().hostName)
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
    func deleteFile(url: NSURL) -> Bool {
        do {
            try NSFileManager.defaultManager().removeItemAtURL(url)
            return true
        } catch let error {
            NSLog("Unit test: could not delete file \(url). \(error)")
        }
        return false
    }
}
