//
//  CloudWatchLogStream.swift
//  SwiftyBeaver/CloudWatch
//

#if CLOUD_WATCH

import Foundation
import AWSLogs

public class CloudWatchLogStream {
    public let name: String
    public let group: CloudWatchLogGroup
    private let logs: CloudWatchLogs
    private var cloudWatchSequenceToken: String?
    
    public init(cloudWatchLogs: CloudWatchLogs, group: CloudWatchLogGroup, name: String) {
        self.name = name
        self.group = group
        self.logs = cloudWatchLogs
    }
    
    public func create(completion: @escaping (Error?) -> Void) {
        let logStreamRequest = AWSLogsCreateLogStreamRequest()!
        logStreamRequest.logGroupName = group.name
        logStreamRequest.logStreamName = name
        logs.createLogStream(logStreamRequest) { error in
            completion(error)
        }
    }
    
    public func sendEvents(events: CloudWatchLogEvents, completion: @escaping (Error?, AWSLogsRejectedLogEventsInfo?) -> Void) {
        let request = events.request
        request.logGroupName = group.name
        request.logStreamName = name
        request.sequenceToken = cloudWatchSequenceToken
        
        logs.putLogEvents(request) { resp, error in
            if let error = error {
                print("An error occurred putting the log events \(error)")
            }
            if let token = resp?.nextSequenceToken {
                self.cloudWatchSequenceToken = token
            }
            completion(error, resp?.rejectedLogEventsInfo)
        }
    }
}

#endif
