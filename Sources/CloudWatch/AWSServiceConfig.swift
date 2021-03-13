//
//  AWSServiceConfig.swift
//  SwiftyBeaver/CloudWatch
//

#if CLOUD_WATCH

import Foundation
import AWSCore

open class AWSServiceConfig {
    public let cognitoPoolId: String
    public let regionType: AWSRegionType
    open var configuration: AWSServiceConfiguration! = nil
    
    public init(cognitoPoolId: String, regionType: AWSRegionType) {
        self.cognitoPoolId = cognitoPoolId
        self.regionType = regionType
    }
    
    open func create() -> AWSServiceConfig {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:self.regionType,
                identityPoolId: cognitoPoolId)
        configuration = AWSServiceConfiguration(region:self.regionType, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        return self
    }
}

#endif
