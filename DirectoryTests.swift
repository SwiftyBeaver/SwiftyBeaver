//
//  Created by Christian Tietze (@ctietze) on 2017-12-15.
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import XCTest
@testable import SwiftyBeaver

class DirectoryTests: XCTestCase {

    var irrelevantURL: URL { return URL(fileURLWithPath: "irrelevant") }

    func testInitializer_ChecksURLForBeingADirectory() {
        let inspectorDouble = DirectoryInspectorDouble()
        let url = URL(fileURLWithPath: "the url")

        _ = Directory(url: url, inspector: inspectorDouble)

        XCTAssertEqual(inspectorDouble.didCheckExistence, url)
    }

    func testInitializer_NotADirectoryAtURL_ReturnsNil() {
        let inspectorDouble = DirectoryInspectorDouble()
        inspectorDouble.testDirectoryExists = false
        XCTAssertNil(Directory(url: URL(fileURLWithPath: "new url"), inspector: inspectorDouble))
    }

    func testInitializer_IsADirectoryAtURL_ReturnsInstance() {
        let inspectorDouble = DirectoryInspectorDouble()
        inspectorDouble.testDirectoryExists = true
        let url = URL(fileURLWithPath: "another url")

        let directory = Directory(url: url, inspector: inspectorDouble)

        XCTAssertNotNil(directory)
        XCTAssertEqual(directory?.url, url)
        XCTAssert(directory?.inspector === inspectorDouble)
    }

    func testFileURLs_RequestsFilesFromInspector() {
        let inspectorDouble = DirectoryInspectorDouble()
        inspectorDouble.testDirectoryExists = true
        let url = URL(fileURLWithPath: "directory URL")

        guard let directory = Directory(url: url, inspector: inspectorDouble) else { XCTFail("Expected directory"); return }

        do {
            _ = try directory.fileURLs(sortedBy: .fileName)
        } catch {
            XCTFail("Expected success")
        }
        XCTAssertEqual(inspectorDouble.didRequestsFilesInDirectory, url)
    }

    func testFileURLs_InspectorThrows_Rethrows() {
        let inspectorDouble = DirectoryInspectorDouble()
        inspectorDouble.testDirectoryExists = true
        let irrelevantURL = URL(fileURLWithPath: "irrelevant")

        guard let directory = Directory(url: irrelevantURL, inspector: inspectorDouble) else { XCTFail("Expected directory"); return }

        do {
            inspectorDouble.filesInDirectoryError = "the error"
            _ = try directory.fileURLs(sortedBy: .fileName)
            XCTFail("Expected error")
        } catch let error as String {
            XCTAssertEqual(error, "the error")
        } catch {
            XCTFail("Expected different kind of error")
        }
    }

    func testFileURLs_InspectorReturnsEmptyArray_ReturnsEmptyArray() {
        let inspectorDouble = DirectoryInspectorDouble()
        inspectorDouble.testDirectoryExists = true

        guard let directory = Directory(url: irrelevantURL, inspector: inspectorDouble) else { XCTFail("Expected directory"); return }

        let result: [URL]

        do {
            inspectorDouble.filesInDirectoryError = nil
            inspectorDouble.testFiles = []
            result = try directory.fileURLs(sortedBy: .fileName)
        } catch {
            XCTFail("Expected success")
            return
        }

        XCTAssert(result.isEmpty)
    }

    func testFileURLs_InspectorReturnsFileURLs_SortedByFileName_ReturnsSortedArray() {
        let inspectorDouble = DirectoryInspectorDouble()
        inspectorDouble.testDirectoryExists = true

        guard let directory = Directory(url: irrelevantURL, inspector: inspectorDouble) else { XCTFail("Expected directory"); return }

        let result: [URL]

        do {
            inspectorDouble.filesInDirectoryError = nil
            inspectorDouble.testFiles = [
                URL(fileURLWithPath: "/somewhere/file 3.txt"),
                URL(fileURLWithPath: "/irrelevant/path/file 1.txt"),
                URL(fileURLWithPath: "/file 2.txt")
            ]
            result = try directory.fileURLs(sortedBy: .fileName)
        } catch {
            XCTFail("Expected success")
            return
        }

        XCTAssertEqual(result, [
             URL(fileURLWithPath: "/irrelevant/path/file 1.txt"),
             URL(fileURLWithPath: "/file 2.txt"),
             URL(fileURLWithPath: "/somewhere/file 3.txt")
            ])
    }

}

// Allows to throw string literals
extension String: Error { }

fileprivate class DirectoryInspectorDouble: DirectoryInspector {
    var didCheckExistence: URL?
    var testDirectoryExists = false
    func directoryExists(at url: URL) -> Bool {
        didCheckExistence = url
        return testDirectoryExists
    }

    var didRequestsFilesInDirectory: URL?
    var testFiles: [URL] = []
    var filesInDirectoryError: Error?
    func filesInDirectory(at url: URL) throws -> [URL] {
        didRequestsFilesInDirectory = url
        if let filesInDirectoryError = filesInDirectoryError {
            throw filesInDirectoryError
        }
        return testFiles
    }
}

class FileManager_DirectoryInspectorTests: XCTestCase {

    func testExistence_NonExistingFile() {
        let url = generatedTempFileURL()
        XCTAssertFalse(FileManager.default.directoryExists(at: url))
    }

    func testExistence_ExistingFile() {
        let fileURL = createTempFileURL()
        XCTAssertFalse(FileManager.default.directoryExists(at: fileURL))
    }

    func testExistence_ExistingDirectory() {
        let url = createTempDirectory()
        XCTAssertTrue(FileManager.default.directoryExists(at: url))
    }

    func testFilesInDirectory_NonexistingURL_Throws() {

        let url = generatedTempFileURL()

        do {
            _ = try FileManager.default.filesInDirectory(at: url)
            XCTFail("expected to throw")
        } catch let error as DirectoryError {
            XCTAssertEqual(error, DirectoryError.notADirectory(url))
        } catch {
            XCTFail("wrong kind of error")
        }
    }

    func testFilesInDirectory_FileAtURL_Throws() {

        let url = createTempFileURL()

        do {
            _ = try FileManager.default.filesInDirectory(at: url)
            XCTFail("expected to throw")
        } catch let error as DirectoryError {
            XCTAssertEqual(error, DirectoryError.notADirectory(url))
        } catch {
            XCTFail("wrong kind of error")
        }
    }

    func testFilesInDirectory_EmptyDirectory_ReturnsEmptyArray() {

        let url = createTempDirectory()

        let results: [URL]
        do {
            results = try FileManager.default.filesInDirectory(at: url)
        } catch {
            XCTFail("Expected no error but got: \(error)")
            return
        }

        XCTAssert(results.isEmpty)
    }

    func testFilesInDirectory_WithFilesInDirectory_ReturnsURLs() {

        let directoryUrl = createTempDirectory()
        let firstFileUrl = directoryUrl.appendingPathComponent("file1")
        let secondFileUrl = directoryUrl.appendingPathComponent("file2")
        createFile(url: firstFileUrl)
        createFile(url: secondFileUrl)

        let results: [URL]
        do {
            results = try FileManager.default.filesInDirectory(at: directoryUrl)
        } catch {
            XCTFail("Expected no error but got: \(error)")
            return
        }

        // Making sure that the /var/ and /private/var/ aliases are irrelevant:
        let fileURLs = results.map({ $0.resolvingSymlinksInPath() })
        XCTAssertEqual(fileURLs.count, 2)
        XCTAssert(fileURLs.contains(firstFileUrl))
        XCTAssert(fileURLs.contains(secondFileUrl))
    }
}
