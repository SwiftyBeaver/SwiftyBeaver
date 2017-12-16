//
//  Created by Christian Tietze (@ctietze) on 2017-12-14.
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import XCTest
@testable import SwiftyBeaver

class FileManager_RemoveLogFilesTests: XCTestCase {

    func testRemove_FileDoesNotExists_RethrowsError() {
        let url = generatedTempFileURL()
        do {
            try FileManager.default.removeLogFile(at: url)
        } catch let error as LogFileRemovalError {
            switch error {
            case let .trashingFailed(errorURL, wrapping: _):
                XCTAssertEqual(errorURL, url)
            default:
                XCTFail("Expected .trashingFailed on Mac")
            }
        } catch {
            XCTFail("Expected LogFileRemovalError")
        }
    }

    func testRemove_FileExists_RemovesFileFromSourceLocation() {
        let url = createTempFileURL()
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))

        do {
            try FileManager.default.removeLogFile(at: url)
        } catch {
            XCTFail("Expected no errors")
        }

        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
    }
}
