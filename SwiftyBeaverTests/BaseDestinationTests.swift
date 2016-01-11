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
    
    func testShouldLevelBeLogged() {
        let obj = BaseDestination()
        obj.minLevel = SwiftyBeaver.Level.Info
        
        // filters to set minLevel to Verbose for certain files / folders
        obj.addMinLevelFilter(.Verbose, path: "foo.swift")
        obj.addMinLevelFilter(.Verbose, path: "/bar/")
        obj.addMinLevelFilter(.Verbose, path: "/app")
        obj.addMinLevelFilter(.Verbose, path: "/world/beaver.swift", function: "AppDelegate")
        obj.addMinLevelFilter(.Verbose, path: "", function: "MyFunction")
        
        // check instance minLevel property
        XCTAssertFalse(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Verbose, path: "", function: ""))
        XCTAssertFalse(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Debug, path: "", function: ""))
        XCTAssertTrue(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Info, path: "", function: ""))
        XCTAssertTrue(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Warning, path: "", function: ""))
        XCTAssertTrue(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Error, path: "", function: ""))
        // check if filters overrule instance property
        XCTAssertFalse(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Verbose, path: "foo2.swift", function: ""))
        XCTAssertFalse(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Verbose, path: "Foo.swift", function: ""))
        XCTAssertTrue(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Verbose, path: "foo.swift", function: ""))
        XCTAssertTrue(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Verbose, path: "/hello/foo.swift", function: ""))
        // check filter 2
        XCTAssertFalse(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Verbose, path: "bar", function: ""))
        XCTAssertFalse(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Verbose, path: "/Bar/", function: ""))
        XCTAssertTrue(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Verbose, path: "/bar/", function: ""))
        XCTAssertTrue(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Verbose, path: "/hello/bar/beaver", function: ""))
        // check filter 3
        XCTAssertFalse(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Verbose, path: "/lol/App2/", function: ""))
        XCTAssertTrue(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Verbose, path: "/lol/app2/", function: ""))
        XCTAssertTrue(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Verbose, path: "/lol/app", function: ""))
        // check filter 4 (file & function)
        XCTAssertFalse(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Verbose, path: "/world/beaver/", function: ""))
        XCTAssertFalse(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Verbose, path: "world/beaver.swift", function: ""))
        XCTAssertFalse(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Verbose, path: "/world/beaver.swift", function: "appDelegate"))
        XCTAssertTrue(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Verbose, path: "/world/beaver.swift", function: "AppDelegate"))
        // check filter 5 (function)
        XCTAssertTrue(obj.shouldLevelBeLogged(SwiftyBeaver.Level.Verbose, path: "", function: "MyFunction"))
    }
}
