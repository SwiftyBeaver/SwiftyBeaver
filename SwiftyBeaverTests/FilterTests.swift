//
// Created by Jeff Roberts on 6/1/16.
// Copyright (c) 2016 Sebastian Kreutzberger. All rights reserved.
//

import Foundation
import XCTest
@testable import SwiftyBeaver

class FilterTests: XCTestCase {
    //
    // Logging Level filter tests
    //
    func test_level_atLeast_isRequiredFilter() {
        let filter = Filters.Level.atLeast(level:.Debug)
        XCTAssertTrue(filter.isRequired())
    }

    func test_level_getTarget_isLogLevelFilter() {
        let filter = Filters.Level.atLeast(level:.Debug)
        let isCorrectTargetType: Bool
        switch filter.getTarget() {
            case .LogLevel(_):
                isCorrectTargetType = true

            default:
                isCorrectTargetType = false
        }
        XCTAssertTrue(isCorrectTargetType)
    }

    func test_level_loggedLevelIsGreaterThanFilter_answersTrue() {
        let filter = Filters.Level.atLeast(level:.Info)
        let logLevel = SwiftyBeaver.Level.Warning
        XCTAssertTrue(filter.apply(value: logLevel.rawValue))
    }

    func test_level_loggedLevelIsEqualFilter_answersTrue() {
        let filter = Filters.Level.atLeast(level:.Info)
        let logLevel = SwiftyBeaver.Level.Info
        XCTAssertTrue(filter.apply(value: logLevel.rawValue))
    }

    func test_level_loggedLevelIsLessThanFilter_answersFalse() {
        let filter = Filters.Level.atLeast(level:.Info)
        let logLevel = SwiftyBeaver.Level.Debug
        XCTAssertFalse(filter.apply(value: logLevel.rawValue))
    }

    //
    // Path filtering tests (identity)
    //
    func test_path_getTarget_isPathFilter() {
        let filter = Filters.Path.startsWith(prefixes: "/some/path")
        let isCorrectTargetType: Bool
        switch filter.getTarget() {
        case .Path(_):
            isCorrectTargetType = true

        default:
            isCorrectTargetType = false
        }
        XCTAssertTrue(isCorrectTargetType)
    }

    //
    // Path filtering tests (isRequired)
    //
    func test_path_startsWithAndIsRequired_isRequiredFilter() {
        let filter = Filters.Path.startsWith(prefixes: "/some/path", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_path_containsAndIsRequired_isRequiredFilter() {
        let filter = Filters.Path.contains(strings: "/some/path", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_path_endsWithAndIsRequired_isRequiredFilter() {
        let filter = Filters.Path.endsWith(suffixes: "/some/path", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_path_equalsAndIsRequired_isRequiredFilter() {
        let filter = Filters.Path.equals(strings: "/some/path", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_path_startsWithAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Path.startsWith(prefixes: "/some/path", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_path_containsAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Path.contains(strings: "/some/path", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_path_endsWithAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Path.endsWith(suffixes: "/some/path", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_path_equalsAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Path.equals(strings: "/some/path", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    //
    // Path filtering tests (case sensitivity)
    //
    func test_path_startsWithAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Path.startsWith(prefixes: "/some/path", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(targetType: filter.getTarget()))
    }

    func test_path_containsAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Path.contains(strings: "/some/path", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(targetType: filter.getTarget()))
    }

    func test_path_endsWithAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Path.endsWith(suffixes: "/some/path", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(targetType: filter.getTarget()))
    }

    func test_path_equalsAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Path.equals(strings: "/some/path", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(targetType: filter.getTarget()))
    }

    func test_path_startsWithAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Path.startsWith(prefixes: "/some/path", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(targetType: filter.getTarget()))
    }

    func test_path_containsAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Path.contains(strings: "/some/path", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(targetType: filter.getTarget()))
    }

    func test_path_endsWithAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Path.endsWith(suffixes: "/some/path", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(targetType: filter.getTarget()))
    }

    func test_path_equalsAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Path.equals(strings: "/some/path", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(targetType: filter.getTarget()))
    }

    //
    // Path filtering tests (comparison testing)
    //
    func test_pathStartsWith_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.startsWith(prefixes: "/first", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "/first/path/to/anywhere"))
    }

    func test_pathStartsWith_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.startsWith(prefixes: "/First", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "/first/path/to/anywhere"))
    }

    func test_pathStartsWith_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Path.startsWith(prefixes: "/First", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "/first/path/to/anywhere"))
    }

    func test_pathStartsWith_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.startsWith(prefixes: "/first", "/second", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "/second/path/to/anywhere"))
    }

    func test_pathStartsWith_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.startsWith(prefixes: "/First", "/Second", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "/second/path/to/anywhere"))
    }

    func test_pathStartsWith_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Path.startsWith(prefixes: "/First", "/Second", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "/second/path/to/anywhere"))
    }

    func test_pathContains_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.contains(strings: "/path", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "/first/path/to/anywhere"))
    }

    func test_pathContains_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.contains(strings: "/Path", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "/first/path/to/anywhere"))
    }

    func test_pathContains_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Path.contains(strings: "/Path", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "/first/path/to/anywhere"))
    }

    func test_pathContains_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.contains(strings: "/pathway", "/path", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "/first/path/to/anywhere"))
    }

    func test_pathContains_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.contains(strings: "/Pathway", "/Path", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "/first/path/to/anywhere"))
    }

    func test_pathContains_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Path.contains(strings: "/Pathway", "/Path", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "/first/path/to/anywhere"))
    }

    func test_pathEndsWith_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.endsWith(suffixes: "/anywhere", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "/first/path/to/anywhere"))
    }

    func test_pathEndsWith_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.endsWith(suffixes: "/Anywhere", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "/first/path/to/anywhere"))
    }

    func test_pathEndsWith_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Path.endsWith(suffixes: "/Anywhere", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "/first/path/to/anywhere"))
    }

    func test_pathEndsWith_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.endsWith(suffixes: "/nowhere", "/anywhere", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "/first/path/to/anywhere"))
    }

    func test_pathEndsWith_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.endsWith(suffixes: "/Nowhere", "/Anywhere", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "/first/path/to/anywhere"))
    }

    func test_pathEndsWith_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Path.endsWith(suffixes: "/Nowhere", "/Anywhere", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "/first/path/to/anywhere"))
    }

    func test_pathEquals_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.equals(strings: "/first/path/to/anywhere", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "/first/path/to/anywhere"))
    }

    func test_pathEquals_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.equals(strings: "/First/path/to/Anywhere", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "/first/path/to/anywhere"))
    }

    func test_pathEquals_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Path.equals(strings: "/First/path/to/Anywhere", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "/first/path/to/anywhere"))
    }

    func test_pathEquals_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.equals(strings: "/second/path/to/anywhere",
                                         "/first/path/to/anywhere", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "/first/path/to/anywhere"))
    }

    func test_pathEquals_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.equals(strings: "/Second/path/to/nowhere",
                                         "/First/Path/To/Anywhere", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "/first/path/to/anywhere"))
    }

    func test_pathEquals_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Path.equals(strings: "/Second/path/to/anywhere",
                                         "/First/path/to/Anywhere", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "/first/path/to/anywhere"))
    }

    //
    // Function filtering tests (identity)
    //
    func test_function_getTarget_isFunctionFilter() {
        let filter = Filters.Function.startsWith(prefixes: "myFunc")
        let isCorrectTargetType: Bool
        switch filter.getTarget() {
        case .Function(_):
            isCorrectTargetType = true

        default:
            isCorrectTargetType = false
        }
        XCTAssertTrue(isCorrectTargetType)
    }

    //
    // Function filtering tests (isRequired)
    //
    func test_function_startsWithAndIsRequired_isRequiredFilter() {
        let filter = Filters.Function.startsWith(prefixes: "myFunc", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_function_containsAndIsRequired_isRequiredFilter() {
        let filter = Filters.Function.contains(strings: "myFunc", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_function_endsWithAndIsRequired_isRequiredFilter() {
        let filter = Filters.Function.endsWith(suffixes: "myFunc", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_function_equalsAndIsRequired_isRequiredFilter() {
        let filter = Filters.Function.equals(strings: "myFunc", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_function_startsWithAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Function.startsWith(prefixes: "myFunc", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_function_containsAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Function.contains(strings: "myFunc", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_function_endsWithAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Function.endsWith(suffixes: "myFunc", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_function_equalsAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Function.equals(strings: "myFunc", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    //
    // Function filtering tests (case sensitivity)
    //
    func test_function_startsWithAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Function.startsWith(prefixes: "myFunc", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(targetType: filter.getTarget()))
    }

    func test_function_containsAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Function.contains(strings: "myFunc", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(targetType: filter.getTarget()))
    }

    func test_function_endsWithAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Function.endsWith(suffixes: "myFunc", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(targetType: filter.getTarget()))
    }

    func test_function_startsWithAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Function.startsWith(prefixes: "myFunc", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(targetType: filter.getTarget()))
    }

    func test_function_containsAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Function.contains(strings: "myFunc", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(targetType: filter.getTarget()))
    }

    func test_function_endsWithAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Function.endsWith(suffixes: "myFunc", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(targetType: filter.getTarget()))
    }

    //
    // Function filtering tests (comparison testing)
    //
    func test_functionStartsWith_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.startsWith(prefixes: "myFunc", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "myFunction"))
    }

    func test_functionStartsWith_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.startsWith(prefixes: "MyFunc", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "myFunc"))
    }

    func test_functionStartsWith_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Function.startsWith(prefixes: "MyFunc", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "myFunc"))
    }

    func test_functionStartsWith_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.startsWith(prefixes: "yourFunc", "myFunc", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "myFunc"))
    }

    func test_functionStartsWith_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.startsWith(prefixes: "YourFunc", "MyFunc", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "myFunc"))
    }

    func test_functionStartsWith_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Function.startsWith(prefixes: "YourFunc", "MyFunc", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "myFunc"))
    }

    func test_functionContains_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.contains(strings: "Func", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "myFunc"))
    }

    func test_functionContains_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.contains(strings: "Func", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "myfunc"))
    }

    func test_functionContains_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Function.contains(strings: "Func", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "myfunc"))
    }

    func test_functionContains_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.contains(strings: "doSomething", "Func", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "myFunc"))
    }

    func test_functionContains_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.contains(strings: "DoSomething", "func", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "myFunc"))
    }

    func test_functionContains_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Function.contains(strings: "DoSomething", "Func", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "myfunc"))
    }

    func test_functionEndsWith_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.endsWith(suffixes: "Func", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "myFunc"))
    }

    func test_functionEndsWith_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.endsWith(suffixes: "Func", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "myfunc"))
    }

    func test_functionEndsWith_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Function.endsWith(suffixes: "Func", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "myfunc"))
    }

    func test_functionEndsWith_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.endsWith(suffixes: "doSomething", "Func", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "myFunc"))
    }

    func test_functionEndsWith_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.endsWith(suffixes: "DoSomething", "Func", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "myfunc"))
    }

    func test_functionEndsWith_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Function.endsWith(suffixes: "DoSomething", "Func", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "myfunc"))
    }

    func test_functionEquals_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.equals(strings: "myFunc", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "myFunc"))
    }

    func test_functionEquals_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.equals(strings: "myFunc", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "myfunc"))
    }

    func test_functionEquals_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Function.equals(strings: "myFunc", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "myfunc"))
    }

    func test_functionEquals_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.equals(strings: "yourFunc", "myFunc", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "myFunc"))
    }

    func test_functionEquals_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.equals(strings: "yourFunc", "myFunc", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "myFunc"))
    }

    func test_functionEquals_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Function.equals(strings: "yourFunc", "myFunc", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "myfunc"))
    }

    //
    // Message filtering tests (identity)
    //
    func test_message_getTarget_isMessageFilter() {
        let filter = Filters.Message.startsWith(prefixes: "Hello there, SwiftyBeaver!")
        let isCorrectTargetType: Bool
        switch filter.getTarget() {
        case .Message(_):
            isCorrectTargetType = true

        default:
            isCorrectTargetType = false
        }
        XCTAssertTrue(isCorrectTargetType)
    }

    //
    // Message filtering tests (isRequired)
    //
    func test_message_startsWithAndIsRequired_isRequiredFilter() {
        let filter = Filters.Message.startsWith(prefixes: "Hello", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_message_containsAndIsRequired_isRequiredFilter() {
        let filter = Filters.Message.contains(strings: "there", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_message_endsWithAndIsRequired_isRequiredFilter() {
        let filter = Filters.Message.endsWith(suffixes: "SwifyBeaver!", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_message_equalsAndIsRequired_isRequiredFilter() {
        let filter = Filters.Message.equals(strings: "SwifyBeaver!", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_message_startsWithAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Message.startsWith(prefixes: "Hello", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_message_containsAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Message.contains(strings: "there", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_message_endsWithAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Message.endsWith(suffixes: "SwiftyBeaver!", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_message_equalsAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Message.equals(strings: "SwiftyBeaver!", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    //
    // Message filtering tests (case sensitivity)
    //
    func test_message_startsWithAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Message.startsWith(prefixes: "Hello", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(targetType: filter.getTarget()))
    }

    func test_message_containsAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Message.contains(strings: "there", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(targetType: filter.getTarget()))
    }

    func test_message_endsWithAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Message.endsWith(suffixes: "SwiftyBeaver!", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(targetType: filter.getTarget()))
    }

    func test_message_equalsAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Message.equals(strings: "SwiftyBeaver!", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(targetType: filter.getTarget()))
    }

    func test_message_startsWithAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Message.startsWith(prefixes: "Hello", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(targetType: filter.getTarget()))
    }

    func test_message_containsAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Message.contains(strings: "there", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(targetType: filter.getTarget()))
    }

    func test_message_endsWithAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Message.endsWith(suffixes: "SwiftyBeaver!", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(targetType: filter.getTarget()))
    }

    func test_message_equalsAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Message.equals(strings: "SwiftyBeaver!", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(targetType: filter.getTarget()))
    }

    //
    // Function filtering tests (comparison testing)
    //
    func test_messageStartsWith_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.startsWith(prefixes: "Hello", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageStartsWith_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.startsWith(prefixes: "hello", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageStartsWith_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Message.startsWith(prefixes: "hello", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageStartsWith_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.startsWith(prefixes: "Goodbye", "Hello", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageStartsWith_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.startsWith(prefixes: "goodbye", "hello", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageStartsWith_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Message.startsWith(prefixes: "goodbye", "hello", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageContains_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.contains(strings: "there", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageContains_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.contains(strings: "There", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageContains_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Message.contains(strings: "There", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageContains_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.contains(strings: "their", "there", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageContains_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.contains(strings: "Their", "There", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageContains_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Message.contains(strings: "Their", "There", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageEndsWith_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.endsWith(suffixes: "SwiftyBeaver!", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageEndsWith_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.endsWith(suffixes: "swiftybeaver!", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageEndsWith_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Message.endsWith(suffixes: "swiftybeaver!", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageEndsWith_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.endsWith(suffixes: "SluggishMink!", "SwiftyBeaver!", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageEndsWith_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.endsWith(suffixes: "sluggishmink!", "swiftybeaver!", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageEndsWith_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Message.endsWith(suffixes: "sluggishmink!!", "swiftybeaver!", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageEquals_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.equals(strings: "Hello there, SwiftyBeaver!", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageEquals_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.equals(strings: "hello there, swiftybeaver!", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageEquals_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Message.equals(strings: "hello there, swiftybeaver!", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageEquals_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.equals(strings: "Goodbye, SluggishMink!",
                                            "Hello there, SwiftyBeaver!", caseSensitive: true)
        XCTAssertTrue(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageEquals_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.equals(strings: "goodbye, sluggishmink!",
                                            "hello there, swiftybeaver!", caseSensitive: false)
        XCTAssertTrue(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    func test_messageEquals_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Message.equals(strings: "goodbye, sluggishmink!",
                                            "hello there, swiftybeaver!", caseSensitive: true)
        XCTAssertFalse(filter.apply(value: "Hello there, SwiftyBeaver!"))
    }

    // Helper functions
    private func isCaseSensitive(targetType: Filter.TargetType) -> Bool {
        let comparisonType: Filter.ComparisonType?
        switch targetType {
        case let .Path(type):
            comparisonType = type

        case let .Function(type):
            comparisonType = type

        case let .Message(type):
            comparisonType = type

        default:
            comparisonType = nil
        }

        guard let compareType = comparisonType else {
            return false
        }

        let isCaseSensitive: Bool

        switch compareType {
        case let .Contains(_, caseSensitive):
            isCaseSensitive = caseSensitive

        case let .StartsWith(_, caseSensitive):
            isCaseSensitive = caseSensitive

        case let .EndsWith(_, caseSensitive):
            isCaseSensitive = caseSensitive

        case let .Equals(_, caseSensitive):
            isCaseSensitive = caseSensitive
        }

        return isCaseSensitive
    }

}
