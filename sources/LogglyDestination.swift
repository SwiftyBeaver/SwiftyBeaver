//
//  LogglyDestination.swift
//  SwiftyBeaver
//
//  Created by Francesco Pretelli on 2/03/16.
//  Copyright © 2016 Sebastian Kreutzberger. All rights reserved.
//

import Foundation
private let logglyQueue: dispatch_queue_t = dispatch_queue_create("loggly", DISPATCH_QUEUE_SERIAL)

public class LogglyDestination:BaseDestination {
    let LOGGLY_URL = "https://logs-01.loggly.com/inputs/"
    
    public var logglyToken:String = "insert-token-here"
    public var logglyTag:String = "http"
    public var maxEntriesBeforeSend = 1
    
    private var buffer:[String] = [String]()
    
    public override init() {
        super.init()
        self.colored = false
    }
    
    // append to file. uses full base class functionality
    override public func send(level: SwiftyBeaver.Level, msg: String, thread: String, path: String, function: String, line: Int) -> String? {
        let formattedString = super.send(level, msg: msg, thread: thread, path: path, function: function, line: line)
        
        if let str = formattedString {
            addLogMsgToBuffer(str)
        }
        return formattedString
    }
    
    private func getLogglyUrl() -> String {
        return LOGGLY_URL + logglyToken + "/tag/" + logglyTag
    }
    
    private func addLogMsgToBuffer(msg:String) {
        dispatch_async(logglyQueue) {
            self.buffer.append(msg)
            if self.buffer.count > self.maxEntriesBeforeSend {
                let tmpbuffer = self.buffer
                self.buffer = [String]()
                self.sendLogsInBuffer(tmpbuffer)
            }
        }
    }
    
    private func sendLogsInBuffer(stringbuffer:[String]) {
        let allMessagesString = stringbuffer.joinWithSeparator("\n")
        
        if let allMessagesData = (allMessagesString as NSString).dataUsingEncoding(NSUTF8StringEncoding) {
            let urlRequest = NSMutableURLRequest(URL: NSURL(string: getLogglyUrl())!)
            urlRequest.HTTPMethod = "POST"
            urlRequest.HTTPBody = allMessagesData
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue(), completionHandler: {
                (response: NSURLResponse?, responsedata: NSData?, error: NSError?) -> Void in
                if let anError = error {
                    print("Error from Loggly: \(anError)")
                } else {
                    if let data = responsedata {
                        print("Posted to Loggly, status = \(NSString(data: data, encoding:NSUTF8StringEncoding))")
                    }
                }
            })
        }
    }
}