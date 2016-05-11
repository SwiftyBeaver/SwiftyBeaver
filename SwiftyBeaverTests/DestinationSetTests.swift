//
//  DestinationSetTests.swift
//  SwiftyBeaver
//
//  Created by Mark Schultz on 5/5/16.
//  Copyright © 2016 Sebastian Kreutzberger. All rights reserved.
//

import XCTest
import SwiftyBeaver

class DestinationSetTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        SwiftyBeaver.removeAllDestinations()
    }

    func testChangeDestinationsMinLogLevels() {
        let log = SwiftyBeaver.self

        // Test for default state
        XCTAssertEqual(log.countDestinations(), 0)

        // add valid destinations
        let console = ConsoleDestination()
        let console2 = ConsoleDestination()
        let file = FileDestination()

        log.addDestination(console)
        log.addDestination(console2)
        log.addDestination(file)

        // Test that destinations are successfully added
        XCTAssertEqual(log.countDestinations(), 3)

        // Test default log level of destinations
        log.destinations.forEach {
            XCTAssertEqual($0.minLevel, SwiftyBeaver.Level.Verbose)
        }

        // Change min log level for all destinations
        log.destinations.forEach { $0.minLevel = .Info }

        // Test min level of destinations has changed
        log.destinations.forEach {
            XCTAssertEqual($0.minLevel, SwiftyBeaver.Level.Info)
        }
    }

    func testRemoveConsoleDestinations() {
        let log = SwiftyBeaver.self

        // Test for default state
        XCTAssertEqual(log.countDestinations(), 0)

        // add valid destinations
        let console = ConsoleDestination()
        let console2 = ConsoleDestination()
        let file = FileDestination()

        log.addDestination(console)
        log.addDestination(console2)
        log.addDestination(file)

        // Test that destinations are successfully added
        XCTAssertEqual(log.countDestinations(), 3)

        // Remove console destinations
        log.destinations.forEach {
            if let consoleDestination = $0 as? ConsoleDestination {
                log.removeDestination(consoleDestination)
            }
        }

        // Test that console destinations are removed
        XCTAssertEqual(log.countDestinations(), 1)
    }

}
