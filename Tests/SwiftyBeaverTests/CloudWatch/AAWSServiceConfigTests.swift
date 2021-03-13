//
//  AWSServiceConfigTests.swift
//  SwiftyBeaver/CloudWatch
//

#if CLOUD_WATCH

import Foundation
import XCTest
import AWSCore

@testable import SwiftyBeaver

//intentionally mispelled so this test runs first
class AAWSServiceConfigTests: XCTestCase {
    var serviceConfig: AWSServiceConfig! = nil

    override func setUp() {
        super.setUp()
        serviceConfig = AWSServiceConfig(cognitoPoolId: "12345", regionType: .USWest2)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInit() {
        XCTAssertEqual(serviceConfig.cognitoPoolId, "12345")
        XCTAssertEqual(serviceConfig.regionType, .USWest2)
    }
    
    func testCreate() {
        _ = serviceConfig.create()
        XCTAssertNotNil(AWSServiceManager.default().defaultServiceConfiguration)
        XCTAssertEqual(AWSServiceManager.default().defaultServiceConfiguration.regionType, .USWest2)
        XCTAssertNotNil(AWSServiceManager.default().defaultServiceConfiguration.credentialsProvider)
        XCTAssertEqual((AWSServiceManager.default().defaultServiceConfiguration.credentialsProvider as! AWSCognitoCredentialsProvider).identityPoolId, "12345")
    }

    static var allTests = [
        ("testInit", testInit),
        ("testCreate", testCreate)
    ]

}

#endif
