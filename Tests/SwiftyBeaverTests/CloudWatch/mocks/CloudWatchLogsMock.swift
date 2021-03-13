//
//  CloudWatchLogsMock.swift
//  SwiftyBeaver/CloudWatch
//

#if CLOUD_WATCH

import Foundation
import AWSCore
import AWSLogs
import SwiftyBeaver

public class CloudWatchLogsMock: CloudWatchLogs {
    var createLogStreamCalled = false
    var createStreamRequest: AWSLogsCreateLogStreamRequest? = nil
    var putEventsCalled = false
    var putEventsRequest: AWSLogsPutLogEventsRequest? = nil
    
    override public init(config: AWSServiceConfig, clientKey: String) {
        super.init(config: config, clientKey: clientKey)
    }
    
    override public func initialize() -> CloudWatchLogsMock {
        AWSLogs.register(with: configuration, forKey: clientKey)
        logs = AWSLogs.default()
        return self
    }
    
    override public func createLogStream(_ request: AWSLogsCreateLogStreamRequest, completionHandler: ((Error?) -> Void)?) {
        createLogStreamCalled = true
        createStreamRequest = request
        completionHandler?(nil)
    }
    
    override public func putLogEvents(_ request: AWSLogsPutLogEventsRequest, completionHandler: ((AWSLogsPutLogEventsResponse?, Error?) -> Void)?) {
        putEventsCalled = true
        putEventsRequest = request
        completionHandler?(nil, nil)
    }
}

#endif
