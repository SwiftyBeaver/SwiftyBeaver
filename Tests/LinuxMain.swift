import XCTest
@testable import SwiftyBeaverTests

XCTMain([
    testCase(AES256CBCTests.allTests), // takes too long
    testCase(BaseDestinationTests.allTests),
    //testCase(DestinationSetTests.allTests),
    testCase(ConsoleDestinationTests.allTests),
    //testCase(FileDestinationTests.allTests),
    //testCase(SBPlatformDestinationTests.allTests),
    testCase(SwiftyBeaverTests.allTests),
    //testCase(GoogleCloudDestinationTests.allTests)
])

// All tests:
// the SBPlatformDestinationTests crashes testing under Linux with a linker issue?
// Log into Docker container to find  issue:
// docker run --rm -it -v $PWD:/app swiftybeaver /bin/bash -c "cd /app ; swift build ; swift test"

/*
 
 testCase(AES256CBCTests.allTests),
 testCase(BaseDestinationTests.allTests),
 testCase(DestinationSetTests.allTests),
 testCase(FileDestinationTests.allTests),
 testCase(SBPlatformDestinationTests.allTests),
 testCase(SwiftyBeaverTests.allTests),
 
 */
