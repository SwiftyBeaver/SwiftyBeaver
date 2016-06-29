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
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let dateStr = formatter.stringFromDate(NSDate())
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
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let dateStr = formatter.stringFromDate(NSDate())

        // logging to main thread does not output thread name
        str = obj.formattedMessage(dateStr, levelString: "DEBUG", msg: "Hello", thread: "main",
            path: "/path/to/ViewController.swift", function: "testFunction()", line: 50, detailOutput: false)
        XCTAssertNotNil(str.rangeOfString("[\(dateStr)] DEBUG: Hello"))
        XCTAssertNil(str.rangeOfString("main"))
        XCTAssertNil(str.rangeOfString("|"))

        str = obj.formattedMessage(dateStr, levelString: "DEBUG", msg: "Hello", thread: "myThread",
            path: "/path/to/ViewController.swift", function: "testFunction()", line: 50, detailOutput: true)
        XCTAssertNotNil(str.rangeOfString("[\(dateStr)] |myThread| ViewController.testFunction():50 DEBUG: Hello"))

        str = obj.formattedMessage(dateStr, levelString: "DEBUG", msg: "Hello", thread: "",
            path: "/path/to/ViewController.swift", function: "testFunction()", line: 50, detailOutput: true)
        XCTAssertNotNil(str.rangeOfString("[\(dateStr)] ViewController.testFunction():50 DEBUG: Hello"))
        XCTAssertNil(str.rangeOfString("|"))
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

    func test_init_noMinLevelSet() {
        let destination = BaseDestination()
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.Verbose, path: "", function: ""))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.Debug, path: "", function: ""))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.Info, path: "", function: ""))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.Warning, path: "", function: ""))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.Error, path: "", function: ""))
    }

    func test_init_minLevelSet() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        XCTAssertFalse(destination.shouldLevelBeLogged(SwiftyBeaver.Level.Verbose, path: "", function: ""))
        XCTAssertFalse(destination.shouldLevelBeLogged(SwiftyBeaver.Level.Debug, path: "", function: ""))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.Info, path: "", function: ""))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.Warning, path: "", function: ""))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.Error, path: "", function: ""))
    }


    func test_shouldLevelBeLogged_hasMinLevel_True() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Verbose
        destination.addFilter(Filters.Path.equals("/world/beaver.swift", caseSensitive: true, required: true))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.Warning,
            path: "/world/beaver.swift", function: "initialize"))
    }

    func test_shouldLevelBeLogged_hasMinLevel_False() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(Filters.Path.equals("/world/beaver.swift", caseSensitive: true, required: true))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.Warning,
            path: "/world/beaver.swift", function: "initialize"))
    }

    func test_shouldLevelBeLogged_hasMinLevelAndMatchingLevelAndEqualPath_True() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        let filter = Filters.Path.equals("/world/beaver.swift", caseSensitive: true, required: true, minLevel: .Debug)
        destination.addFilter(filter)
        XCTAssertTrue(destination.shouldLevelBeLogged(.Debug,
            path: "/world/beaver.swift", function: "initialize"))
    }

    func test_shouldLevelBeLogged_hasMinLevelAndNoMatchingLevelButEqualPath_False() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        let filter = Filters.Path.equals("/world/beaver.swift", caseSensitive: true, required: true, minLevel: .Debug)
        destination.addFilter(filter)
        XCTAssertFalse(destination.shouldLevelBeLogged(.Verbose,
            path: "/world/beaver.swift", function: "initialize"))
    }

    func test_shouldLevelBeLogged_hasMinLevelAndOneEqualsPathFilterAndDoesNotPass_False() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(Filters.Path.equals("/world/beaver.swift", caseSensitive: true, required: true))
        XCTAssertFalse(destination.shouldLevelBeLogged(.Debug,
            path: "/hello/foo.swift", function: "initialize"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterAndTwoRequiredPathFiltersAndPasses_True() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(Filters.Path.startsWith("/world", caseSensitive: true, required: true))
        destination.addFilter(Filters.Path.endsWith("beaver.swift", caseSensitive: true, required: true))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.Warning,
            path: "/world/beaver.swift", function: "initialize"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterAndTwoRequiredPathFiltersAndDoesNotPass_False() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(Filters.Path.startsWith("/world", caseSensitive: true, required: true))
        destination.addFilter(Filters.Path.endsWith("foo.swift", caseSensitive: true, required: true))
        XCTAssertFalse(destination.shouldLevelBeLogged(.Debug,
            path: "/hello/foo.swift", function: "initialize"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterARequiredPathFilterAndTwoRequiredMessageFiltersAndPasses_True() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(Filters.Path.startsWith("/world", caseSensitive: true, required: true))
        destination.addFilter(Filters.Message.startsWith("SQL:", caseSensitive: true, required: true))
        destination.addFilter(Filters.Message.contains("insert", caseSensitive: false, required: true))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.Warning,
            path: "/world/beaver.swift", function: "executeSQLStatement",
            message: "SQL: INSERT INTO table (c1, c2) VALUES (1, 2)"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterARequiredPathFilterAndTwoRequiredMessageFiltersAndDoesNotPass_False() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(Filters.Path.startsWith("/world", caseSensitive: true, required: true))
        destination.addFilter(Filters.Message.startsWith("SQL:", caseSensitive: true, required: true))
        destination.addFilter(Filters.Message.contains("insert", caseSensitive: false, required: true))
        XCTAssertFalse(destination.shouldLevelBeLogged(.Debug,
            path: "/world/beaver.swift",
            function: "executeSQLStatement",
            message: "SQL: DELETE FROM table WHERE c1 = 1"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterCombinationOfAllOtherFiltersAndPasses_True() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(Filters.Path.startsWith("/world", caseSensitive: true, required: true))
        destination.addFilter(Filters.Path.endsWith("/beaver.swift", caseSensitive: true, required: true))
        destination.addFilter(Filters.Function.equals("executeSQLStatement", required: true))
        destination.addFilter(Filters.Message.startsWith("SQL:", caseSensitive: true, required: true))
        destination.addFilter(Filters.Message.contains("insert", "update", "delete", required: true))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.Warning,
            path: "/world/beaver.swift",
            function: "executeSQLStatement",
            message: "SQL: INSERT INTO table (c1, c2) VALUES (1, 2)"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterCombinationOfAllOtherFiltersAndDoesNotPass_False() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(Filters.Path.startsWith("/world", caseSensitive: true, required: true))
        destination.addFilter(Filters.Path.endsWith("/beaver.swift", caseSensitive: true, required: true))
        destination.addFilter(Filters.Function.equals("executeSQLStatement", required: true))
        destination.addFilter(Filters.Message.startsWith("SQL:", caseSensitive: true, required: true))
        destination.addFilter(Filters.Message.contains("insert", "update", "delete", required: true))
        XCTAssertFalse(destination.shouldLevelBeLogged(.Debug,
            path: "/world/beaver.swift",
            function: "executeSQLStatement",
            message: "SQL: CREATE TABLE sample (c1 INTEGER, c2 VARCHAR)"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterCombinationOfOtherFiltersIncludingNonRequiredAndPasses_True() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(Filters.Path.startsWith("/world", caseSensitive: true, required: true))
        destination.addFilter(Filters.Path.endsWith("/beaver.swift", caseSensitive: true, required: true))
        destination.addFilter(Filters.Function.equals("executeSQLStatement", required: true))
        destination.addFilter(Filters.Message.startsWith("SQL:", caseSensitive: true, required: true))
        destination.addFilter(Filters.Message.contains("insert"))
        destination.addFilter(Filters.Message.contains("update"))
        destination.addFilter(Filters.Message.contains("delete"))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.Warning,
            path: "/world/beaver.swift",
            function: "executeSQLStatement",
            message: "SQL: INSERT INTO table (c1, c2) VALUES (1, 2)"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterCombinationOfOtherFiltersIncludingNonRequired_True() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(Filters.Path.startsWith("/world", caseSensitive: true, required: true))
        destination.addFilter(Filters.Path.endsWith("/beaver.swift", caseSensitive: true, required: true))
        destination.addFilter(Filters.Function.equals("executeSQLStatement", required: true))
        destination.addFilter(Filters.Message.startsWith("SQL:", caseSensitive: true, required: true))
        destination.addFilter(Filters.Message.contains("insert", caseSensitive: true))
        destination.addFilter(Filters.Message.contains("update"))
        destination.addFilter(Filters.Message.contains("delete"))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.Warning,
            path: "/world/beaver.swift",
            function: "executeSQLStatement",
            message: "SQL: INSERT INTO table (c1, c2) VALUES (1, 2)"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterCombinationOfOtherFiltersIncludingNonRequired_False() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.Info
        destination.addFilter(Filters.Path.startsWith("/world", caseSensitive: true, required: true))
        destination.addFilter(Filters.Path.endsWith("/beaver.swift", caseSensitive: true, required: true))
        destination.addFilter(Filters.Function.equals("executeSQLStatement", required: true))
        destination.addFilter(Filters.Message.startsWith("SQL:", caseSensitive: true, required: true))
        destination.addFilter(Filters.Message.contains("rename", caseSensitive: true, required: true))
        destination.addFilter(Filters.Message.contains("update"))
        destination.addFilter(Filters.Message.contains("delete"))
        XCTAssertFalse(destination.shouldLevelBeLogged(.Debug,
            path: "/world/beaver.swift",
            function: "executeSQLStatement",
            message: "SQL: INSERT INTO table (c1, c2) VALUES (1, 2)"))
    }

    func test_shouldLevelBeLogged_hasMatchingNonRequiredFilter_True() {
        let destination = BaseDestination()
        destination.minLevel = .Info
        destination.addFilter(Filters.Path.contains("/ViewController"))
        XCTAssertTrue(destination.shouldLevelBeLogged(.Debug,
            path: "/world/ViewController.swift",
            function: "myFunc",
            message: "Hello World"))
    }

    func test_shouldLevelBeLogged_hasNoMatchingNonRequiredFilter_False() {
        let destination = BaseDestination()
        destination.minLevel = .Info
        destination.addFilter(Filters.Path.contains("/ViewController"))
        XCTAssertFalse(destination.shouldLevelBeLogged(.Debug,
            path: "/world/beaver.swift",
            function: "myFunc",
            message: "Hello World"))
    }

    func test_shouldLevelBeLogged_hasNoMatchingNonRequiredFilterAndMinLevel_False() {
        let destination = BaseDestination()
        destination.minLevel = .Info
        destination.addFilter(Filters.Path.contains("/ViewController", minLevel: .Debug))
        XCTAssertFalse(destination.shouldLevelBeLogged(.Verbose,
            path: "/world/ViewController.swift",
            function: "myFunc",
            message: "Hello World"))
    }

    func test_shouldLevelBeLogged_noFilters_True() {
        // everything is logged on default
        let destination = BaseDestination()
        XCTAssertTrue(destination.shouldLevelBeLogged(.Debug,
            path: "/world/ViewController.swift",
            function: "myFunc",
            message: "Hello World"))
    }

    func test_shouldLevelBeLogged_multipleNonRequiredFiltersAndGlobal_True() {
        // everything is logged on default
        let destination = BaseDestination()
        destination.minLevel = .Info

        destination.addFilter(Filters.Path.contains("/ViewController", minLevel: .Debug))
        destination.addFilter(Filters.Function.contains("Func", minLevel: .Debug))
        destination.addFilter(Filters.Message.contains("World", minLevel: .Debug))
        //destination.debugPrint = true

        // covered by filters
        XCTAssertTrue(destination.shouldLevelBeLogged(.Debug,
            path: "/world/ViewController.swift",
            function: "myFunc",
            message: "Hello World"))

        // not in filter but matching global minLevel
        XCTAssertTrue(destination.shouldLevelBeLogged(.Info,
            path: "hello.swift",
            function: "foo",
            message: "bar"))

        // not in filter and below global minLevel
        XCTAssertFalse(destination.shouldLevelBeLogged(.Debug,
            path: "hello.swift",
            function: "foo",
            message: "bar"))
    }

}
