//
//  CloudWatchLogGroup.swift
//  SwiftyBeaver/CloudWatch
//

#if CLOUD_WATCH

import Foundation

public class CloudWatchLogGroup {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}

#endif
