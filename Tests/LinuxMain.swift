import XCTest
@testable import SwiftyBeaverTests

XCTMain([
    testCase(BaseDestinationTests.allTests),
    testCase(ConsoleDestinationTests.allTests),
    testCase(SwiftyBeaverTests.allTests),
])
