//
//  BaseDestinationTests.swift
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger on 05.12.15.
//  Copyright © 2015 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import XCTest
@testable import SwiftyBeaver

class BaseDestinationTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInit() {
        let obj = BaseDestination()
        XCTAssertNotNil(obj.queue)
    }

    func testFormattedDate() {
        // empty format
        var str = BaseDestination().formattedDate("")
        XCTAssertEqual(str, "")
        // no time format
        str = BaseDestination().formattedDate("--")
        XCTAssertGreaterThanOrEqual(str, "--")
        // HH:mm:ss
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let dateStr = formatter.string(from: NSDate() as Date)
        str = BaseDestination().formattedDate(formatter.dateFormat)
        XCTAssertEqual(str, dateStr)
    }

    func testFormattedLevel() {
        let obj = BaseDestination()
        var str = ""

        str = obj.formattedLevel(SwiftyBeaver.Level.Verbose)
        XCTAssertNotNil(str, "VERBOSE")
        str = obj.formattedLevel(SwiftyBeaver.Level.Debug)
        XCTAssertNotNil(str, "DEBUG")
        str = obj.formattedLevel(SwiftyBeaver.Level.Info)
        XCTAssertNotNil(str, "INFO")
        str = obj.formattedLevel(SwiftyBeaver.Level.Warning)
        XCTAssertNotNil(str, "WARNING")
        str = obj.formattedLevel(SwiftyBeaver.Level.Error)
        XCTAssertNotNil(str, "ERROR")

        // custom level strings
        obj.levelString.Verbose = "Who cares"
        obj.levelString.Debug = "Look"
        obj.levelString.Info = "Interesting"
        obj.levelString.Warning = "Oh oh"
        obj.levelString.Error = "OMG!!!"

        str = obj.formattedLevel(SwiftyBeaver.Level.Verbose)
        XCTAssertNotNil(str, "Who cares")
        str = obj.formattedLevel(SwiftyBeaver.Level.Debug)
        XCTAssertNotNil(str, "Look")
        str = obj.formattedLevel(SwiftyBeaver.Level.Info)
        XCTAssertNotNil(str, "Interesting")
        str = obj.formattedLevel(SwiftyBeaver.Level.Warning)
        XCTAssertNotNil(str, "Oh oh")
        str = obj.formattedLevel(SwiftyBeaver.Level.Error)
        XCTAssertNotNil(str, "OMG!!!")
    }

    func testFormattedMessage() {
        let obj = BaseDestination()
        var str = ""
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"

        let dateStr = formatter.string(from: NSDate() as Date)

        // logging to main thread does not output thread name
        str = obj.formattedMessage(dateStr, levelString: "DEBUG", msg: "Hello", thread: "main",
            path: "/path/to/ViewController.swift", function: "testFunction()", line: 50, detailOutput: false)
        XCTAssertNotNil(str.range(of: "[\(dateStr)] DEBUG: Hello"))
        XCTAssertNil(str.range(of: "main"))
        XCTAssertNil(str.range(of: "|"))

        str = obj.formattedMessage(dateStr, levelString: "DEBUG", msg: "Hello", thread: "myThread",
            path: "/path/to/ViewController.swift", function: "testFunction()", line: 50, detailOutput: true)
        XCTAssertNotNil(str.range(of: "[\(dateStr)] |myThread| ViewController.testFunction():50 DEBUG: Hello"))

        str = obj.formattedMessage(dateStr, levelString: "DEBUG", msg: "Hello", thread: "",
            path: "/path/to/ViewController.swift", function: "testFunction()", line: 50, detailOutput: true)
        XCTAssertNotNil(str.range(of: "[\(dateStr)] ViewController.testFunction():50 DEBUG: Hello"))
        XCTAssertNil(str.range(of: "|"))
    }

    func testFormattedMessageEmptyDate() {
        let obj = BaseDestination()
        var str = ""
        let dateStr = obj.formattedDate("")
        XCTAssertEqual(dateStr, "")

        str = obj.formattedMessage(dateStr, levelString: "DEBUG", msg: "Hello", thread: "main",
            path: "/path/to/ViewController.swift", function: "testFunction()", line: 50, detailOutput: false)
        XCTAssertEqual(str, "DEBUG: Hello")
    }

    func testShouldLevelBeLogged() {
        let obj = BaseDestination()
        obj.minLevel = SwiftyBeaver.Level.Info

        // filters to set minLevel to Verbose for certain files / folders
        obj.addMinLevelFilter(minLevel: .Verbose, path: "foo.swift")
        obj.addMinLevelFilter(minLevel: .Verbose, path: "/bar/")
        obj.addMinLevelFilter(minLevel: .Verbose, path: "/app")
        obj.addMinLevelFilter(minLevel: .Verbose, path: "/world/beaver.swift", function: "AppDelegate")
        obj.addMinLevelFilter(minLevel: .Verbose, path: "", function: "MyFunction")

        // check instance minLevel property
        XCTAssertFalse(obj.shouldLevelBeLogged(level: SwiftyBeaver.Level.Verbose, path: "", function: ""))
        XCTAssertFalse(obj.shouldLevelBeLogged(level: SwiftyBeaver.Level.Debug, path: "", function: ""))
        XCTAssertTrue(obj.shouldLevelBeLogged(level: SwiftyBeaver.Level.Info, path: "", function: ""))
        XCTAssertTrue(obj.shouldLevelBeLogged(level: SwiftyBeaver.Level.Warning, path: "", function: ""))
        XCTAssertTrue(obj.shouldLevelBeLogged(level: SwiftyBeaver.Level.Error, path: "", function: ""))
        // check if filters overrule instance property
        XCTAssertFalse(obj.shouldLevelBeLogged(level: SwiftyBeaver.Level.Verbose, path: "foo2.swift", function: ""))
        XCTAssertFalse(obj.shouldLevelBeLogged(level: SwiftyBeaver.Level.Verbose, path: "Foo.swift", function: ""))
        XCTAssertTrue(obj.shouldLevelBeLogged(level: SwiftyBeaver.Level.Verbose, path: "foo.swift", function: ""))
        XCTAssertTrue(obj.shouldLevelBeLogged(level: SwiftyBeaver.Level.Verbose, path: "/hello/foo.swift", function: ""))
        // check filter 2
        XCTAssertFalse(obj.shouldLevelBeLogged(level: SwiftyBeaver.Level.Verbose, path: "bar", function: ""))
        XCTAssertFalse(obj.shouldLevelBeLogged(level: SwiftyBeaver.Level.Verbose, path: "/Bar/", function: ""))
        XCTAssertTrue(obj.shouldLevelBeLogged(level: SwiftyBeaver.Level.Verbose, path: "/bar/", function: ""))
        XCTAssertTrue(obj.shouldLevelBeLogged(level: SwiftyBeaver.Level.Verbose,
                                              path: "/hello/bar/beaver", function: ""))
        // check filter 3
        XCTAssertFalse(obj.shouldLevelBeLogged(level: SwiftyBeaver.Level.Verbose, path: "/lol/App2/", function: ""))
        XCTAssertTrue(obj.shouldLevelBeLogged(level: SwiftyBeaver.Level.Verbose, path: "/lol/app2/", function: ""))
        XCTAssertTrue(obj.shouldLevelBeLogged(level: SwiftyBeaver.Level.Verbose, path: "/lol/app", function: ""))
        // check filter 4 (file & function)
        XCTAssertFalse(obj.shouldLevelBeLogged(level: SwiftyBeaver.Level.Verbose, path: "/world/beaver/", function: ""))
        XCTAssertFalse(obj.shouldLevelBeLogged(level: SwiftyBeaver.Level.Verbose,
                                               path: "world/beaver.swift", function: ""))
        XCTAssertFalse(obj.shouldLevelBeLogged(
            level: SwiftyBeaver.Level.Verbose, path: "/world/beaver.swift", function: "appDelegate"))
        XCTAssertTrue(obj.shouldLevelBeLogged(
            level: SwiftyBeaver.Level.Verbose, path: "/world/beaver.swift", function: "AppDelegate"))
        // check filter 5 (function)
        XCTAssertTrue(obj.shouldLevelBeLogged(level: SwiftyBeaver.Level.Verbose, path: "", function: "MyFunction"))
    }

    func test_init_noMinLevelExplicitelySet_createsOneMatchingLevelFilter() {
        let destination = BaseDestination()
        XCTAssertEqual(destination.filters.count, 1)
    }

    func test_init_newMinLevelExplicitelySet_createsOneMatchingLevelFilter() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        XCTAssertEqual(destination.filters.count, 1)
    }

    func test_init_newMinLevelExplicitelySetAndPasses_True() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        XCTAssertTrue(destination.shouldLevelBeLogged(level: SwiftyBeaver.Level.Info, path: "", function: ""))
    }

    func test_init_newMinLevelExplicitelySetAndDoesNotPass_False() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        XCTAssertFalse(destination.shouldLevelBeLogged(level: SwiftyBeaver.Level.Verbose, path: "", function: ""))
    }

    func test_shouldLevelBeLogged_hasLevelFilterAndOneEqualsPathFilterAndPasses_True() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(filter: Filters.Path.equals(strings: "/world/beaver.swift",
                                                          caseSensitive: true, required: true))
        XCTAssertTrue(destination.shouldLevelBeLogged(level: SwiftyBeaver.Level.Warning,
                                                      path: "/world/beaver.swift", function: "initialize"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterAndOneEqualsPathFilterAndDoesNotPass_False() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(filter: Filters.Path.equals(strings: "/world/beaver.swift",
                                                          caseSensitive: true, required: true))
        XCTAssertFalse(destination.shouldLevelBeLogged(level: SwiftyBeaver.Level.Warning,
                                                       path: "/hello/foo.swift", function: "initialize"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterAndTwoRequiredPathFiltersAndPasses_True() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(filter: Filters.Path.startsWith(prefixes: "/world",
                                                              caseSensitive: true, required: true))
        destination.addFilter(filter: Filters.Path.endsWith(suffixes: "beaver.swift",
                                                            caseSensitive: true, required: true))
        XCTAssertTrue(destination.shouldLevelBeLogged(level: SwiftyBeaver.Level.Warning,
                                                      path: "/world/beaver.swift", function: "initialize"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterAndTwoRequiredPathFiltersAndDoesNotPass_False() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(filter: Filters.Path.startsWith(prefixes: "/world", caseSensitive: true, required: true))
        destination.addFilter(filter: Filters.Path.endsWith(suffixes: "foo.swift", caseSensitive: true, required: true))
        XCTAssertFalse(destination.shouldLevelBeLogged(level: SwiftyBeaver.Level.Warning,
                                                       path: "/hello/foo.swift", function: "initialize"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterARequiredPathFilterAndTwoRequiredMessageFiltersAndPasses_True() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(filter: Filters.Path.startsWith(prefixes: "/world", caseSensitive: true, required: true))
        destination.addFilter(filter: Filters.Message.startsWith(prefixes: "SQL:", caseSensitive: true, required: true))
        destination.addFilter(filter: Filters.Message.contains(strings: "insert", caseSensitive: false, required: true))
        XCTAssertTrue(destination.shouldLevelBeLogged(level: SwiftyBeaver.Level.Warning,
                                                      path: "/world/beaver.swift", function: "executeSQLStatement",
                                                      message: "SQL: INSERT INTO table (c1, c2) VALUES (1, 2)"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterARequiredPathFilterAnd2RequiredMessageFiltersAndDoesNotPass_False() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(filter: Filters.Path.startsWith(prefixes: "/world", caseSensitive: true, required: true))
        destination.addFilter(filter: Filters.Message.startsWith(prefixes: "SQL:", caseSensitive: true, required: true))
        destination.addFilter(filter: Filters.Message.contains(strings: "insert", caseSensitive: false, required: true))
        XCTAssertFalse(destination.shouldLevelBeLogged(level: SwiftyBeaver.Level.Warning,
                                                       path: "/world/beaver.swift", function: "executeSQLStatement",
                                                       message: "SQL: DELETE FROM table WHERE c1 = 1"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterCombinationOfAllOtherFiltersAndPasses_True() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(filter: Filters.Path.startsWith(prefixes: "/world", caseSensitive: true, required: true))
        destination.addFilter(filter: Filters.Path.endsWith(suffixes: "/beaver.swift",
                                                            caseSensitive: true, required: true))
        destination.addFilter(filter: Filters.Function.equals(strings: "executeSQLStatement", required: true))
        destination.addFilter(filter: Filters.Message.startsWith(prefixes: "SQL:", caseSensitive: true, required: true))
        destination.addFilter(filter: Filters.Message.contains(strings: "insert", "update", "delete", required: true))
        XCTAssertTrue(destination.shouldLevelBeLogged(level: SwiftyBeaver.Level.Warning,
                                                      path: "/world/beaver.swift", function: "executeSQLStatement",
                                                      message: "SQL: INSERT INTO table (c1, c2) VALUES (1, 2)"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterCombinationOfAllOtherFiltersAndDoesNotPass_False() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(filter: Filters.Path.startsWith(prefixes: "/world", caseSensitive: true, required: true))
        destination.addFilter(filter: Filters.Path.endsWith(suffixes: "/beaver.swift",
                                                            caseSensitive: true, required: true))
        destination.addFilter(filter: Filters.Function.equals(strings: "executeSQLStatement", required: true))
        destination.addFilter(filter: Filters.Message.startsWith(prefixes: "SQL:", caseSensitive: true, required: true))
        destination.addFilter(filter: Filters.Message.contains(strings: "insert", "update", "delete", required: true))
        XCTAssertFalse(destination.shouldLevelBeLogged(level: SwiftyBeaver.Level.Warning,
                                                       path: "/world/beaver.swift", function: "executeSQLStatement",
                                                       message: "SQL: CREATE TABLE sample (c1 INTEGER, c2 VARCHAR)"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterCombinationOfOtherFiltersIncludingNonRequiredAndPasses_True() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(filter: Filters.Path.startsWith(prefixes: "/world", caseSensitive: true, required: true))
        destination.addFilter(filter: Filters.Path.endsWith(suffixes: "/beaver.swift",
                                                            caseSensitive: true, required: true))
        destination.addFilter(filter: Filters.Function.equals(strings: "executeSQLStatement", required: true))
        destination.addFilter(filter: Filters.Message.startsWith(prefixes: "SQL:", caseSensitive: true, required: true))
        destination.addFilter(filter: Filters.Message.contains(strings: "insert"))
        destination.addFilter(filter: Filters.Message.contains(strings: "update"))
        destination.addFilter(filter: Filters.Message.contains(strings: "delete"))
        XCTAssertTrue(destination.shouldLevelBeLogged(level: SwiftyBeaver.Level.Warning,
                                                      path: "/world/beaver.swift", function: "executeSQLStatement",
                                                      message: "SQL: INSERT INTO table (c1, c2) VALUES (1, 2)"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterCombinationOfOtherFiltersIncludingNonRequiredAndDoesNotPass_False() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(filter: Filters.Path.startsWith(prefixes: "/world", caseSensitive: true, required: true))
        destination.addFilter(filter: Filters.Path.endsWith(suffixes: "/beaver.swift",
                                                            caseSensitive: true, required: true))
        destination.addFilter(filter: Filters.Function.equals(strings: "executeSQLStatement", required: true))
        destination.addFilter(filter: Filters.Message.startsWith(prefixes: "SQL:", caseSensitive: true, required: true))
        destination.addFilter(filter: Filters.Message.contains(strings: "insert", caseSensitive: true))
        destination.addFilter(filter: Filters.Message.contains(strings: "update"))
        destination.addFilter(filter: Filters.Message.contains(strings: "delete"))
        XCTAssertFalse(destination.shouldLevelBeLogged(level: SwiftyBeaver.Level.Warning,
                                                       path: "/world/beaver.swift", function: "executeSQLStatement",
                                                       message: "SQL: INSERT INTO table (c1, c2) VALUES (1, 2)"))
    }

}
