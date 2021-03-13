//
//  CloudWatchLogEvents.swift
//  SwiftyBeaver/CloudWatch
//

#if CLOUD_WATCH

import Foundation
import AWSLogs

public class CloudWatchLogEvents {
    public let request = AWSLogsPutLogEventsRequest()!
    
    public init() {
        request.logEvents = []
    }
    
    public var events: [AWSLogsInputLogEvent] {
        return request.logEvents!
    }
    
    public func add(message: String) {
        let event = AWSLogsInputLogEvent()!
        event.message = message
        event.timestamp = NSNumber(value: Date().timeIntervalSince1970 * 1000)
        request.logEvents?.append(event)
    }
}

#endif
