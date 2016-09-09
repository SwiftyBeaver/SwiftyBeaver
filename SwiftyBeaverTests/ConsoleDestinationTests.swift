//
//  ConsoleDestinationTests.swift
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger on 7/29/16.
//  Copyright © 2016 Sebastian Kreutzberger. All rights reserved.
//

import XCTest
@testable import SwiftyBeaver

class ConsoleDestinationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        SwiftyBeaver.removeAllDestinations()
    }

    override func tearDown() {
        super.tearDown()
    }
}
