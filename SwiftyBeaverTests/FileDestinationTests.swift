//
//  FileDestinationTests.swift
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger on 6/21/16.
//  Copyright © 2016 Sebastian Kreutzberger. All rights reserved.
//

import XCTest
@testable import SwiftyBeaver

class FileDestinationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        SwiftyBeaver.removeAllDestinations()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testFileIsWritten() {
        let log = SwiftyBeaver.self

        let path = "/tmp/testSBF.log"
        deleteFile(path)

        // add file
        let file = FileDestination()
        file.logFileURL = NSURL(string: "file://" + path)!
        file.detailOutput = false
        file.dateFormat = ""
        file.colored = false
        log.addDestination(file)

        log.verbose("first line to log")
        log.debug("second line to log")
        log.info("third line to log")
        log.flush(3)

        // was the file written and does it contain the lines?
        let fileLines = self.linesOfFile(path)
        XCTAssertNotNil(fileLines)
        guard let lines = fileLines else { return }
        XCTAssertEqual(lines.count, 4)
        XCTAssertEqual(lines[0], "VERBOSE: first line to log")
        XCTAssertEqual(lines[1], "DEBUG: second line to log")
        XCTAssertEqual(lines[2], "INFO: third line to log")
        XCTAssertEqual(lines[3], "")
    }


    func testFileIsWrittenToFolderWithSpaces() {
        let log = SwiftyBeaver.self

        let folder = "/tmp/folder with spaces"
        createFolder(folder)

        let path = folder + "/testSBF.log"
        deleteFile(path)

        // in conversion from path String to NSURL you need to replace " " with "%20"
        let pathReadyForURL = path.stringByReplacingOccurrencesOfString(" ", withString: "%20")
        let fileURL = NSURL(string: "file://" + pathReadyForURL)
        XCTAssertNotNil(fileURL)
        guard let url = fileURL else { return }

        // add file
        let file = FileDestination()
        file.logFileURL = url
        file.detailOutput = false
        file.dateFormat = ""
        file.colored = false
        log.addDestination(file)

        log.verbose("first line to log")
        log.debug("second line to log")
        log.info("third line to log")
        log.flush(3)

        // was the file written and does it contain the lines?
        let fileLines = self.linesOfFile(path)
        XCTAssertNotNil(fileLines)
        guard let lines = fileLines else { return }
        XCTAssertEqual(lines.count, 4)
        XCTAssertEqual(lines[0], "VERBOSE: first line to log")
        XCTAssertEqual(lines[1], "DEBUG: second line to log")
        XCTAssertEqual(lines[2], "INFO: third line to log")
        XCTAssertEqual(lines[3], "")
    }


    // MARK: Helper Functions

    // deletes a file if it is existing
    func deleteFile(path: String) {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(path)
        } catch {}
    }

    // returns the lines of a file as optional array which is nil on error
    func linesOfFile(path: String) -> [String]? {
        do {
            // try to read file
            let fileContent = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            return fileContent.componentsSeparatedByString("\n")
        } catch let error {
            print(error)
            return nil
        }
    }

    // creates a folder if not already existing
    func createFolder(path: String) {
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(path,
                        withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Unable to create directory \(error.debugDescription)")
        }
    }
}
