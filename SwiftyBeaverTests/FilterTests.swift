//
// Created by Jeff Roberts on 6/1/16.
// Copyright (c) 2016 Sebastian Kreutzberger. All rights reserved.
//

import Foundation
import XCTest
@testable import SwiftyBeaver

class FilterTests: XCTestCase {

    //
    // Path filtering tests (identity)
    //
    func test_path_getTarget_isPathFilter() {
        let filter = Filters.Path.startsWith("/some/path")
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
        let filter = Filters.Path.startsWith("/some/path", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_path_containsAndIsRequired_isRequiredFilter() {
        let filter = Filters.Path.contains("/some/path", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_path_excludesAndIsRequired_isRequiredFilter() {
        let filter = Filters.Path.excludes("/some/path", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_path_endsWithAndIsRequired_isRequiredFilter() {
        let filter = Filters.Path.endsWith("/some/path", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_path_equalsAndIsRequired_isRequiredFilter() {
        let filter = Filters.Path.equals("/some/path", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_path_startsWithAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Path.startsWith("/some/path", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_path_containsAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Path.contains("/some/path", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_path_excludesAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Path.excludes("/some/path", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_path_endsWithAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Path.endsWith("/some/path", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_path_equalsAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Path.equals("/some/path", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    //
    // Path filtering tests (case sensitivity)
    //
    func test_path_startsWithAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Path.startsWith("/some/path", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(filter.getTarget()))
    }

    func test_path_containsAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Path.contains("/some/path", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(filter.getTarget()))
    }

    func test_path_excludesAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Path.excludes("/some/path", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(filter.getTarget()))
    }

    func test_path_endsWithAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Path.endsWith("/some/path", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(filter.getTarget()))
    }

    func test_path_equalsAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Path.equals("/some/path", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(filter.getTarget()))
    }

    func test_path_startsWithAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Path.startsWith("/some/path", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(filter.getTarget()))
    }

    func test_path_containsAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Path.contains("/some/path", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(filter.getTarget()))
    }

    func test_path_excludesAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Path.excludes("/some/path", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(filter.getTarget()))
    }

    func test_path_endsWithAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Path.endsWith("/some/path", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(filter.getTarget()))
    }

    func test_path_equalsAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Path.equals("/some/path", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(filter.getTarget()))
    }

    //
    // Path filtering tests (comparison testing)
    //
    func test_pathStartsWith_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.startsWith("/first", caseSensitive: true)
        XCTAssertTrue(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathStartsWith_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.startsWith("/First", caseSensitive: false)
        XCTAssertTrue(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathStartsWith_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Path.startsWith("/First", caseSensitive: true)
        XCTAssertFalse(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathStartsWith_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.startsWith("/first", "/second", caseSensitive: true)
        XCTAssertTrue(filter.apply("/second/path/to/anywhere"))
    }

    func test_pathStartsWith_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.startsWith("/First", "/Second", caseSensitive: false)
        XCTAssertTrue(filter.apply("/second/path/to/anywhere"))
    }

    func test_pathStartsWith_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Path.startsWith("/First", "/Second", caseSensitive: true)
        XCTAssertFalse(filter.apply("/second/path/to/anywhere"))
    }

    func test_pathContains_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.contains("/path", caseSensitive: true)
        XCTAssertTrue(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathContains_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.contains("/Path", caseSensitive: false)
        XCTAssertTrue(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathContains_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Path.contains("/Path", caseSensitive: true)
        XCTAssertFalse(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathContains_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.contains("/pathway", "/path", caseSensitive: true)
        XCTAssertTrue(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathContains_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.contains("/Pathway", "/Path", caseSensitive: false)
        XCTAssertTrue(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathContains_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Path.contains("/Pathway", "/Path", caseSensitive: true)
        XCTAssertFalse(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathExcludes_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.excludes("/path", caseSensitive: true)
        XCTAssertTrue(filter.apply("/first/epath/to/anywhere"))
    }

    func test_pathExcludes_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.excludes("/Path", caseSensitive: false)
        XCTAssertTrue(filter.apply("/first/epath/to/anywhere"))
    }

    func test_pathExcludes_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Path.excludes("/Path", caseSensitive: true)
        XCTAssertTrue(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathExcludes_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.excludes("/pathway", "/path", caseSensitive: true)
        XCTAssertTrue(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathExcludes_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.excludes("/Pathway", "/Path", caseSensitive: false)
        XCTAssertTrue(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathExcludes_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Path.excludes("/Pathway", "/Path", caseSensitive: true)
        XCTAssertTrue(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathEndsWith_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.endsWith("/anywhere", caseSensitive: true)
        XCTAssertTrue(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathEndsWith_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.endsWith("/Anywhere", caseSensitive: false)
        XCTAssertTrue(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathEndsWith_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Path.endsWith("/Anywhere", caseSensitive: true)
        XCTAssertFalse(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathEndsWith_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.endsWith("/nowhere", "/anywhere", caseSensitive: true)
        XCTAssertTrue(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathEndsWith_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.endsWith("/Nowhere", "/Anywhere", caseSensitive: false)
        XCTAssertTrue(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathEndsWith_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Path.endsWith("/Nowhere", "/Anywhere", caseSensitive: true)
        XCTAssertFalse(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathEquals_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.equals("/first/path/to/anywhere", caseSensitive: true)
        XCTAssertTrue(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathEquals_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.equals("/First/path/to/Anywhere", caseSensitive: false)
        XCTAssertTrue(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathEquals_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Path.equals("/First/path/to/Anywhere", caseSensitive: true)
        XCTAssertFalse(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathEquals_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.equals("/second/path/to/anywhere", "/first/path/to/anywhere", caseSensitive: true)
        XCTAssertTrue(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathEquals_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Path.equals("/Second/path/to/nowhere", "/First/Path/To/Anywhere", caseSensitive: false)
        XCTAssertTrue(filter.apply("/first/path/to/anywhere"))
    }

    func test_pathEquals_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Path.equals("/Second/path/to/anywhere", "/First/path/to/Anywhere", caseSensitive: true)
        XCTAssertFalse(filter.apply("/first/path/to/anywhere"))
    }

    //
    // Function filtering tests (identity)
    //
    func test_function_getTarget_isFunctionFilter() {
        let filter = Filters.Function.startsWith("myFunc")
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
        let filter = Filters.Function.startsWith("myFunc", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_function_containsAndIsRequired_isRequiredFilter() {
        let filter = Filters.Function.contains("myFunc", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_function_excludesAndIsRequired_isRequiredFilter() {
        let filter = Filters.Function.excludes("myFunc", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_function_endsWithAndIsRequired_isRequiredFilter() {
        let filter = Filters.Function.endsWith("myFunc", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_function_equalsAndIsRequired_isRequiredFilter() {
        let filter = Filters.Function.equals("myFunc", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_function_startsWithAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Function.startsWith("myFunc", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_function_containsAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Function.contains("myFunc", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_function_excludesAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Function.excludes("myFunc", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_function_endsWithAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Function.endsWith("myFunc", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_function_equalsAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Function.equals("myFunc", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    //
    // Function filtering tests (case sensitivity)
    //
    func test_function_startsWithAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Function.startsWith("myFunc", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(filter.getTarget()))
    }

    func test_function_containsAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Function.contains("myFunc", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(filter.getTarget()))
    }

    func test_function_excludesAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Function.excludes("myFunc", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(filter.getTarget()))
    }

    func test_function_endsWithAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Function.endsWith("myFunc", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(filter.getTarget()))
    }

    func test_function_startsWithAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Function.startsWith("myFunc", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(filter.getTarget()))
    }

    func test_function_containsAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Function.contains("myFunc", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(filter.getTarget()))
    }

    func test_function_excludesAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Function.excludes("myFunc", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(filter.getTarget()))
    }

    func test_function_endsWithAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Function.endsWith("myFunc", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(filter.getTarget()))
    }

    //
    // Function filtering tests (comparison testing)
    //
    func test_functionStartsWith_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.startsWith("myFunc", caseSensitive: true)
        XCTAssertTrue(filter.apply("myFunction"))
    }

    func test_functionStartsWith_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.startsWith("MyFunc", caseSensitive: false)
        XCTAssertTrue(filter.apply("myFunc"))
    }

    func test_functionStartsWith_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Function.startsWith("MyFunc", caseSensitive: true)
        XCTAssertFalse(filter.apply("myFunc"))
    }

    func test_functionStartsWith_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.startsWith("yourFunc", "myFunc", caseSensitive: true)
        XCTAssertTrue(filter.apply("myFunc"))
    }

    func test_functionStartsWith_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.startsWith("YourFunc", "MyFunc", caseSensitive: false)
        XCTAssertTrue(filter.apply("myFunc"))
    }

    func test_functionStartsWith_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Function.startsWith("YourFunc", "MyFunc", caseSensitive: true)
        XCTAssertFalse(filter.apply("myFunc"))
    }

    func test_functionContains_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.contains("Func", caseSensitive: true)
        XCTAssertTrue(filter.apply("myFunc"))
    }

    func test_functionContains_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.contains("Func", caseSensitive: false)
        XCTAssertTrue(filter.apply("myfunc"))
    }

    func test_functionContains_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Function.contains("Func", caseSensitive: true)
        XCTAssertFalse(filter.apply("myfunc"))
    }

    func test_functionContains_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.contains("doSomething", "Func", caseSensitive: true)
        XCTAssertTrue(filter.apply("myFunc"))
    }

    func test_functionContains_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.contains("DoSomething", "func", caseSensitive: false)
        XCTAssertTrue(filter.apply("myFunc"))
    }

    func test_functionContains_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Function.contains("DoSomething", "Func", caseSensitive: true)
        XCTAssertFalse(filter.apply("myfunc"))
    }

    func test_functionExcludes_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.excludes("Func", caseSensitive: true)
        XCTAssertFalse(filter.apply("myFunc"))
    }

    func test_functionExcludes_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.excludes("Func", caseSensitive: false)
        XCTAssertFalse(filter.apply("myfunc"))
    }

    func test_functionExcludes_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Function.excludes("Func", caseSensitive: true)
        XCTAssertTrue(filter.apply("myfunc"))
    }

    func test_functionExcludes_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.excludes("doSomething", "Func", caseSensitive: true)
        XCTAssertTrue(filter.apply("myFunc"))
    }

    func test_functionExcludes_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.excludes("DoSomething", "func", caseSensitive: false)
        XCTAssertTrue(filter.apply("myFunc"))
    }

    func test_functionExcludes_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Function.excludes("DoSomething", "Func", caseSensitive: true)
        XCTAssertTrue(filter.apply("myfunc"))
    }

    func test_functionEndsWith_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.endsWith("Func", caseSensitive: true)
        XCTAssertTrue(filter.apply("myFunc"))
    }

    func test_functionEndsWith_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.endsWith("Func", caseSensitive: false)
        XCTAssertTrue(filter.apply("myfunc"))
    }

    func test_functionEndsWith_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Function.endsWith("Func", caseSensitive: true)
        XCTAssertFalse(filter.apply("myfunc"))
    }

    func test_functionEndsWith_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.endsWith("doSomething", "Func", caseSensitive: true)
        XCTAssertTrue(filter.apply("myFunc"))
    }

    func test_functionEndsWith_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.endsWith("DoSomething", "Func", caseSensitive: false)
        XCTAssertTrue(filter.apply("myfunc"))
    }

    func test_functionEndsWith_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Function.endsWith("DoSomething", "Func", caseSensitive: true)
        XCTAssertFalse(filter.apply("myfunc"))
    }

    func test_functionEquals_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.equals("myFunc", caseSensitive: true)
        XCTAssertTrue(filter.apply("myFunc"))
    }

    func test_functionEquals_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.equals("myFunc", caseSensitive: false)
        XCTAssertTrue(filter.apply("myfunc"))
    }

    func test_functionEquals_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Function.equals("myFunc", caseSensitive: true)
        XCTAssertFalse(filter.apply("myfunc"))
    }

    func test_functionEquals_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.equals("yourFunc", "myFunc", caseSensitive: true)
        XCTAssertTrue(filter.apply("myFunc"))
    }

    func test_functionEquals_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Function.equals("yourFunc", "myFunc", caseSensitive: false)
        XCTAssertTrue(filter.apply("myFunc"))
    }

    func test_functionEquals_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Function.equals("yourFunc", "myFunc", caseSensitive: true)
        XCTAssertFalse(filter.apply("myfunc"))
    }

    //
    // Message filtering tests (identity)
    //
    func test_message_getTarget_isMessageFilter() {
        let filter = Filters.Message.startsWith("Hello there, SwiftyBeaver!")
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
        let filter = Filters.Message.startsWith("Hello", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_message_containsAndIsRequired_isRequiredFilter() {
        let filter = Filters.Message.contains("there", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_message_excludesAndIsRequired_isRequiredFilter() {
        let filter = Filters.Message.excludes("there", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_message_endsWithAndIsRequired_isRequiredFilter() {
        let filter = Filters.Message.endsWith("SwifyBeaver!", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_message_equalsAndIsRequired_isRequiredFilter() {
        let filter = Filters.Message.equals("SwifyBeaver!", required: true)
        XCTAssertTrue(filter.isRequired())
    }

    func test_message_startsWithAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Message.startsWith("Hello", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_message_containsAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Message.contains("there", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_message_excludesAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Message.excludes("there", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_message_endsWithAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Message.endsWith("SwiftyBeaver!", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    func test_message_equalsAndIsNotRequired_isNotRequiredFilter() {
        let filter = Filters.Message.equals("SwiftyBeaver!", required: false)
        XCTAssertFalse(filter.isRequired())
    }

    //
    // Message filtering tests (case sensitivity)
    //
    func test_message_startsWithAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Message.startsWith("Hello", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(filter.getTarget()))
    }

    func test_message_containsAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Message.contains("there", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(filter.getTarget()))
    }

    func test_message_excludesAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Message.excludes("there", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(filter.getTarget()))
    }

    func test_message_endsWithAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Message.endsWith("SwiftyBeaver!", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(filter.getTarget()))
    }

    func test_message_equalsAndIsCaseSensitive_isCaseSensitive() {
        let filter = Filters.Message.equals("SwiftyBeaver!", caseSensitive: true)
        XCTAssertTrue(isCaseSensitive(filter.getTarget()))
    }

    func test_message_startsWithAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Message.startsWith("Hello", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(filter.getTarget()))
    }

    func test_message_containsAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Message.contains("there", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(filter.getTarget()))
    }

    func test_message_excludesAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Message.excludes("there", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(filter.getTarget()))
    }

    func test_message_endsWithAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Message.endsWith("SwiftyBeaver!", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(filter.getTarget()))
    }

    func test_message_equalsAndIsNotCaseSensitive_isNotCaseSensitive() {
        let filter = Filters.Message.equals("SwiftyBeaver!", caseSensitive: false)
        XCTAssertFalse(isCaseSensitive(filter.getTarget()))
    }

    //
    // Function filtering tests (comparison testing)
    //
    func test_messageStartsWith_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.startsWith("Hello", caseSensitive: true)
        XCTAssertTrue(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageStartsWith_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.startsWith("hello", caseSensitive: false)
        XCTAssertTrue(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageStartsWith_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Message.startsWith("hello", caseSensitive: true)
        XCTAssertFalse(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageStartsWith_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.startsWith("Goodbye", "Hello", caseSensitive: true)
        XCTAssertTrue(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageStartsWith_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.startsWith("goodbye", "hello", caseSensitive: false)
        XCTAssertTrue(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageStartsWith_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Message.startsWith("goodbye", "hello", caseSensitive: true)
        XCTAssertFalse(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageContains_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.contains("there", caseSensitive: true)
        XCTAssertTrue(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageContains_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.contains("There", caseSensitive: false)
        XCTAssertTrue(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageContains_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Message.contains("There", caseSensitive: true)
        XCTAssertFalse(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageContains_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.contains("their", "there", caseSensitive: true)
        XCTAssertTrue(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageContains_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.contains("Their", "There", caseSensitive: false)
        XCTAssertTrue(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageContains_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Message.contains("Their", "There", caseSensitive: true)
        XCTAssertFalse(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageExcludes_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.excludes("there", caseSensitive: true)
        XCTAssertFalse(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageExcludes_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.excludes("There", caseSensitive: false)
        XCTAssertFalse(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageExcludes_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Message.excludes("There", caseSensitive: true)
        XCTAssertTrue(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageExcludes_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.excludes("their", "there", caseSensitive: true)
        XCTAssertTrue(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageExcludes_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.excludes("Their", "There", caseSensitive: false)
        XCTAssertTrue(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageExcludes_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Message.excludes("Their", "There", caseSensitive: true)
        XCTAssertTrue(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageEndsWith_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.endsWith("SwiftyBeaver!", caseSensitive: true)
        XCTAssertTrue(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageEndsWith_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.endsWith("swiftybeaver!", caseSensitive: false)
        XCTAssertTrue(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageEndsWith_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Message.endsWith("swiftybeaver!", caseSensitive: true)
        XCTAssertFalse(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageEndsWith_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.endsWith("SluggishMink!", "SwiftyBeaver!", caseSensitive: true)
        XCTAssertTrue(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageEndsWith_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.endsWith("sluggishmink!", "swiftybeaver!", caseSensitive: false)
        XCTAssertTrue(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageEndsWith_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Message.endsWith("sluggishmink!!", "swiftybeaver!", caseSensitive: true)
        XCTAssertFalse(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageEquals_hasOneValueAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.equals("Hello there, SwiftyBeaver!", caseSensitive: true)
        XCTAssertTrue(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageEquals_hasOneValueAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.equals("hello there, swiftybeaver!", caseSensitive: false)
        XCTAssertTrue(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageEquals_hasOneValueAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Message.equals("hello there, swiftybeaver!", caseSensitive: true)
        XCTAssertFalse(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageEquals_hasMultipleValuesAndIsCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.equals("Goodbye, SluggishMink!", "Hello there, SwiftyBeaver!", caseSensitive: true)
        XCTAssertTrue(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageEquals_hasMultipleValuesAndIsNotCaseSensitiveAndMatches_answersTrue() {
        let filter = Filters.Message.equals("goodbye, sluggishmink!", "hello there, swiftybeaver!", caseSensitive: false)
        XCTAssertTrue(filter.apply("Hello there, SwiftyBeaver!"))
    }

    func test_messageEquals_hasMultipleValuesAndIsCaseSensitiveAndDoesNotMatch_answersFalse() {
        let filter = Filters.Message.equals("goodbye, sluggishmink!", "hello there, swiftybeaver!", caseSensitive: true)
        XCTAssertFalse(filter.apply("Hello there, SwiftyBeaver!"))
    }

    // Helper functions
    private func isCaseSensitive(_ targetType: Filter.TargetType) -> Bool {
        let comparisonType: Filter.ComparisonType?
        switch targetType {
        case let .Path(type):
            comparisonType = type

        case let .Function(type):
            comparisonType = type

        case let .Message(type):
            comparisonType = type
        }

        guard let compareType = comparisonType else {
            return false
        }

        let isCaseSensitive: Bool

        switch compareType {
        case let .Contains(_, caseSensitive):
            isCaseSensitive = caseSensitive

        case let .Excludes(_, caseSensitive):
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
