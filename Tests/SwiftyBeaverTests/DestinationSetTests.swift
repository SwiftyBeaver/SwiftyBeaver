//
//  DestinationSetTests.swift
//  SwiftyBeaver
//
//  Created by Mark Schultz on 5/5/16.
//  Copyright © 2016 Sebastian Kreutzberger. All rights reserved.
//

import XCTest
import SwiftyBeaverKit

class DestinationSetTests: XCTestCase {

    override func setUp() {
        super.setUp()
        SwiftyBeaverKit.removeAllDestinations()
    }

    override func tearDown() {
        super.tearDown()
        SwiftyBeaverKit.removeAllDestinations()
    }

    func testChangeDestinationsMinLogLevels() {
        let log = SwiftyBeaverKit.self

        // Test for default state
        XCTAssertEqual(log.countDestinations(), 0)

        // add valid destinations
        let console = ConsoleDestination()
        let console2 = ConsoleDestination()
        let file = FileDestination()

        XCTAssertTrue(log.addDestination(console))
        XCTAssertTrue(log.addDestination(console2))
        XCTAssertTrue(log.addDestination(file))

        // Test that destinations are successfully added
        XCTAssertEqual(log.countDestinations(), 3)

        // Test default log level of destinations
        log.destinations.forEach {
            XCTAssertEqual($0.minLevel, SwiftyBeaverKit.Level.verbose)
        }

        // Change min log level for all destinations
        log.destinations.forEach { $0.minLevel = .info }

        // Test min level of destinations has changed
        log.destinations.forEach {
            XCTAssertEqual($0.minLevel, SwiftyBeaverKit.Level.info)
        }
    }

    func testRemoveConsoleDestinations() {
        let log = SwiftyBeaverKit.self

        // Test for default state
        XCTAssertEqual(log.countDestinations(), 0)

        // add valid destinations
        let console = ConsoleDestination()
        let console2 = ConsoleDestination()
        let file = FileDestination()

        XCTAssertTrue(log.addDestination(console))
        XCTAssertTrue(log.addDestination(console2))
        XCTAssertTrue(log.addDestination(file))

        // Test that destinations are successfully added
        XCTAssertEqual(log.countDestinations(), 3)

        // Remove console destinations
        log.destinations.forEach {
            if let consoleDestination = $0 as? ConsoleDestination {
                XCTAssertTrue(log.removeDestination(consoleDestination))
            }
        }

        // Test that console destinations are removed
        XCTAssertEqual(log.countDestinations(), 1)
    }

    // MARK: Linux allTests

    static let allTests = [
        ("testChangeDestinationsMinLogLevels", testChangeDestinationsMinLogLevels),
        ("testRemoveConsoleDestinations", testRemoveConsoleDestinations)

    ]
}
