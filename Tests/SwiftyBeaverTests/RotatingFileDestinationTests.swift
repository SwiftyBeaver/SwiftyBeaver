//
//  Created by Christian Tietze (@ctietze) on 2017-12-14.
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import XCTest
@testable import SwiftyBeaver

class RotatingFileDestinationTests: XCTestCase {

    var irrelevantClock: Clock { return SystemClock() }
    var irrelevantURL: URL { return URL(fileURLWithPath: "irrelevant") }
    var irrelevantFileName: RotatingFileDestination.FileName { return RotatingFileDestination.FileName(name: "irrelevant", pathExtension: "irrelevant") }
    var irrelevantDeletionPolicy: RotatingFileDestination.DeletionPolicy { return .quantity(keep: 123) }

    func testInitializer_DefaultValues() {
        let destination = RotatingFileDestination()

        XCTAssertEqual(destination.fileName.name, "swiftybeaver")
        XCTAssertEqual(destination.baseURL, defaultBaseURL())
        XCTAssertEqual(destination.fileName.pathExtension, "log")
        XCTAssertEqual(destination.rotation, .daily)
        XCTAssertEqual(destination.deletionPolicy, .quantity(keep: 5))
    }

    func testInitializer_UsesSameSettingsAsFileDestination() {
        assertEqualSettings(RotatingFileDestination(), FileDestination())
    }

    // MARK: Rotation

    func testCurrentFileName() {
        XCTAssertEqual(
            RotatingFileDestination(
                rotation: .daily,
                deletionPolicy: irrelevantDeletionPolicy,
                logDirectoryURL: irrelevantURL,
                fileName: .init(name: "base", pathExtension: "ext"),
                clock: ClockDouble(year: 2020, month: 05, day: 17))
                .currentFileName,
            "base-2020-05-17.ext")

        XCTAssertEqual(
            RotatingFileDestination(
                rotation: .daily,
                deletionPolicy: irrelevantDeletionPolicy,
                logDirectoryURL: irrelevantURL,
                fileName: .init(name: "base", pathExtension: "ext"),
                clock: ClockDouble(year: 1987, month: 11, day: 09))
                .currentFileName,
            "base-1987-11-09.ext")

        XCTAssertEqual(
            RotatingFileDestination(
                rotation: .daily,
                deletionPolicy: irrelevantDeletionPolicy,
                logDirectoryURL: irrelevantURL,
                fileName: .init(name: "swiftybeaver", pathExtension: "log"),
                clock: ClockDouble(year: 2017, month: 12, day: 14))
                .currentFileName,
            "swiftybeaver-2017-12-14.log")
    }

    func testCurrentFileName_RotatesWithClock() {

        let clockDouble = ClockDouble(year: 1967, month: 6, day: 2)
        let destination = RotatingFileDestination(
            rotation: .daily,
            deletionPolicy: irrelevantDeletionPolicy,
            logDirectoryURL: irrelevantURL,
            fileName: .init(name: "base", pathExtension: "ext"),
            clock: clockDouble)

        XCTAssertEqual(destination.currentFileName, "base-1967-06-02.ext")

        clockDouble.changeDate(year: 1967, month: 6, day: 3)

        XCTAssertEqual(destination.currentFileName, "base-1967-06-03.ext")
    }

    func testCurrentURL_BaseIsNil_ReturnsNil() {

        let destination = RotatingFileDestination(
            rotation: .daily,
            deletionPolicy: irrelevantDeletionPolicy,
            logDirectory: nil,
            fileName: irrelevantFileName,
            clock: irrelevantClock)
        XCTAssertNil(destination.currentURL)
    }

    func testCurrentURL_BaseIsRegularFileURL() {

        let baseURL = URL(fileURLWithPath: "/foo/bar")
        let destination = RotatingFileDestination(
            rotation: .daily,
            deletionPolicy: irrelevantDeletionPolicy,
            logDirectory: createDirectoryStub(baseURL: baseURL),
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
            deletionPolicy: irrelevantDeletionPolicy,
            logDirectory: createDirectoryStub(baseURL: baseURL),
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
            deletionPolicy: irrelevantDeletionPolicy,
            logDirectoryURL: nil,
            fileName: irrelevantFileName,
            clock: irrelevantClock)
        XCTAssertNil(destination.fileDestination)
    }

    func testFileDestination_BaseIsNotNil_ReturnsFileDestinationWithSameSettings() {

        let baseURL = URL(fileURLWithPath: "/fizz/buzz", isDirectory: true)
        let destination = RotatingFileDestination(
            rotation: .daily,
            deletionPolicy: irrelevantDeletionPolicy,
            logDirectory: createDirectoryStub(baseURL: baseURL),
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
            deletionPolicy: irrelevantDeletionPolicy,
            logDirectory: createDirectoryStub(baseURL: baseURL),
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


    // MARK: Exercising deletion policy

    func testFileDestination_RotationCleansUpOutdatedFiles() {
        let clockDouble = ClockDouble(year: 2010, month: 10, day: 20)
        let existingLogFilesFromThePast = [
            fileURL("swifty-2010-10-10.beaver"),
            fileURL("swifty-2010-10-11.beaver"),
            fileURL("swifty-2010-10-12.beaver")
        ]
        let inspectorStub = DirectoryInspectorStub(urls: existingLogFilesFromThePast)

        let removalDouble = LogFileRemovalDouble()
        let destination = RotatingFileDestination(
            rotation: .daily,
            deletionPolicy: .quantity(keep: 2),
            logDirectory: LogDirectory(url: irrelevantURL, inspector: inspectorStub),
            fileName: .init(name: "swifty", pathExtension: "beaver"),
            clock: clockDouble)
        destination.removeLogFiles = removalDouble

        func simulateLoggingAtCurrentDate() {
            // Event that triggers the cleanup
            _ = destination.fileDestination

            // Simulates writing to file (prevent duplicates)
            inspectorStub.addIfNotExists(url: fileURL(destination.currentFileName))
        }

        // Precondition
        XCTAssert(removalDouble.removedLogFiles.isEmpty)

        do {
            // First access (set up)

            simulateLoggingAtCurrentDate()

            XCTAssertEqual(removalDouble.removedLogFiles, [
                fileURL("swifty-2010-10-10.beaver"),
                fileURL("swifty-2010-10-11.beaver")
                ])
        }

        do {
            // Access in same rotation does not trigger another cleanup

            simulateLoggingAtCurrentDate()

            // `removalDouble` *appends* reported URLs, so if they are the same,
            // nothing happened. (Continue reading this exciting story arc
            // to see what would happen!)
            XCTAssertEqual(removalDouble.removedLogFiles, [
                fileURL("swifty-2010-10-10.beaver"),
                fileURL("swifty-2010-10-11.beaver")
                ])
        }

        // Next day, next rotation
        clockDouble.changeDate(year: 2010, month: 10, day: 21)

        do {
            // Access in new rotation triggers cleanup again, picking up files
            // that were previously marked but not seem to be removed as well.

            simulateLoggingAtCurrentDate()

            XCTAssertEqual(removalDouble.removedLogFiles, [
                // Reported in last rotation
                fileURL("swifty-2010-10-10.beaver"),
                fileURL("swifty-2010-10-11.beaver"),

                // Reported in this rotation
                fileURL("swifty-2010-10-10.beaver"),
                fileURL("swifty-2010-10-11.beaver"),
                fileURL("swifty-2010-10-12.beaver")
                ])

            // Simulate deletion of the outdated files
            inspectorStub.remove(urls: [
                fileURL("swifty-2010-10-10.beaver"),
                fileURL("swifty-2010-10-11.beaver"),
                fileURL("swifty-2010-10-12.beaver")
                ])
        }

        // Another day, another rotation
        clockDouble.changeDate(year: 2010, month: 10, day: 22)

        do {
            simulateLoggingAtCurrentDate()

            XCTAssertEqual(removalDouble.removedLogFiles, [
                // Reported in the first rotation
                fileURL("swifty-2010-10-10.beaver"),
                fileURL("swifty-2010-10-11.beaver"),

                // Reported in the second rotation
                fileURL("swifty-2010-10-10.beaver"),
                fileURL("swifty-2010-10-11.beaver"),
                fileURL("swifty-2010-10-12.beaver"),

                // Reported in this rotation: the file we created at the beginning
                fileURL("swifty-2010-10-20.beaver")
                ])
        }
    }


    // MARK: Forward logging to `FileDestination`

    func testSend_ForwardsToFileDestination() {

        let fileDestinationDouble = FileDestinationSendingMock()
        let destination = MockFactoryRotatingFileDestination(testFileDestination: fileDestinationDouble)

        _ = destination.send(.info, msg: "the message", thread: "the thread", file: "the file", function: "the function", line: 1337, context: "a context")

        XCTAssertNotNil(fileDestinationDouble.didSend)
        if let values = fileDestinationDouble.didSend {
            XCTAssertEqual(values.level, .info)
            XCTAssertEqual(values.msg, "the message")
            XCTAssertEqual(values.thread, "the thread")
            XCTAssertEqual(values.file, "the file")
            XCTAssertEqual(values.function, "the function")
            XCTAssertEqual(values.line, 1337)
            XCTAssertEqual(values.context as? String, "a context")
        }
    }

    func testSend_ReturnsResultOfFileDestination() {

        let fileDestinationDouble = FileDestinationSendingMock()
        let destination = MockFactoryRotatingFileDestination(testFileDestination: fileDestinationDouble)
        fileDestinationDouble.testSendResult = "the result"

        let result = destination.send(.debug, msg: "irrelevant", thread: "irrelevant", file: "irrelevant", function: "irrelevant", line: 0, context: "irrelevant")

        XCTAssertEqual(result, "the result")
    }


    // MARK: Forwarding settings to `FileDestination`

    func testInitializer_DoesNotForward() {
        let fileDestinationDouble = FileDestinationSettingForwardingMock()
        _ = MockFactoryRotatingFileDestination(testFileDestination: fileDestinationDouble)
        XCTAssertFalse(fileDestinationDouble.didForward)
    }

    func testSettingsForwarding_Format() {

        let destination = RotatingFileDestination()
        guard let fileDestination = destination.fileDestination else { XCTFail("Expected fileDestination"); return }

        assertEqualSettings(destination, fileDestination)

        let format = "new format"
        destination.format = format

        XCTAssertEqual(fileDestination.format, format)
        assertEqualSettings(destination, fileDestination)
    }

    func testSettingsForwarding_Asynchrony() {

        let destination = RotatingFileDestination()
        guard let fileDestination = destination.fileDestination else { XCTFail("Expected fileDestination"); return }

        assertEqualSettings(destination, fileDestination)

        destination.asynchronously = !destination.asynchronously

        assertEqualSettings(destination, fileDestination)
    }

    func testSettingsForwarding_MinLevel() {

        let destination = RotatingFileDestination()
        guard let fileDestination = destination.fileDestination else { XCTFail("Expected fileDestination"); return }

        assertEqualSettings(destination, fileDestination)

        destination.minLevel = .error

        XCTAssertEqual(fileDestination.minLevel, .error)
        assertEqualSettings(destination, fileDestination)
    }

    func testSettingsForwarding_LevelString() {

        let destination = RotatingFileDestination()
        guard let fileDestination = destination.fileDestination else { XCTFail("Expected fileDestination"); return }

        assertEqualSettings(destination, fileDestination)

        let levelString = BaseDestination.LevelString(verbose: "1", debug: "2", info: "3", warning: "4", error: "5")
        destination.levelString = levelString

        XCTAssert(fileDestination.levelString == levelString)
        assertEqualSettings(destination, fileDestination)
    }

    func testSettingsForwarding_LevelColor() {

        let destination = RotatingFileDestination()
        guard let fileDestination = destination.fileDestination else { XCTFail("Expected fileDestination"); return }

        assertEqualSettings(destination, fileDestination)

        let levelColor = BaseDestination.LevelColor(verbose: "a", debug: "b", info: "c", warning: "d", error: "e")
        destination.levelColor = levelColor

        XCTAssert(fileDestination.levelColor == levelColor)
        assertEqualSettings(destination, fileDestination)
    }

    func testSettingsForwarding_Reset() {

        let destination = RotatingFileDestination()
        guard let fileDestination = destination.fileDestination else { XCTFail("Expected fileDestination"); return }

        assertEqualSettings(destination, fileDestination)

        let reset = "new reset"
        destination.reset = reset

        XCTAssertEqual(fileDestination.reset, reset)
        assertEqualSettings(destination, fileDestination)
    }

    func testSettingsForwarding_Escape() {

        let destination = RotatingFileDestination()
        guard let fileDestination = destination.fileDestination else { XCTFail("Expected fileDestination"); return }

        assertEqualSettings(destination, fileDestination)

        let escape = "new escape"
        destination.escape = escape

        XCTAssertEqual(fileDestination.escape, escape)
        assertEqualSettings(destination, fileDestination)
    }

    func testSettingsForwarding_Filters() {

        let destination = RotatingFileDestination()
        guard let fileDestination = destination.fileDestination else { XCTFail("Expected fileDestination"); return }

        assertEqualSettings(destination, fileDestination)

        let filters = [Filters.Message.contains("something")]
        destination.filters = filters

        XCTAssert(fileDestination.filters == filters)
        assertEqualSettings(destination, fileDestination)
    }

    func testSettingsForwarding_DebugPrint() {

        let destination = RotatingFileDestination()
        guard let fileDestination = destination.fileDestination else { XCTFail("Expected fileDestination"); return }

        assertEqualSettings(destination, fileDestination)

        destination.debugPrint = !destination.debugPrint

        assertEqualSettings(destination, fileDestination)
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

    func testFilterMatching() {
        let fileName = RotatingFileDestination.FileName(name: "foo", pathExtension: "log")

        XCTAssertEqual(fileName.filterMatching(fileURLs: []), [])
        XCTAssertEqual(
            fileName.filterMatching(fileURLs: [
                fileURL("/irrelevant/foo123.log"),
                fileURL("/fooBAR.log"),
                fileURL("/foo.differentExtension"),
                fileURL("relative/path/foo.log"),
                fileURL(".log"),
                fileURL("foo"),
                fileURL("foo."),
                fileURL("foo.log")
                ]),
            [
                fileURL("/irrelevant/foo123.log"),
                fileURL("/fooBAR.log"),
                fileURL("relative/path/foo.log"),
                fileURL("foo.log")
            ])
    }
}

fileprivate func fileURL(_ path: String) -> URL {
    return URL(fileURLWithPath: path)
}

class DeletionPolicyTests: XCTestCase {
    func testRemovable_ByQuantity() {
        let fileName = RotatingFileDestination.FileName(name: "rainbow", pathExtension: "txt")
        let directory = createDirectoryStub(fileURLs: [
            fileURL("somewhere/rainbow-2.txt"),
            fileURL("nowhere/rainbow-0.txt"),
            fileURL("totally/different/file.exe"),
            fileURL("somewhere/over/rainbow-1.txt"),
            fileURL("somewhere/over/the/rainbow-3.txt"),
            fileURL("even/more/rainbow-4.txt")])
        // Not part of the directory, so assume this file _will_ be written into.
        let nonexistingFileToBeWrittenTo = fileURL("tom/clancy's/rainbow-6.txt")

        func removableURLsForPolicy(keeping amount: UInt) -> [URL] {
            return RotatingFileDestination.DeletionPolicy
                .quantity(keep: amount)
                .filterRemovable(
                    assumingFileExistsAt: nonexistingFileToBeWrittenTo,
                    logDirectory: directory,
                    fileName: fileName)
        }

        XCTAssertEqual(
            removableURLsForPolicy(keeping: 0),
            [])

        XCTAssertEqual(
            removableURLsForPolicy(keeping: 1),
            [
                fileURL("nowhere/rainbow-0.txt"),
                fileURL("somewhere/over/rainbow-1.txt"),
                fileURL("somewhere/rainbow-2.txt"),
                fileURL("somewhere/over/the/rainbow-3.txt"),
                fileURL("even/more/rainbow-4.txt")
            ])

        XCTAssertEqual(
            removableURLsForPolicy(keeping: 3),
            [
                fileURL("nowhere/rainbow-0.txt"),
                fileURL("somewhere/over/rainbow-1.txt"),
                fileURL("somewhere/rainbow-2.txt")
            ])

        XCTAssertEqual(
            removableURLsForPolicy(keeping: 100),
            [])
    }
}

/// Creates a fake `Directory` without a file-system representation
/// that returns a static `fileURLs` (or throws).
///
/// - parameter baseURL: URL of the directory itself.
/// - parameter fileURLs: Array of URLs to return, or nil to throw an error.
fileprivate func createDirectoryStub(
    baseURL: URL = URL(fileURLWithPath: "irrelevant"),
    fileURLs: [URL]? = []) -> LogDirectory {

    return LogDirectory(
        url: baseURL,
        inspector: DirectoryInspectorStub(urls: fileURLs))!
}

fileprivate class DirectoryInspectorStub: DirectoryInspector {
    var urls: [URL]?

    init(urls: [URL]?) {
        self.urls = urls
    }

    func directoryExists(at url: URL) -> Bool {
        return true
    }

    func filesInDirectory(at url: URL) throws -> [URL] {
        guard let fileURLs = urls else {
            throw "some error"
        }

        return fileURLs
    }

    func addIfNotExists(url: URL) {
        guard let existingURLs = urls,
            !existingURLs.contains(url)
            else { return }
        urls?.append(url)
    }

    func remove(urls removedURLs: [URL]) {
        for url in removedURLs {
            if let index = urls?.index(where: { $0 == url }) {
                urls?.remove(at: index)
            }
        }
    }
}

class RotatingFileDestinationIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        SwiftyBeaver.removeAllDestinations()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testRotatingFilesAreWritten() {
        let log = SwiftyBeaver.self
        let clockDouble = ClockDouble(year: 2014, month: 6, day: 2)
        let rotatingDestination = RotatingFileDestination(
            rotation: .daily,
            deletionPolicy: .quantity(keep: 2),
            logDirectory: LogDirectory(url: createTempDirectory()),
            fileName: .init(name: "the", pathExtension: "log"),
            clock: clockDouble)
        rotatingDestination.format = "$L: $M"
        _ = log.addDestination(rotatingDestination)

        // First rotation

        log.verbose("first line to log")
        log.debug("second line to log")
        log.info("third line to log")
        _ = log.flush(secondTimeout: 3)

        waitForFilesToBeWritten()

        guard let firstPath = rotatingDestination.currentURL?.path else {
            XCTFail("Expected first log file's path")
            return
        }

        do {
            let fileLines = linesOfFile(path: firstPath)
            XCTAssertNotNil(fileLines)
            guard let lines = fileLines else { return }
            XCTAssertEqual(lines.count, 4)
            XCTAssertEqual(lines[safe: 0], "VERBOSE: first line to log")
            XCTAssertEqual(lines[safe: 1], "DEBUG: second line to log")
            XCTAssertEqual(lines[safe: 2], "INFO: third line to log")
            XCTAssertEqual(lines[safe: 3], "")
        }

        // Second rotation

        clockDouble.changeDate(year: 2014, month: 6, day: 3)

        log.info("single line to log")
        _ = log.flush(secondTimeout: 3)

        waitForFilesToBeWritten()

        guard let secondPath = rotatingDestination.currentURL?.path else {
            XCTFail("Expected second log file's path")
            return
        }

        do {
            // Old file is untouched
            let fileLines = linesOfFile(path: firstPath)
            XCTAssertNotNil(fileLines)
            guard let lines = fileLines else { return }
            XCTAssertEqual(lines.count, 4)
            XCTAssertEqual(lines[safe: 0], "VERBOSE: first line to log")
            XCTAssertEqual(lines[safe: 1], "DEBUG: second line to log")
            XCTAssertEqual(lines[safe: 2], "INFO: third line to log")
            XCTAssertEqual(lines[safe: 3], "")
        }

        do {
            let fileLines = linesOfFile(path: secondPath)
            XCTAssertNotNil(fileLines)
            guard let lines = fileLines else { return }
            XCTAssertEqual(lines.count, 2)
            XCTAssertEqual(lines[safe: 0], "INFO: single line to log")
            XCTAssertEqual(lines[safe: 1], "")
        }

        // Ooohhh, rewind the clock in the 3rd rotation!

        clockDouble.changeDate(year: 2014, month: 6, day: 2)

        log.info("additional line to log")
        _ = log.flush(secondTimeout: 3)

        waitForFilesToBeWritten()

        do {
            // Old file is untouched
            let fileLines = linesOfFile(path: firstPath)
            XCTAssertNotNil(fileLines)
            guard let lines = fileLines else { return }
            XCTAssertEqual(lines.count, 5)
            XCTAssertEqual(lines[safe: 0], "VERBOSE: first line to log")
            XCTAssertEqual(lines[safe: 1], "DEBUG: second line to log")
            XCTAssertEqual(lines[safe: 2], "INFO: third line to log")
            XCTAssertEqual(lines[safe: 3], "INFO: additional line to log")
            XCTAssertEqual(lines[safe: 4], "")
        }

        do {
            let fileLines = linesOfFile(path: secondPath)
            XCTAssertNotNil(fileLines)
            guard let lines = fileLines else { return }
            XCTAssertEqual(lines.count, 2)
            XCTAssertEqual(lines[safe: 0], "INFO: single line to log")
            XCTAssertEqual(lines[safe: 1], "")
        }

        // Fourth rotation, creating a 3rd file, triggering the deletion policy

        clockDouble.changeDate(year: 2014, month: 6, day: 4)

        log.verbose("new file started")
        log.debug("interesting stuff to log")
        _ = log.flush(secondTimeout: 3)

        waitForFilesToBeWritten()

        guard let thirdPath = rotatingDestination.currentURL?.path else {
            XCTFail("Expected third log file's path")
            return
        }

        do {
            // First file is removed
            XCTAssertFalse(FileManager.default.fileExists(atPath: firstPath))
        }

        do {
            // Second file is untouched
            let fileLines = linesOfFile(path: secondPath)
            XCTAssertNotNil(fileLines)
            guard let lines = fileLines else { return }
            XCTAssertEqual(lines.count, 2)
            XCTAssertEqual(lines[safe: 0], "INFO: single line to log")
            XCTAssertEqual(lines[safe: 1], "")
        }

        do {
            // Third file is new
            let fileLines = linesOfFile(path: thirdPath)
            XCTAssertNotNil(fileLines)
            guard let lines = fileLines else { return }
            XCTAssertEqual(lines.count, 3)
            XCTAssertEqual(lines[safe: 0], "VERBOSE: new file started")
            XCTAssertEqual(lines[safe: 1], "DEBUG: interesting stuff to log")
            XCTAssertEqual(lines[safe: 2], "")
        }
    }
}

fileprivate extension Collection {
    subscript (safe index: Self.Index) -> Self.Iterator.Element? {
        return index < endIndex ? self[index] : nil
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

/// Use to override the internal factories.
fileprivate class MockFactoryRotatingFileDestination: RotatingFileDestination {
    /// Sets up `testFileDestination` before `super.init` sets up its own
    /// through the settings's `didSet` property observers.
    required init(testFileDestination: FileDestination) {
        self.testFileDestination = testFileDestination
        // Initializer parameters are irrelevant:
        let directoryStub = createDirectoryStub(fileURLs: [])
        super.init(
            rotation: .daily,
            deletionPolicy: .quantity(keep: 5),
            logDirectory: directoryStub,
            fileName: .init(name: "irrelevant", pathExtension: "irrelevant"),
            clock: ClockDouble(date: Date(timeIntervalSinceReferenceDate: 12345)))
    }

    var testFileDestination: FileDestination?
    override func currentFileDestination() -> FileDestination {
        return testFileDestination ?? super.currentFileDestination()
    }
}

fileprivate class FileDestinationSendingMock: FileDestination {
    var testSendResult: String?
    var didSend: (level: SwiftyBeaver.Level, msg: String, thread: String, file: String, function: String, line: Int, context: Any?)?
    override func send(_ level: SwiftyBeaver.Level, msg: String, thread: String, file: String, function: String, line: Int, context: Any?) -> String? {
        didSend = (level, msg, thread, file, function, line, context)
        return testSendResult
    }
}

fileprivate class FileDestinationSettingForwardingMock: FileDestination {
    override init() {
        // Main initializer applies default settings, so reset `didForward` afterwards
        super.init()
        didForward = false
    }
    var didForward = false

    override var format: String { didSet { didForward = true } }
    override var reset: String  { didSet { didForward = true } }
    override var escape: String { didSet { didForward = true } }
    override var asynchronously: Bool  { didSet { didForward = true } }
    override var filters: [FilterType] { didSet { didForward = true } }
    override var minLevel: SwiftyBeaver.Level { didSet { didForward = true } }
    override var levelString: BaseDestination.LevelString { didSet { didForward = true } }
    override var levelColor: BaseDestination.LevelColor   { didSet { didForward = true } }
}

fileprivate class LogFileRemovalDouble: RemoveLogFiles {
    var removedLogFiles: [URL] = []
    func removeLogFile(at url: URL) throws {
        removedLogFiles.append(url)
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

