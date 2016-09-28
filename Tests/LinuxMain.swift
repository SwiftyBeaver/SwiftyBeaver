import XCTest
@testable import SwiftyBeaverTests

#if os(Linux)
XCTMain([
    testCase(SwiftyBeaverTests.allTests)
])
#endif
