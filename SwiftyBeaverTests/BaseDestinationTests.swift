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


    ////////////////////////////////
    // MARK: Format
    ////////////////////////////////

    func testFormatMessage() {
        let obj = BaseDestination()
        var str = ""
        var format = ""

        // empty format
        str = obj.formatMessage(format, level: .verbose, msg: "Hello", thread: "main",
            file: "/path/to/ViewController.swift", function: "testFunction()", line: 50)
        XCTAssertEqual(str, "")

        // format without variables
        format = "Hello"
        str = obj.formatMessage(format, level: .verbose, msg: "Hello", thread: "main",
                                file: "/path/to/ViewController.swift", function: "testFunction()", line: 50)
        XCTAssertEqual(str, "Hello")

        // weird format
        format = "$"
        str = obj.formatMessage(format, level: .verbose, msg: "Hello", thread: "main",
                                file: "/path/to/ViewController.swift", function: "testFunction()", line: 50)
        XCTAssertEqual(str, "")

        // basic format with ignored color and thread
        format = "|$T| $C$L$c: $M"
        str = obj.formatMessage(format, level: .verbose, msg: "Hello", thread: "main",
            file: "/path/to/ViewController.swift", function: "testFunction()", line: 50)
        XCTAssertEqual(str, "|main| VERBOSE: Hello")

        // format with date and color
        let obj2 = BaseDestination()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = formatter.string(from: NSDate() as Date)

        obj2.levelColor.verbose = "?"
        obj2.escape = ">"
        obj2.reset = "<"

        format = "[$Dyyyy-MM-dd HH:mm:ss$d] |$T| $N.$F:$l $C$L$c: $M"
        str = obj2.formatMessage(format, level: .verbose, msg: "Hello", thread: "main",
                                 file: "/path/to/ViewController.swift", function: "testFunction()", line: 50)
        XCTAssertEqual(str, "[\(dateStr)] |main| ViewController.testFunction():50 >?VERBOSE<: Hello")


        //  UTC datetime
        let obj3 = BaseDestination()
        let utcFormatter = DateFormatter()
        utcFormatter.timeZone = TimeZone(abbreviation: "UTC")
        utcFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let utcDateStr = utcFormatter.string(from: NSDate() as Date)
        str = BaseDestination().formatDate(utcFormatter.dateFormat, timeZone: "UTC")

        format = "$Zyyyy-MM-dd HH:mm:ss$z"
        str = obj3.formatMessage(format, level: .verbose, msg: "Hello", thread: "main",
                                 file: "/path/to/ViewController.swift", function: "testFunction()", line: 50)
        XCTAssertEqual(str, "\(utcDateStr)")

        /*
         WORKING !!!

        // format with JSON message
        // test was deactivated because it seems impossible to test for \\" in Swift 3?!
        format = "$L: $m"
        str = obj.formatMessage(format, level: .verbose, msg: "Hello \"world\" yeah", thread: "main",
                                file: "/path/to/ViewController.swift", function: "testFunction()", line: 50)
        print(str)

        // JSON format, just message needs to be encoded -> IS WORKING!
        format = "{\"level\": \"$L\", \"message\": \"$m\", \"line\":$l}"
        str = obj.formatMessage(format, level: .verbose, msg: "Hello \"world\" yeah", thread: "main",
                                file: "/path/to/ViewController.swift", function: "testFunction()", line: 50)
        print(str)
        */
    }

    func testLevelWord() {
        let obj = BaseDestination()
        var str = ""

        str = obj.levelWord(SwiftyBeaver.Level.verbose)
        XCTAssertNotNil(str, "VERBOSE")
        str = obj.levelWord(SwiftyBeaver.Level.debug)
        XCTAssertNotNil(str, "DEBUG")
        str = obj.levelWord(SwiftyBeaver.Level.info)
        XCTAssertNotNil(str, "INFO")
        str = obj.levelWord(SwiftyBeaver.Level.warning)
        XCTAssertNotNil(str, "WARNING")
        str = obj.levelWord(SwiftyBeaver.Level.error)
        XCTAssertNotNil(str, "ERROR")

        // custom level strings
        obj.levelString.verbose = "Who cares"
        obj.levelString.debug = "Look"
        obj.levelString.info = "Interesting"
        obj.levelString.warning = "Oh oh"
        obj.levelString.error = "OMG!!!"

        str = obj.levelWord(SwiftyBeaver.Level.verbose)
        XCTAssertNotNil(str, "Who cares")
        str = obj.levelWord(SwiftyBeaver.Level.debug)
        XCTAssertNotNil(str, "Look")
        str = obj.levelWord(SwiftyBeaver.Level.info)
        XCTAssertNotNil(str, "Interesting")
        str = obj.levelWord(SwiftyBeaver.Level.warning)
        XCTAssertNotNil(str, "Oh oh")
        str = obj.levelWord(SwiftyBeaver.Level.error)
        XCTAssertNotNil(str, "OMG!!!")
    }

    func testColorForLevel() {
        let obj = BaseDestination()
        var str = ""

        // empty on default
        str = obj.colorForLevel(SwiftyBeaver.Level.verbose)
        XCTAssertNotNil(str, "")
        str = obj.colorForLevel(SwiftyBeaver.Level.debug)
        XCTAssertNotNil(str, "")
        str = obj.colorForLevel(SwiftyBeaver.Level.info)
        XCTAssertNotNil(str, "")
        str = obj.colorForLevel(SwiftyBeaver.Level.warning)
        XCTAssertNotNil(str, "")
        str = obj.colorForLevel(SwiftyBeaver.Level.error)
        XCTAssertNotNil(str, "")

        // custom level color strings
        obj.levelString.verbose = "silver"
        obj.levelString.debug = "green"
        obj.levelString.info = "blue"
        obj.levelString.warning = "yellow"
        obj.levelString.error = "red"

        str = obj.colorForLevel(SwiftyBeaver.Level.verbose)
        XCTAssertNotNil(str, "silver")
        str = obj.colorForLevel(SwiftyBeaver.Level.debug)
        XCTAssertNotNil(str, "green")
        str = obj.colorForLevel(SwiftyBeaver.Level.info)
        XCTAssertNotNil(str, "blue")
        str = obj.colorForLevel(SwiftyBeaver.Level.warning)
        XCTAssertNotNil(str, "yellow")
        str = obj.colorForLevel(SwiftyBeaver.Level.error)
        XCTAssertNotNil(str, "red")
    }

    func testFileNameOfFile() {
        let obj = BaseDestination()
        var str = ""

        str = obj.fileNameOfFile("")
        XCTAssertEqual(str, "")
        str = obj.fileNameOfFile("foo.bar")
        XCTAssertEqual(str, "foo.bar")
        str = obj.fileNameOfFile("path/to/ViewController.swift")
        XCTAssertEqual(str, "ViewController.swift")
    }

    func testFileNameOfFileWithoutSuffix() {
        let obj = BaseDestination()
        var str = ""

        str = obj.fileNameWithoutSuffix("")
        XCTAssertEqual(str, "")
        str = obj.fileNameWithoutSuffix("/")
        XCTAssertEqual(str, "")
        str = obj.fileNameWithoutSuffix("foo")
        XCTAssertEqual(str, "foo")
        str = obj.fileNameWithoutSuffix("foo.bar")
        XCTAssertEqual(str, "foo")
        str = obj.fileNameWithoutSuffix("path/to/ViewController.swift")
        XCTAssertEqual(str, "ViewController")
    }

    func testFormatDate() {
        // empty format
        var str = BaseDestination().formatDate("")
        XCTAssertEqual(str, "")
        // no time format
        str = BaseDestination().formatDate("--")
        XCTAssertGreaterThanOrEqual(str, "--")
        // HH:mm:ss
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let dateStr = formatter.string(from: NSDate() as Date)
        str = BaseDestination().formatDate(formatter.dateFormat)
        XCTAssertEqual(str, dateStr)
        // test UTC
        let utcFormatter = DateFormatter()
        utcFormatter.timeZone = TimeZone(abbreviation: "UTC")
        utcFormatter.dateFormat = "HH:mm:ss"
        let utcDateStr = utcFormatter.string(from: NSDate() as Date)
        str = BaseDestination().formatDate(utcFormatter.dateFormat, timeZone: "UTC")
        XCTAssertEqual(str, utcDateStr)
    }


    ////////////////////////////////
    // MARK: Filters
    ////////////////////////////////

    func test_init_noMinLevelSet() {
        let destination = BaseDestination()
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.verbose, path: "", function: ""))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.debug, path: "", function: ""))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.info, path: "", function: ""))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.warning, path: "", function: ""))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.error, path: "", function: ""))
    }

    func test_init_minLevelSet() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.info
        XCTAssertFalse(destination.shouldLevelBeLogged(SwiftyBeaver.Level.verbose, path: "", function: ""))
        XCTAssertFalse(destination.shouldLevelBeLogged(SwiftyBeaver.Level.debug, path: "", function: ""))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.info, path: "", function: ""))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.warning, path: "", function: ""))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.error, path: "", function: ""))
    }


    func test_shouldLevelBeLogged_hasMinLevel_True() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.verbose
        destination.addFilter(Filters.Path.equals("/world/beaver.swift", caseSensitive: true, required: true))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.warning,
                                                      path: "/world/beaver.swift", function: "initialize"))
    }

    func test_shouldLevelBeLogged_hasMinLevel_False() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.info
        destination.addFilter(Filters.Path.equals("/world/beaver.swift", caseSensitive: true, required: true))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.warning,
                                                      path: "/world/beaver.swift", function: "initialize"))
    }

    func test_shouldLevelBeLogged_hasMinLevelAndMatchingLevelAndEqualPath_True() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.info
        let filter = Filters.Path.equals("/world/beaver.swift", caseSensitive: true, required: true, minLevel: .debug)
        destination.addFilter(filter)
        XCTAssertTrue(destination.shouldLevelBeLogged(.debug,
                                                      path: "/world/beaver.swift", function: "initialize"))
    }

    func test_shouldLevelBeLogged_hasMinLevelAndNoMatchingLevelButEqualPath_False() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.info
        let filter = Filters.Path.equals("/world/beaver.swift", caseSensitive: true, required: true, minLevel: .debug)
        destination.addFilter(filter)
        XCTAssertFalse(destination.shouldLevelBeLogged(.verbose,
                                                       path: "/world/beaver.swift", function: "initialize"))
    }

    func test_shouldLevelBeLogged_hasMinLevelAndOneEqualsPathFilterAndDoesNotPass_False() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.info
        destination.addFilter(Filters.Path.equals("/world/beaver.swift", caseSensitive: true, required: true))
        XCTAssertFalse(destination.shouldLevelBeLogged(.debug,
                                                       path: "/hello/foo.swift", function: "initialize"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterAndTwoRequiredPathFiltersAndPasses_True() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.info
        destination.addFilter(Filters.Path.startsWith("/world", caseSensitive: true, required: true))
        destination.addFilter(Filters.Path.endsWith("beaver.swift", caseSensitive: true, required: true))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.warning,
                                                      path: "/world/beaver.swift", function: "initialize"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterAndTwoRequiredPathFiltersAndDoesNotPass_False() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.info
        destination.addFilter(Filters.Path.startsWith("/world", caseSensitive: true, required: true))
        destination.addFilter(Filters.Path.endsWith("foo.swift", caseSensitive: true, required: true))
        XCTAssertFalse(destination.shouldLevelBeLogged(.debug,
                                                       path: "/hello/foo.swift", function: "initialize"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterARequiredPathFilterAndTwoRequiredMessageFiltersAndPasses_True() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.info
        destination.addFilter(Filters.Path.startsWith("/world", caseSensitive: true, required: true))
        destination.addFilter(Filters.Message.startsWith("SQL:", caseSensitive: true, required: true))
        destination.addFilter(Filters.Message.contains("insert", caseSensitive: false, required: true))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.warning,
                                                      path: "/world/beaver.swift", function: "executeSQLStatement",
                                                      message: "SQL: INSERT INTO table (c1, c2) VALUES (1, 2)"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterARequiredPathFilterAndTwoRequiredMessageFiltersAndDoesNotPass_False() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.info
        destination.addFilter(Filters.Path.startsWith("/world", caseSensitive: true, required: true))
        destination.addFilter(Filters.Message.startsWith("SQL:", caseSensitive: true, required: true))
        destination.addFilter(Filters.Message.contains("insert", caseSensitive: false, required: true))
        XCTAssertFalse(destination.shouldLevelBeLogged(.debug,
                                                       path: "/world/beaver.swift",
                                                       function: "executeSQLStatement",
                                                       message: "SQL: DELETE FROM table WHERE c1 = 1"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterCombinationOfAllOtherFiltersAndPasses_True() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.info
        destination.addFilter(Filters.Path.startsWith("/world", caseSensitive: true, required: true))
        destination.addFilter(Filters.Path.endsWith("/beaver.swift", caseSensitive: true, required: true))
        destination.addFilter(Filters.Function.equals("executeSQLStatement", required: true))
        destination.addFilter(Filters.Message.startsWith("SQL:", caseSensitive: true, required: true))
        destination.addFilter(Filters.Message.contains("insert", "update", "delete", required: true))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.warning,
                                                      path: "/world/beaver.swift",
                                                      function: "executeSQLStatement",
                                                      message: "SQL: INSERT INTO table (c1, c2) VALUES (1, 2)"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterCombinationOfAllOtherFiltersAndDoesNotPass_False() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.info
        destination.addFilter(Filters.Path.startsWith("/world", caseSensitive: true, required: true))
        destination.addFilter(Filters.Path.endsWith("/beaver.swift", caseSensitive: true, required: true))
        destination.addFilter(Filters.Function.equals("executeSQLStatement", required: true))
        destination.addFilter(Filters.Message.startsWith("SQL:", caseSensitive: true, required: true))
        destination.addFilter(Filters.Message.contains("insert", "update", "delete", required: true))
        XCTAssertFalse(destination.shouldLevelBeLogged(.debug,
                                                       path: "/world/beaver.swift",
                                                       function: "executeSQLStatement",
                                                       message: "SQL: CREATE TABLE sample (c1 INTEGER, c2 VARCHAR)"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterCombinationOfOtherFiltersIncludingNonRequiredAndPasses_True() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.info
        destination.addFilter(Filters.Path.startsWith("/world", caseSensitive: true, required: true))
        destination.addFilter(Filters.Path.endsWith("/beaver.swift", caseSensitive: true, required: true))
        destination.addFilter(Filters.Function.equals("executeSQLStatement", required: true))
        destination.addFilter(Filters.Message.startsWith("SQL:", caseSensitive: true, required: true))
        destination.addFilter(Filters.Message.contains("insert"))
        destination.addFilter(Filters.Message.contains("update"))
        destination.addFilter(Filters.Message.contains("delete"))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.warning,
                                                      path: "/world/beaver.swift",
                                                      function: "executeSQLStatement",
                                                      message: "SQL: INSERT INTO table (c1, c2) VALUES (1, 2)"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterCombinationOfOtherFiltersIncludingNonRequired_True() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.info
        destination.addFilter(Filters.Path.startsWith("/world", caseSensitive: true, required: true))
        destination.addFilter(Filters.Path.endsWith("/beaver.swift", caseSensitive: true, required: true))
        destination.addFilter(Filters.Function.equals("executeSQLStatement", required: true))
        destination.addFilter(Filters.Message.startsWith("SQL:", caseSensitive: true, required: true))
        destination.addFilter(Filters.Message.contains("insert", caseSensitive: true))
        destination.addFilter(Filters.Message.contains("update"))
        destination.addFilter(Filters.Message.contains("delete"))
        XCTAssertTrue(destination.shouldLevelBeLogged(SwiftyBeaver.Level.warning,
                                                      path: "/world/beaver.swift",
                                                      function: "executeSQLStatement",
                                                      message: "SQL: INSERT INTO table (c1, c2) VALUES (1, 2)"))
    }

    func test_shouldLevelBeLogged_hasLevelFilterCombinationOfOtherFiltersIncludingNonRequired_False() {
        let destination = BaseDestination()
        destination.minLevel = SwiftyBeaver.Level.info
        destination.addFilter(Filters.Path.startsWith("/world", caseSensitive: true, required: true))
        destination.addFilter(Filters.Path.endsWith("/beaver.swift", caseSensitive: true, required: true))
        destination.addFilter(Filters.Function.equals("executeSQLStatement", required: true))
        destination.addFilter(Filters.Message.startsWith("SQL:", caseSensitive: true, required: true))
        destination.addFilter(Filters.Message.contains("rename", caseSensitive: true, required: true))
        destination.addFilter(Filters.Message.contains("update"))
        destination.addFilter(Filters.Message.contains("delete"))
        XCTAssertFalse(destination.shouldLevelBeLogged(.debug,
                                                       path: "/world/beaver.swift",
                                                       function: "executeSQLStatement",
                                                       message: "SQL: INSERT INTO table (c1, c2) VALUES (1, 2)"))
    }

    func test_shouldLevelBeLogged_hasMatchingNonRequiredFilter_True() {
        let destination = BaseDestination()
        destination.minLevel = .info
        destination.addFilter(Filters.Path.contains("/ViewController"))
        XCTAssertTrue(destination.shouldLevelBeLogged(.debug,
                                                      path: "/world/ViewController.swift",
                                                      function: "myFunc",
                                                      message: "Hello World"))
    }

    func test_shouldLevelBeLogged_hasNoMatchingNonRequiredFilter_False() {
        let destination = BaseDestination()
        destination.minLevel = .info
        destination.addFilter(Filters.Path.contains("/ViewController"))
        XCTAssertFalse(destination.shouldLevelBeLogged(.debug,
                                                       path: "/world/beaver.swift",
                                                       function: "myFunc",
                                                       message: "Hello World"))
    }

    func test_shouldLevelBeLogged_hasNoMatchingNonRequiredFilterAndMinLevel_False() {
        let destination = BaseDestination()
        destination.minLevel = .info
        destination.addFilter(Filters.Path.contains("/ViewController", minLevel: .debug))
        XCTAssertFalse(destination.shouldLevelBeLogged(.verbose,
                                                       path: "/world/ViewController.swift",
                                                       function: "myFunc",
                                                       message: "Hello World"))
    }

    func test_shouldLevelBeLogged_noFilters_True() {
        // everything is logged on default
        let destination = BaseDestination()
        XCTAssertTrue(destination.shouldLevelBeLogged(.debug,
                                                      path: "/world/ViewController.swift",
                                                      function: "myFunc",
                                                      message: "Hello World"))
    }

    func test_shouldLevelBeLogged_multipleNonRequiredFiltersAndGlobal_True() {
        // everything is logged on default
        let destination = BaseDestination()
        destination.minLevel = .info

        destination.addFilter(Filters.Path.contains("/ViewController", minLevel: .debug))
        destination.addFilter(Filters.Function.contains("Func", minLevel: .debug))
        destination.addFilter(Filters.Message.contains("World", minLevel: .debug))
        //destination.debugPrint = true

        // covered by filters
        XCTAssertTrue(destination.shouldLevelBeLogged(.debug,
                                                      path: "/world/ViewController.swift",
                                                      function: "myFunc",
                                                      message: "Hello World"))

        // not in filter and below global minLevel
        XCTAssertFalse(destination.shouldLevelBeLogged(.debug,
                                                       path: "hello.swift",
                                                       function: "foo",
                                                       message: "bar"))
    }



    func test_shouldLevelBeLogged_excludeFilter_True() {
        // everything is logged on default
        let destination = BaseDestination()
        destination.minLevel = .error

        destination.addFilter(Filters.Path.contains("/ViewController", minLevel: .debug))
        destination.addFilter(Filters.Function.excludes("myFunc", minLevel: .debug))
        //destination.debugPrint = true

        // excluded
        XCTAssertFalse(destination.shouldLevelBeLogged(.debug,
                                                       path: "/world/ViewController.swift",
                                                       function: "myFunc",
                                                       message: "Hello World"))

        // excluded
        XCTAssertFalse(destination.shouldLevelBeLogged(.error,
                                                       path: "/world/ViewController.swift",
                                                       function: "myFunc",
                                                       message: "Hello World"))

        // not excluded, but below minLevel
        XCTAssertFalse(destination.shouldLevelBeLogged(.debug,
                                                       path: "/world/OtherViewController.swift",
                                                       function: "otherFunc",
                                                       message: "Hello World"))

        // not excluded, but above minLevel
        XCTAssertTrue(destination.shouldLevelBeLogged(.error,
                                                      path: "/world/OtherViewController.swift",
                                                      function: "otherFunc",
                                                      message: "Hello World"))
    }

}
