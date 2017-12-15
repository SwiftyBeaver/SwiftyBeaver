//
//  Created by Christian Tietze (@ctietze) on 2017-12-14.
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import XCTest
@testable import SwiftyBeaver

class RotatingFileDestinationTests: XCTestCase {

    var irrelevantClock: Clock { return SystemClock() }
    var irrelevantBaseURL: URL { return URL(fileURLWithPath: "irrelevant") }
    var irrelevantFileName: RotatingFileDestination.FileName { return RotatingFileDestination.FileName(name: "irrelevant", pathExtension: "irrelevant") }

    override func setUp() {
        super.setUp()
        SwiftyBeaver.removeAllDestinations()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInitializer_DefaultValues() {
        let destination = RotatingFileDestination()

        XCTAssertEqual(destination.fileName.name, "swiftybeaver")
        XCTAssertEqual(destination.baseURL, defaultBaseURL())
        XCTAssertEqual(destination.fileName.pathExtension, "log")
        XCTAssertEqual(destination.rotation, .daily)
    }

    func testInitializer_UsesSameSettingsAsFileDestination() {
        assertEqualSettings(RotatingFileDestination(), FileDestination())
    }

    func testCurrentFileName() {
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

    func testCurrentFileName_RotatesWithClock() {

        let clockDouble = ClockDouble(year: 1967, month: 6, day: 2)
        let destination = RotatingFileDestination(
            rotation: .daily,
            logDirectoryURL: irrelevantBaseURL,
            fileName: .init(name: "base", pathExtension: "ext"),
            clock: clockDouble)

        XCTAssertEqual(destination.currentFileName, "base-1967-06-02.ext")

        clockDouble.changeDate(year: 1967, month: 6, day: 3)

        XCTAssertEqual(destination.currentFileName, "base-1967-06-03.ext")
    }

    func testCurrentURL_BaseIsNil_ReturnsNil() {

        let destination = RotatingFileDestination(
            rotation: .daily,
            logDirectoryURL: nil,
            fileName: irrelevantFileName,
            clock: irrelevantClock)
        XCTAssertNil(destination.currentURL)
    }

    func testCurrentURL_BaseIsRegularFileURL() {

        let baseURL = URL(fileURLWithPath: "/foo/bar")
        let destination = RotatingFileDestination(
            rotation: .daily,
            logDirectoryURL: baseURL,
            fileName: .init(name: "some", pathExtension: "ext"),
            clock: ClockDouble(year: 1987, month: 11, day: 09))

        XCTAssertEqual(
            destination.currentURL,
            baseURL.appendingPathComponent("some-1987-11-09.ext", isDirectory: false))
    }

    func testCurrentURL_BaseIsDirectoryURL() {

        let baseURL = URL(fileURLWithPath: "/fizz/buzz", isDirectory: true)
        let destination = RotatingFileDestination(
            rotation: .daily,
            logDirectoryURL: baseURL,
            fileName: .init(name: "swifty", pathExtension: "beaver"),
            clock: ClockDouble(year: 2017, month: 12, day: 14))

        XCTAssertEqual(
            destination.currentURL,
            baseURL.appendingPathComponent("swifty-2017-12-14.beaver", isDirectory: false))
    }

    func testFileDestination_ConvenienceInitializer_ReturnsFileDestination() {

        let destination = RotatingFileDestination()

        XCTAssertNotNil(destination.fileDestination)
        if let fileDestination = destination.fileDestination {
            assertEqualSettings(fileDestination, destination)
            XCTAssertEqual(fileDestination.logFileURL, destination.currentURL)
        }
    }

    func testFileDestination_BaseIsNil_ReturnsNil() {

        let destination = RotatingFileDestination(
            rotation: .daily,
            logDirectoryURL: nil,
            fileName: irrelevantFileName,
            clock: irrelevantClock)
        XCTAssertNil(destination.fileDestination)
    }

    func testFileDestination_BaseIsNotNil_ReturnsFileDestinationWithSameSettings() {

        let baseURL = URL(fileURLWithPath: "/fizz/buzz", isDirectory: true)
        let destination = RotatingFileDestination(
            rotation: .daily,
            logDirectoryURL: baseURL,
            fileName: .init(name: "as", pathExtension: "df"),
            clock: ClockDouble(year: 2000, month: 06, day: 18))

        XCTAssertNotNil(destination.fileDestination)
        if let fileDestination = destination.fileDestination {
            assertEqualSettings(fileDestination, destination)
            XCTAssertEqual(fileDestination.logFileURL, destination.currentURL)
        }
    }

    func testFileDestination_BaseIsNotNil_ChangesOnRotation() {

        let baseURL = URL(fileURLWithPath: "/foo/bar", isDirectory: true)
        let clockDouble = ClockDouble(year: 1998, month: 04, day: 12)
        let destination = RotatingFileDestination(
            rotation: .daily,
            logDirectoryURL: baseURL,
            fileName: .init(name: "file", pathExtension: "txt"),
            clock: clockDouble)

        let originalFileDestination = destination.fileDestination
        XCTAssertNotNil(originalFileDestination)
        XCTAssertEqual(originalFileDestination?.logFileURL, destination.currentURL)

        clockDouble.changeDate(year: 1998, month: 04, day: 13)

        let secondFileDestination = destination.fileDestination
        XCTAssertNotNil(secondFileDestination)
        XCTAssertEqual(secondFileDestination?.logFileURL, destination.currentURL)

        XCTAssert(originalFileDestination !== secondFileDestination)
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

fileprivate class ClockDouble: Clock {

    var testDate: Date

    init(date: Date) {
        self.testDate = date
    }

    convenience init(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 12,
        minute: Int = 15,
        second: Int = 30,
        calendar: Calendar = Calendar(identifier: .gregorian)) {

        let components = DateComponents(calendar: calendar, year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        self.init(date: calendar.date(from: components)!)
    }

    func changeDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 12,
        minute: Int = 15,
        second: Int = 30,
        calendar: Calendar = Calendar(identifier: .gregorian)) {

        let components = DateComponents(calendar: calendar, year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        self.testDate = calendar.date(from: components)!
    }

    func now() -> Date {
        return testDate
    }
}


fileprivate func assertEqualSettings(_ lhs: BaseDestination, _ rhs: BaseDestination, file: StaticString = #file, line: UInt = #line) {

    XCTAssertEqual(lhs.format, rhs.format, file: file, line: line)
    XCTAssertEqual(lhs.reset, rhs.reset, file: file, line: line)
    XCTAssertEqual(lhs.escape, rhs.escape, file: file, line: line)
    XCTAssertEqual(lhs.asynchronously, rhs.asynchronously, file: file, line: line)
    XCTAssert(lhs.filters == rhs.filters, file: file, line: line)
    XCTAssertEqual(lhs.minLevel, rhs.minLevel, file: file, line: line)
    XCTAssert(lhs.levelString == rhs.levelString, file: file, line: line)
    XCTAssert(lhs.levelColor == rhs.levelColor, file: file, line: line)
}

fileprivate func ==(lhs: BaseDestination.LevelString, rhs: BaseDestination.LevelString) -> Bool {
    return lhs.debug == rhs.debug
        && lhs.error == rhs.error
        && lhs.info == rhs.info
        && lhs.verbose == rhs.verbose
        && lhs.warning == rhs.warning
}

fileprivate func ==(lhs: BaseDestination.LevelColor, rhs: BaseDestination.LevelColor) -> Bool {
    return lhs.debug == rhs.debug
        && lhs.error == rhs.error
        && lhs.info == rhs.info
        && lhs.verbose == rhs.verbose
        && lhs.warning == rhs.warning
}

fileprivate func ==(lhs: [FilterType], rhs: [FilterType]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (lElement, rElement) in zip(lhs, rhs) {
        if lElement !== rElement { return false }
    }
    return true
}

