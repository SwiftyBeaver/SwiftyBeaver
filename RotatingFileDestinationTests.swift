//
//  Created by Christian Tietze (@ctietze) on 2017-12-14.
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import XCTest
@testable import SwiftyBeaver

class RotatingFileDestinationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        SwiftyBeaver.removeAllDestinations()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInitializerDefaultValues() {
        let destination = RotatingFileDestination()

        XCTAssertEqual(destination.fileName.name, "swiftybeaver")
        XCTAssertEqual(destination.baseURL, defaultBaseURL())
        XCTAssertEqual(destination.fileName.pathExtension, "log")
        XCTAssertEqual(destination.rotation, .daily)
    }

    func testCurrentFileName() {
        let irrelevantBaseURL: URL? = URL(fileURLWithPath: "irrelevant")

        XCTAssertEqual(
            RotatingFileDestination(
                rotation: .daily,
                logDirectoryURL: irrelevantBaseURL,
                fileName: .init(name: "base", pathExtension: "ext"),
                clock: ClockDouble(year: 2020, month: 05, day: 17))
                .currentFileName,
            "base-2020-05-17.ext")

        XCTAssertEqual(
            RotatingFileDestination(
                rotation: .daily,
                logDirectoryURL: irrelevantBaseURL,
                fileName: .init(name: "base", pathExtension: "ext"),
                clock: ClockDouble(year: 1987, month: 11, day: 09))
                .currentFileName,
            "base-1987-11-09.ext")

        XCTAssertEqual(
            RotatingFileDestination(
                rotation: .daily,
                logDirectoryURL: irrelevantBaseURL,
                fileName: .init(name: "swiftybeaver", pathExtension: "log"),
                clock: ClockDouble(year: 2017, month: 12, day: 14))
                .currentFileName,
            "swiftybeaver-2017-12-14.log")
    }
}

class RotationTests: XCTestCase {
    func testDateFormat_Daily() {
        XCTAssertEqual(RotatingFileDestination.Rotation.daily.dateFormat, "yyyy-MM-dd")
    }
}

class FileNameTests: XCTestCase {
    func testPathComponent() {
        XCTAssertEqual(
            RotatingFileDestination
                .FileName(name: "foo", pathExtension: "bar")
                .pathComponent(suffix: "baz"),
            "foo-baz.bar")
        XCTAssertEqual(
            RotatingFileDestination
                .FileName(name: "foo", pathExtension: "bar")
                .pathComponent(suffix: "fizz"),
            "foo-fizz.bar")
        XCTAssertEqual(
            RotatingFileDestination
                .FileName(name: "fizz", pathExtension: "test")
                .pathComponent(suffix: "buzz"),
            "fizz-buzz.test")
    }
}

// MARK: - Helpers

import Foundation

fileprivate struct ClockDouble: Clock {

    let testDate: Date

    init(year: Int,
         month: Int,
         day: Int,
         hour: Int = 12,
         minute: Int = 15,
         second: Int = 30,
         calendar: Calendar = Calendar(identifier: .gregorian)) {

        let components = DateComponents(calendar: calendar, year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        testDate = calendar.date(from: components)!
    }

    func now() -> Date {
        return testDate
    }
}
