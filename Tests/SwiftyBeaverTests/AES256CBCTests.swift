//
//  AES256CBCTests.swift
//  AES256CBCTests
//
//  Created by Sebastian Kreutzberger on 2/9/16.
//  Copyright © 2016 SwiftyBeaver. All rights reserved.
//

import XCTest
@testable import SwiftyBeaverKit

class AES256CBCTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testEncryptDecryptStringCycle() {
        // encrypt. password must be 32 chars long
        let str = AES256CBC.randomText(32)
        let password = AES256CBC.randomText(32)
        let encrypted = AES256CBC.encryptString(str, password: password)
        XCTAssertNotNil(encrypted)
        //print("str: \(str)")
        //print("password: \(password)")
        //printn("encrypted secret (IV is at first 16 chars): \(encrypted)")

        if let encrypted = encrypted {
            XCTAssertGreaterThan(encrypted.length, 16)
            // decrypt
            let decrypted = AES256CBC.decryptString(encrypted, password: password)
            //print("decrypted str: \(decrypted)")
            XCTAssertNotNil(decrypted)
            XCTAssertEqual(decrypted, str)
        }
    }

    func testEncryptString() {
        // str length can vary due to padding, password must be 32 chars long
        var str = ""
        var password = ""
        var encrypted = AES256CBC.encryptString(str, password: password)
        XCTAssertNil(encrypted)

        // str must be longer than 0 characters
        str = ""
        password = AES256CBC.randomText(32)
        encrypted = AES256CBC.encryptString(str, password: password)
        XCTAssertNil(encrypted)

        // password must be exactly 32 chars long
        str = AES256CBC.randomText(20)
        password = AES256CBC.randomText(31)
        encrypted = AES256CBC.encryptString(str, password: password)
        XCTAssertNil(encrypted)

        password = AES256CBC.randomText(33)
        encrypted = AES256CBC.encryptString(str, password: password)
        XCTAssertNil(encrypted)

        // that works, even with str length of 3 due to padding
        str = "x"
        password = AES256CBC.randomText(32)
        encrypted = AES256CBC.encryptString(str, password: password)
        XCTAssertNotNil(encrypted)
        //NSLog("str: \(str)")
        //NSLog("password: \(password)")
        //NSLog("encrypted: \(encrypted)")

        if let encrypted = encrypted {
            XCTAssertGreaterThan(encrypted.length, 16)
            // decrypt
            let decrypted = AES256CBC.decryptString(encrypted, password: password)
            XCTAssertNotNil(decrypted)
            XCTAssertEqual(decrypted, str)
        }
    }

    func testDecryptString() {
        // the encrypted string must be at least 17 chars long because the first
        // 16 chars are the IV. password must be 32 chars long
        var str = ""
        var password = ""
        var decrypted = AES256CBC.decryptString(str, password: password)
        XCTAssertNil(decrypted)

        // str must be at least 17 chars long
        str = AES256CBC.randomText(16)
        password = AES256CBC.randomText(32)
        decrypted = AES256CBC.decryptString(str, password: password)
        XCTAssertNil(decrypted)

        str = AES256CBC.randomText(17)
        // password must be exactly 32 chars long
        password = AES256CBC.randomText(31)
        decrypted = AES256CBC.decryptString(str, password: password)
        XCTAssertNil(decrypted)

        password = AES256CBC.randomText(33)
        decrypted = AES256CBC.decryptString(str, password: password)
        XCTAssertNil(decrypted)
    }

    func testRandomText() {
        let length = 6
        let text = AES256CBC.randomText(length)
        let text2 = AES256CBC.randomText(length)
        XCTAssertEqual(text.length, length)
        XCTAssertEqual(text2.length, length)
        XCTAssertNotEqual(text, text2)
        XCTAssertNil(text.range(of: " "))
        XCTAssertNil(text2.range(of: " "))
    }

    func testGeneratePassword() {
        let pw = AES256CBC.generatePassword()
        let pw2 = AES256CBC.generatePassword()
        XCTAssertEqual(pw.length, 32)
        XCTAssertEqual(pw2.length, 32)
        XCTAssertNotEqual(pw, pw2)
        XCTAssertNil(pw.range(of: " "))
        XCTAssertNil(pw2.range(of: " "))
    }

    // MARK: Linux allTests

    static let allTests = [
        ("testEncryptDecryptStringCycle", testEncryptDecryptStringCycle),
        ("testEncryptString", testEncryptString),
        ("testDecryptString", testDecryptString),
        ("testRandomText", testRandomText),
        ("testGeneratePassword", testGeneratePassword)
    ]
}
