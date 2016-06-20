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
        console2.detailOutput = false
        console2.dateFormat = "HH:mm:ss.SSS"
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
        file2.detailOutput = false
        file2.dateFormat = "HH:mm:ss.SSS"
        file2.minLevel = SwiftyBeaver.Level.Debug
        log.addDestination(file2)
        XCTAssertEqual(log.countDestinations(), 4)
        log.verbose("this should be in file 1")
        log.debug("this should be in both files, msg 1")
        log.info("this should be in both files, msg 2")

        // log to default file location
        let file3 = FileDestination()
        file3.detailOutput = false
        file3.dateFormat = "HH:mm:ss.SSS"
        log.addDestination(file3)
        XCTAssertEqual(log.countDestinations(), 5)
        log.info("Logging to default log file \(file3.logFileURL)")
    }

    func testColors() {
        let log = SwiftyBeaver.self
        log.verbose("that should lead to nowhere")

        // add console
        let console = ConsoleDestination()
        log.addDestination(console)

        // add file
        let file = FileDestination()
        file.logFileURL = NSURL(string: "file:///tmp/testSwiftyBeaver.log")!
        file.detailOutput = false
        file.dateFormat = "HH:mm:ss.SSS"
        log.addDestination(file)

        XCTAssertTrue(console.colored)
        XCTAssertTrue(file.colored)

        log.verbose("not so important")
        log.debug("something to debug")
        log.info("a nice information")
        log.warning("oh no, that won’t be good")
        log.error("ouch, an error did occur!")

        XCTAssertEqual(log.countDestinations(), 2)
    }

    func testModifiedColors() {
        let log = SwiftyBeaver.self

        // add console
        let console = ConsoleDestination()
        log.addDestination(console)

        XCTAssertTrue(console.colored)

        // change default color
        console.levelColor.Verbose = "fg255,0,255;"
        console.levelColor.Debug = "fg255,100,0;"
        console.levelColor.Info = ""
        console.levelColor.Warning = "fg255,255,255;"
        console.levelColor.Error = "fg100,0,200;"

        log.verbose("not so important, level in magenta")
        log.debug("something to debug, level in orange")
        log.info("a nice information, level in black")
        log.warning("oh no, that won’t be good, level in white")
        log.error("ouch, an error did occur!, level in purple")
    }

    func testColoredMessage() {
        let log = SwiftyBeaver.self

        // add console
        let console = ConsoleDestination()
        log.addDestination(console)

        // add file
        let file = FileDestination()
        file.logFileURL = NSURL(string: "file:///tmp/testSwiftyBeaver.log")!
        file.detailOutput = false
        file.dateFormat = "HH:mm:ss.SSS"
        log.addDestination(file)

        console.coloredLines = true
        XCTAssertTrue(console.colored)
        XCTAssertTrue(console.coloredLines)
        file.coloredLines = true
        XCTAssertTrue(file.colored)
        XCTAssertTrue(file.coloredLines)

        log.verbose("not so important")
        log.debug("something to debug")
        log.info("a nice information")
        log.warning("oh no, that won’t be good")
        log.error("ouch, an error did occur!")
    }

    func testDifferentMessageTypes() {
        let log = SwiftyBeaver.self

        // add console
        let console = ConsoleDestination()
        console.detailOutput = false
        console.dateFormat = "HH:mm:ss.SSS"
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
        console.dateFormat = "HH:mm:ss.SSS"
        log.addDestination(console)
        // should not create a compile error relating autoclosure
        log.info(instanceVar)
    }

    func testLongRunningTaskIsNotExecutedWhenLoggingUnderMinLevel() {

        let log = SwiftyBeaver.self

        // add console
        let console = ConsoleDestination()
        console.dateFormat = "HH:mm:ss.SSS"
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
