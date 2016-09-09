//
//  SwiftyBeaverTests.swift
//  SwiftyBeaverTests
//
//  Created by Sebastian Kreutzberger (Twitter @skreutzb) on 28.11.15.
//  Copyright © 2015 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import XCTest
@testable import SwiftyBeaver

class SwiftyBeaverTests: XCTestCase {

    var instanceVar = "an instance variable"

    override func setUp() {
        super.setUp()
        SwiftyBeaver.removeAllDestinations()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testAddDestination() {
        let log = SwiftyBeaver.self

        // add invalid destination
        XCTAssertEqual(log.countDestinations(), 0)

        // add valid destinations
        let console = ConsoleDestination()
        let console2 = ConsoleDestination()
        let file = FileDestination()

        XCTAssertEqual(log.countDestinations(), 0)
        XCTAssertTrue(log.addDestination(console))
        XCTAssertEqual(log.countDestinations(), 1)
        XCTAssertFalse(log.addDestination(console))
        XCTAssertEqual(log.countDestinations(), 1)
        XCTAssertTrue(log.addDestination(console2))
        XCTAssertEqual(log.countDestinations(), 2)
        XCTAssertFalse(log.addDestination(console2))
        XCTAssertTrue(log.addDestination(file))
        XCTAssertEqual(log.countDestinations(), 3)
    }

    func testRemoveDestination() {
        let log = SwiftyBeaver.self

        // remove invalid destination
        XCTAssertEqual(log.countDestinations(), 0)

        // remove valid destinations
        let console = ConsoleDestination()
        let console2 = ConsoleDestination()
        let file = FileDestination()

        // add destinations
        log.addDestination(console)
        log.addDestination(console2)
        log.addDestination(file)
        XCTAssertEqual(log.countDestinations(), 3)
        // remove destinations
        XCTAssertTrue(log.removeDestination(console))
        XCTAssertEqual(log.countDestinations(), 2)
        XCTAssertFalse(log.removeDestination(console))
        XCTAssertEqual(log.countDestinations(), 2)
        XCTAssertTrue(log.removeDestination(console2))
        XCTAssertFalse(log.removeDestination(console2))
        XCTAssertEqual(log.countDestinations(), 1)
        XCTAssertTrue(log.removeDestination(file))
        XCTAssertEqual(log.countDestinations(), 0)
    }

    func testLoggingWithoutDestination() {
        let log = SwiftyBeaver.self
        // no destination was set, yet
        log.verbose("Where do I log to?")
    }

    func testDestinationIntegration() {
        let log = SwiftyBeaver.self
        log.verbose("that should lead to nowhere")

        // add console
        let console = ConsoleDestination()
        log.addDestination(console)
        log.verbose("the default console destination")
        // add another console and set it to be less chatty
        let console2 = ConsoleDestination()
        log.addDestination(console2)
        XCTAssertEqual(log.countDestinations(), 2)
        console2.format = "$L: $M"
        console2.minLevel = SwiftyBeaver.Level.Debug
        log.verbose("a verbose hello from hopefully just 1 console!")
        log.debug("a debug hello from 2 different consoles!")

        // add file
        let file = FileDestination()
        file.logFileURL = NSURL(string: "file:///tmp/testSwiftyBeaver.log")!
        log.addDestination(file)
        XCTAssertEqual(log.countDestinations(), 3)
        log.verbose("default file msg 1")
        log.verbose("default file msg 2")
        log.verbose("default file msg 3")

        // log to another file
        let file2 = FileDestination()
        file2.logFileURL = NSURL(string: "file:///tmp/testSwiftyBeaver2.log")!
        file2.format = "$L: $M"
        file2.minLevel = SwiftyBeaver.Level.Debug
        log.addDestination(file2)
        XCTAssertEqual(log.countDestinations(), 4)
        log.verbose("this should be in file 1")
        log.debug("this should be in both files, msg 1")
        log.info("this should be in both files, msg 2")

        // log to default file location
        let file3 = FileDestination()
        file3.format = "$L: $M"
        log.addDestination(file3)
        XCTAssertEqual(log.countDestinations(), 5)
        log.info("Logging to default log file \(file3.logFileURL)")
    }

    func testDifferentMessageTypes() {
        let log = SwiftyBeaver.self

        // add console
        let console = ConsoleDestination()
        console.format = "$L: $M"
        console.levelString.Info = "interesting number"
        log.addDestination(console)

        log.verbose("My name is üÄölèå")
        log.verbose(123)
        log.info(-123.45678)
        log.warning(NSDate())
        log.error(["I", "like", "logs!"])
        log.error(["beaver": "yeah", "age": 12])

        XCTAssertEqual(log.countDestinations(), 1)
    }

    func testAutoClosure() {
        let log = SwiftyBeaver.self
        // add console
        let console = ConsoleDestination()
        console.format = "$L: $M"
        log.addDestination(console)
        // should not create a compile error relating autoclosure
        log.info(instanceVar)
    }

    func testLongRunningTaskIsNotExecutedWhenLoggingUnderMinLevel() {

        let log = SwiftyBeaver.self

        // add console
        let console = ConsoleDestination()
        console.format = "$L: $M"
        // set info level on default
        console.minLevel = .Info

        log.addDestination(console)

        func longRunningTask() -> String {
            XCTAssert(false, "A block passed should not be executed if the log should not be logged.")
            return "This should NOT BE VISIBLE!"
        }

        log.verbose(longRunningTask())
    }

    func testVersionAndBuild() {
        XCTAssertGreaterThan(SwiftyBeaver.version.characters.count, 4)
        XCTAssertGreaterThan(SwiftyBeaver.build, 500)
    }

    func testStripParams() {
        var f = "singleParam"
        XCTAssertEqual(SwiftyBeaver.stripParams(f), "singleParam()")
        f = "logWithParamFunc(_:foo:hello:)"
        XCTAssertEqual(SwiftyBeaver.stripParams(f), "logWithParamFunc()")
        f = "aFunc()"
        XCTAssertEqual(SwiftyBeaver.stripParams(f), "aFunc()")
    }
}
