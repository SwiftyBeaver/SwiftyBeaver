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
        str = obj.formatMessage(format, level: .Verbose, msg: "Hello", thread: "main",
                                file: "/path/to/ViewController.swift", function: "testFunction()", line: 50)
        XCTAssertEqual(str, "")

        // format without variables
        format = "Hello"
        str = obj.formatMessage(format, level: .Verbose, msg: "Hello", thread: "main",
                                file: "/path/to/ViewController.swift", function: "testFunction()", line: 50)
        XCTAssertEqual(str, "Hello")

        // weird format
        format = "$"
        str = obj.formatMessage(format, level: .Verbose, msg: "Hello", thread: "main",
                                file: "/path/to/ViewController.swift", function: "testFunction()", line: 50)
        XCTAssertEqual(str, "")

        // basic format
        format = "|$T| $L: $M"
        str = obj.formatMessage(format, level: .Verbose, msg: "Hello", thread: "main",
                                file: "/path/to/ViewController.swift", function: "testFunction()", line: 50)
        XCTAssertEqual(str, "|main| VERBOSE: Hello")

        // format with date and color
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = formatter.stringFromDate(NSDate())

        obj.levelColor.Verbose = "?"
        obj.escape = ">"
        obj.reset = "<"

        format = "[$Dyyyy-MM-dd HH:mm:ss$d] |$T| $N.$F:$l $C$L$c: $M"
        str = obj.formatMessage(format, level: .Verbose, msg: "Hello", thread: "main",
                                file: "/path/to/ViewController.swift", function: "testFunction()", line: 50)
        XCTAssertEqual(str, "[\(dateStr)] |main| ViewController.testFunction():50 >?VERBOSE<: Hello")
    }

    func testLevelWord() {
        let obj = BaseDestination()
        var str = ""

        str = obj.levelWord(SwiftyBeaver.Level.Verbose)
        XCTAssertNotNil(str, "VERBOSE")
        str = obj.levelWord(SwiftyBeaver.Level.Debug)
        XCTAssertNotNil(str, "DEBUG")
        str = obj.levelWord(SwiftyBeaver.Level.Info)
        XCTAssertNotNil(str, "INFO")
        str = obj.levelWord(SwiftyBeaver.Level.Warning)
        XCTAssertNotNil(str, "WARNING")
        str = obj.levelWord(SwiftyBeaver.Level.Error)
        XCTAssertNotNil(str, "ERROR")

        // custom level strings
        obj.levelString.Verbose = "Who cares"
        obj.levelString.Debug = "Look"
        obj.levelString.Info = "Interesting"
        obj.levelString.Warning = "Oh oh"
        obj.levelString.Error = "OMG!!!"

        str = obj.levelWord(SwiftyBeaver.Level.Verbose)
        XCTAssertNotNil(str, "Who cares")
        str = obj.levelWord(SwiftyBeaver.Level.Debug)
        XCTAssertNotNil(str, "Look")
        str = obj.levelWord(SwiftyBeaver.Level.Info)
        XCTAssertNotNil(str, "Interesting")
        str = obj.levelWord(SwiftyBeaver.Level.Warning)
        XCTAssertNotNil(str, "Oh oh")
        str = obj.levelWord(SwiftyBeaver.Level.Error)
        XCTAssertNotNil(str, "OMG!!!")
    }

    func testColorForLevel() {
        let obj = BaseDestination()
        var str = ""

        // empty on default
        str = obj.colorForLevel(SwiftyBeaver.Level.Verbose)
        XCTAssertNotNil(str, "")
        str = obj.colorForLevel(SwiftyBeaver.Level.Debug)
        XCTAssertNotNil(str, "")
        str = obj.colorForLevel(SwiftyBeaver.Level.Info)
        XCTAssertNotNil(str, "")
        str = obj.colorForLevel(SwiftyBeaver.Level.Warning)
        XCTAssertNotNil(str, "")
        str = obj.colorForLevel(SwiftyBeaver.Level.Error)
        XCTAssertNotNil(str, "")

        // custom level color strings
        obj.levelString.Verbose = "silver"
        obj.levelString.Debug = "green"
        obj.levelString.Info = "blue"
        obj.levelString.Warning = "yellow"
        obj.levelString.Error = "red"

        str = obj.colorForLevel(SwiftyBeaver.Level.Verbose)
        XCTAssertNotNil(str, "silver")
        str = obj.colorForLevel(SwiftyBeaver.Level.Debug)
        XCTAssertNotNil(str, "green")
        str = obj.colorForLevel(SwiftyBeaver.Level.Info)
        XCTAssertNotNil(str, "blue")
        str = obj.colorForLevel(SwiftyBeaver.Level.Warning)
        XCTAssertNotNil(str, "yellow")
        str = obj.colorForLevel(SwiftyBeaver.Level.Error)
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
        // format with date and color
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let dateStr = formatter.stringFromDate(NSDate())
        str = BaseDestination().formatDate(formatter.dateFormat)
        XCTAssertEqual(str, dateStr)
    }


    ////////////////////////////////
    // MARK: Filters
    ////////////////////////////////

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

        // not in filter and below global minLevel
        XCTAssertFalse(destination.shouldLevelBeLogged(.Debug,
            path: "hello.swift",
            function: "foo",
            message: "bar"))
    }



    func test_shouldLevelBeLogged_excludeFilter_True() {
        // everything is logged on default
        let destination = BaseDestination()
        destination.minLevel = .Error

        destination.addFilter(Filters.Path.contains("/ViewController", minLevel: .Debug))
        destination.addFilter(Filters.Function.excludes("myFunc", minLevel: .Debug))
        //destination.debugPrint = true

        // excluded
        XCTAssertFalse(destination.shouldLevelBeLogged(.Debug,
            path: "/world/ViewController.swift",
            function: "myFunc",
            message: "Hello World"))

        // excluded
        XCTAssertFalse(destination.shouldLevelBeLogged(.Error,
            path: "/world/ViewController.swift",
            function: "myFunc",
            message: "Hello World"))

        // not excluded, but below minLevel
        XCTAssertFalse(destination.shouldLevelBeLogged(.Debug,
            path: "/world/OtherViewController.swift",
            function: "otherFunc",
            message: "Hello World"))

        // not excluded, but above minLevel
        XCTAssertTrue(destination.shouldLevelBeLogged(.Error,
            path: "/world/OtherViewController.swift",
            function: "otherFunc",
            message: "Hello World"))
    }

}
