//
//  SwiftyBeaverTests.swift
//  SwiftyBeaverTests
//
//  Created by Sebastian Kreutzberger (Twitter @skreutzb) on 28.11.15.
//  Copyright © 2015 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation
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
        XCTAssertTrue(log.addDestination(console))
        XCTAssertTrue(log.addDestination(console2))
        XCTAssertTrue(log.addDestination(file))
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

    func testLogVerifiesIfShouldLogOnAllDestinations() {
        let log = SwiftyBeaver.self

        let dest1 = MockDestination()
        dest1.asynchronously = false
        let dest2 = MockDestination()
        dest2.asynchronously = false

        log.addDestination(dest1)
        log.addDestination(dest2)

        log.dispatch_send(level: .warning, message: "Message", thread: "Thread", file: "File", function: "Function()", line: 123, context: "Context")

        XCTAssertEqual(dest1.shouldLogToLevel, SwiftyBeaver.Level.warning)
        XCTAssertEqual(dest2.shouldLogToLevel, SwiftyBeaver.Level.warning)

        XCTAssertEqual(dest1.shouldLogPath, "File")
        XCTAssertEqual(dest2.shouldLogPath, "File")

        XCTAssertEqual(dest1.shouldLogFunction, "Function()")
        XCTAssertEqual(dest2.shouldLogFunction, "Function()")

        XCTAssertEqual(dest1.shouldLogMessage, "Message")
        XCTAssertEqual(dest2.shouldLogMessage, "Message")
    }

    func testLogCallsAllDestinations() {
        let log = SwiftyBeaver.self

        let dest1 = MockDestination()
        dest1.asynchronously = false
        let dest2 = MockDestination()
        dest2.asynchronously = false

        log.addDestination(dest1)
        log.addDestination(dest2)

        log.dispatch_send(level: .warning, message: "Message", thread: "Thread", file: "File", function: "Function()", line: 123, context: "Context")

        XCTAssertEqual(dest1.didSendToLevel, SwiftyBeaver.Level.warning)
        XCTAssertEqual(dest2.didSendToLevel, SwiftyBeaver.Level.warning)

        XCTAssertEqual(dest1.didSendMessage, "Message")
        XCTAssertEqual(dest2.didSendMessage, "Message")

        XCTAssertEqual(dest1.didSendToThread, "Thread")
        XCTAssertEqual(dest2.didSendToThread, "Thread")

        XCTAssertEqual(dest1.didSendFile, "File")
        XCTAssertEqual(dest2.didSendFile, "File")

        XCTAssertEqual(dest1.didSendFunction, "Function()")
        XCTAssertEqual(dest2.didSendFunction, "Function()")

        XCTAssertEqual(dest1.didSendLine, 123)
        XCTAssertEqual(dest2.didSendLine, 123)

        XCTAssertEqual(dest1.didSendContext as? String, "Context")
        XCTAssertEqual(dest2.didSendContext as? String, "Context")
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
        XCTAssertTrue(log.addDestination(console))
        log.verbose("the default console destination")
        // add another console and set it to be less chatty
        let console2 = ConsoleDestination()
        XCTAssertTrue(log.addDestination(console2))
        XCTAssertEqual(log.countDestinations(), 2)
        console2.format = "$L: $M"
        console2.minLevel = SwiftyBeaver.Level.debug
        log.verbose("a verbose hello from hopefully just 1 console!")
        log.debug("a debug hello from 2 different consoles!")

        // add file
        let file = FileDestination()
        file.logFileURL = URL(string: "file:///tmp/testSwiftyBeaver.log")!
        XCTAssertTrue(log.addDestination(file))
        XCTAssertEqual(log.countDestinations(), 3)
        log.verbose("default file msg 1")
        log.verbose("default file msg 2")
        log.verbose("default file msg 3")

        // log to another file
        let file2 = FileDestination()
        file2.logFileURL = URL(string: "file:///tmp/testSwiftyBeaver2.log")!
        console2.format = "$L: $M"
        file2.minLevel = SwiftyBeaver.Level.debug
        XCTAssertTrue(log.addDestination(file2))
        XCTAssertEqual(log.countDestinations(), 4)
        log.verbose("this should be in file 1")
        log.debug("this should be in both files, msg 1")
        log.info("this should be in both files, msg 2")

        // log to default file location
        let file3 = FileDestination()
        console2.format = "$L: $M"
        XCTAssertTrue(log.addDestination(file3))
        XCTAssertEqual(log.countDestinations(), 5)
        guard let f3URL = file3.logFileURL else {
            return
        }
        log.info("Logging to default log file \(f3URL)")
    }

    func testColors() {
        let log = SwiftyBeaver.self
        log.verbose("that should lead to nowhere")

        // add console
        let console = ConsoleDestination()
        XCTAssertTrue(log.addDestination(console))

        // add file
        let file = FileDestination()
        file.logFileURL = URL(string: "file:///tmp/testSwiftyBeaver.log")!
        file.format = "$L: $M"
        XCTAssertTrue(log.addDestination(file))

        log.verbose("not so important")
        log.debug("something to debug")
        log.info("a nice information")
        log.warning("oh no, that won’t be good")
        log.error("ouch, an error did occur!")

        XCTAssertEqual(log.countDestinations(), 2)
    }
    
    func testUptime() {
        let log = SwiftyBeaver.self
        log.verbose("that should lead to nowhere")
        
        // add console
        let console = ConsoleDestination()
        console.format = "$U: $M"
        XCTAssertTrue(log.addDestination(console))
        
        // add file
        let file = FileDestination()
        file.logFileURL = URL(string: "file:///tmp/testSwiftyBeaver.log")!
        file.format = "$U: $M"
        XCTAssertTrue(log.addDestination(file))
        
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
        XCTAssertTrue(log.addDestination(console))

        // change default color
        console.levelColor.verbose = "fg255,0,255;"
        console.levelColor.debug = "fg255,100,0;"
        console.levelColor.info = ""
        console.levelColor.warning = "fg255,255,255;"
        console.levelColor.error = "fg100,0,200;"

        log.verbose("not so important, level in magenta")
        log.debug("something to debug, level in orange")
        log.info("a nice information, level in black")
        log.warning("oh no, that won’t be good, level in white")
        log.error("ouch, an error did occur!, level in purple")
    }

    func testDifferentMessageTypes() {
        let log = SwiftyBeaver.self

        // add console
        let console = ConsoleDestination()
        console.format = "$L: $M"
        console.levelString.info = "interesting number"
        XCTAssertTrue(log.addDestination(console))

        log.verbose("My name is üÄölèå")
        log.verbose(123)
        log.info(-123.45678)
        log.warning(NSDate())
        log.error(["I", "like", "logs!"])
        log.error(["beaver": "yeah", "age": 12])

        // JSON Logging
        let jsonConsole = ConsoleDestination()
        jsonConsole.format = "$J"
        XCTAssertTrue(log.addDestination(jsonConsole))

        log.verbose("My name is üÄölèå")
        log.verbose(123)
        log.info(-123.45678)
        log.warning(NSDate())
        log.error(["I", "like", "logs!"])
        log.error(["beaver": "yeah", "age": 12])

        XCTAssertEqual(log.countDestinations(), 2)
    }

    func testAutoClosure() {
        let log = SwiftyBeaver.self
        // add console
        let console = ConsoleDestination()
        XCTAssertTrue(log.addDestination(console))
        // should not create a compile error relating autoclosure
        log.info(instanceVar)
    }

    func testLongRunningTaskIsNotExecutedWhenLoggingUnderMinLevel() {

        let log = SwiftyBeaver.self

        // add console
        let console = ConsoleDestination()
        // set info level on default
        console.minLevel = .info

        XCTAssertTrue(log.addDestination(console))

        func longRunningTask() -> String {
            XCTAssert(false, "A block passed should not be executed if the log should not be logged.")
            return "This should NOT BE VISIBLE!"
        }

        log.verbose(longRunningTask())
    }

    func testVersionAndBuild() {
        XCTAssertGreaterThan(SwiftyBeaver.version.length, 4)
        XCTAssertGreaterThan(SwiftyBeaver.build, 500)
    }

    func testStripParams() {
        var f = "singleParam"
        XCTAssertEqual(SwiftyBeaver.stripParams(function: f), "singleParam()")
        f = "logWithParamFunc(_:foo:hello:)"
        XCTAssertEqual(SwiftyBeaver.stripParams(function: f), "logWithParamFunc()")
        f = "aFunc()"
        XCTAssertEqual(SwiftyBeaver.stripParams(function: f), "aFunc()")
    }

    static let allTests = [
        ("testAddDestination", testAddDestination),
        ("testRemoveDestination", testRemoveDestination),
        ("testLoggingWithoutDestination", testLoggingWithoutDestination),
        ("testDestinationIntegration", testDestinationIntegration),
        ("testColors", testColors),
        ("testModifiedColors", testModifiedColors),
        ("testDifferentMessageTypes", testDifferentMessageTypes),
        ("testAutoClosure", testAutoClosure),
        ("testLongRunningTaskIsNotExecutedWhenLoggingUnderMinLevel",
            testLongRunningTaskIsNotExecutedWhenLoggingUnderMinLevel),
        ("testVersionAndBuild", testVersionAndBuild),
        ("testStripParams", testStripParams)
    ]
}

private class MockDestination: BaseDestination {
    var didSendToLevel: SwiftyBeaver.Level?
    var didSendMessage: String?
    var didSendToThread: String?
    var didSendFile: String?
    var didSendFunction: String?
    var didSendLine: Int?
    var didSendContext: (Any?)?

    override func send(_ level: SwiftyBeaver.Level, msg: String, thread: String, file: String, function: String, line: Int, context: Any?) -> String? {
        didSendToLevel = level
        didSendMessage = msg
        didSendToThread = thread
        didSendFile = file
        didSendFunction = function
        didSendLine = line
        didSendContext = context

        return ""
    }

    var shouldLogToLevel: SwiftyBeaver.Level?
    var shouldLogPath: String?
    var shouldLogFunction: String?
    var shouldLogMessage: String?
    override func shouldLevelBeLogged(_ level: SwiftyBeaver.Level, path: String, function: String, message: String?) -> Bool {
        shouldLogToLevel = level
        shouldLogPath = path
        shouldLogFunction = function
        shouldLogMessage = message
        return true
    }

    override func hasMessageFilters() -> Bool {
        return true
    }
}
