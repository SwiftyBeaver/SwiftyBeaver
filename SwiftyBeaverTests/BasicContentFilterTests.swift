//
// Created by Jeff Roberts on 5/30/16.
// Copyright (c) 2016 Sebastian Kreutzberger. All rights reserved.
//

import Foundation
import XCTest
@testable import SwiftyBeaver

class BasicContentFilterTests : XCTestCase {
    private var contentFilter : BasicContentFilter!

    override func setUp() {
        super.setUp()
        contentFilter = BasicContentFilter()
    }

    func test_apply_noComparisonCriteria_answersTrue() {
        XCTAssertTrue(contentFilter.apply("Some simple message"))
    }

    func test_apply_oneBeginsWithThatMatches_answersTrue() {
        contentFilter?.beginsWith("Some")
        XCTAssertTrue(contentFilter.apply("Some simple message"))
    }

    func test_apply_oneBeginsWithThatDoesNotMatch_answersFalse() {
        contentFilter?.beginsWith("some")
        XCTAssertFalse(contentFilter.apply("Some simple message"))
    }

    func test_apply_multipleBeginsWithThatDoesNotMatch_answersFalse() {
        contentFilter?.beginsWith("one", "two", "three")
        XCTAssertFalse(contentFilter.apply("Some simple message"))
    }

    func test_apply_multipleBeginsWithThatMatches_answersTrue() {
        contentFilter?.beginsWith("some", "one", "two", "three", "Some")
        XCTAssertTrue(contentFilter.apply("Some simple message"))
    }

    func test_apply_oneContainsThatMatches_answersTrue() {
        contentFilter?.contains("simple")
        XCTAssertTrue(contentFilter.apply("Some simple message"))
    }

    func test_apply_oneContainsThatDoesNotMatch_answersFalse() {
        contentFilter?.contains("complex")
        XCTAssertFalse(contentFilter.apply("Some simple message"))
    }

    func test_apply_multipleContainsThatDoesNotMatch_answersFalse() {
        contentFilter?.contains("complex", "very complex", "not simple")
        XCTAssertFalse(contentFilter.apply("Some simple message"))
    }

    func test_apply_multipleContainsThatMatches_answersTrue() {
        contentFilter?.contains("complex", "very complex", "not simple", "Simple", "simple")
        XCTAssertTrue(contentFilter.apply("Some simple message"))
    }

    func test_apply_oneEndsWithThatMatches_answersTrue() {
        contentFilter?.endsWith("message")
        XCTAssertTrue(contentFilter.apply("Some simple message"))
    }

    func test_apply_oneEndsWithThatDoesNotMatch_answersFalse() {
        contentFilter?.endsWith("massage")
        XCTAssertFalse(contentFilter.apply("Some simple message"))
    }

    func test_apply_multipleEndsWithThatDoesNotMatch_answersFalse() {
        contentFilter?.endsWith("text message", "phone message", "Message", "messages")
        XCTAssertFalse(contentFilter.apply("Some simple message"))
    }

    func test_apply_multipleEndsWithThatMatches_answersTrue() {
        contentFilter?.endsWith("text message", "phone message", "Message", "messages", "message")
        XCTAssertTrue(contentFilter.apply("Some simple message"))
    }

    func test_apply_oneOfEach_noneOfWhichMatch_answersFalse() {
        contentFilter?.endsWith("hello").contains("world").endsWith("goodbye")
        XCTAssertFalse(contentFilter.apply("Some simple message"))
    }

    func test_apply_oneOfEach_oneOfWhichMatches_answersTrue() {
        contentFilter?.endsWith("hello").contains("world").endsWith("message")
        XCTAssertTrue(contentFilter.apply("Some simple message"))
    }

}