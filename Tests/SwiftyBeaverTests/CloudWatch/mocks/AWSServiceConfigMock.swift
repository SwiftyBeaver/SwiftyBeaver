//
//  AWSServiceConfigMock.swift
//  SwiftyBeaver/CloudWatch
//

#if CLOUD_WATCH

import Foundation
import AWSCore
import SwiftyBeaver

public class AWSServiceConfigMock: AWSServiceConfig {
    
    override public init(cognitoPoolId: String, regionType: AWSRegionType) {
        super.init(cognitoPoolId: cognitoPoolId, regionType: regionType)
    }
    
    override public func create() -> AWSServiceConfigMock {
        configuration = AWSServiceConfiguration(region: self.regionType, credentialsProvider:nil)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        return self
    }
}

#endif
