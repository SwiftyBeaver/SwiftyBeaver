//
//  CloudWatchLogs.swift
//  SwiftyBeaver/CloudWatch
//

#if CLOUD_WATCH

import Foundation
import AWSLogs

open class CloudWatchLogs {
    public let clientKey: String
    public let configuration: AWSServiceConfiguration
    public var logs: AWSLogs! = nil
    
    public init(config: AWSServiceConfig, clientKey: String) {
        self.configuration = config.configuration
        self.clientKey = clientKey
    }
    
    open func initialize() -> CloudWatchLogs {
        AWSLogs.register(with: configuration, forKey: clientKey)
        logs = AWSLogs.init(forKey: clientKey)
        return self
    }
    
    open func createLogStream(_ request: AWSLogsCreateLogStreamRequest, completionHandler: ((Error?) -> Void)?) {
        logs.createLogStream(request) { error in
            completionHandler?(error)
        }
    }
    
    open func putLogEvents(_ request: AWSLogsPutLogEventsRequest, completionHandler: ((AWSLogsPutLogEventsResponse?, Error?) -> Void)?) {
        logs.putLogEvents(request) { resp, error in
            completionHandler?(resp, error)
        }
    }
}

#endif
