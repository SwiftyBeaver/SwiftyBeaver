//
//  AWSCloudWatchDestination.swift
//  SwiftyBeaver/CloudWatch
//

#if CLOUD_WATCH

public class AWSCloudWatchDestination: BaseDestination {
    public private(set) var logStream: CloudWatchLogStream! = nil
    private var logEvents: CloudWatchLogEvents = CloudWatchLogEvents()
    private var lastSend = Date().timeIntervalSince1970
    private var flushTimer = false
    private var sendInProgress = false
    
    public init(logStream: CloudWatchLogStream) {
        self.logStream = logStream
    }
    
    override public func send(_ level: SwiftyBeaver.Level, msg: String, thread: String,
            file: String, function: String, line: Int, context: Any? = nil) -> String? {

        let jsonString = "{\"level\":\"\(level)\",\"message\":\"\(msg)\",\"function\":\"\(function)\",\"fileName\":\"\(file.components(separatedBy: "/").last!)\",\"line\":\(line)}"
        
        logEvents.add(message: jsonString)
        
        if ((logEvents.events.count >= 10 || (logEvents.events.count > 0 &&
            Date().timeIntervalSince1970 - lastSend > 15.0)) && !sendInProgress) {
           sendEvents()
        } else {
            if (!flushTimer) {
                flushTimer = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                    self.sendEvents()
                    self.flushTimer = false
                }
            }
        }
        
        return jsonString
    }
    
    private func sendEvents() {
        sendInProgress = true
        execute(synchronously: false) {
            let dg = DispatchGroup()
            dg.enter()
            
            if (self.logEvents.events.count == 0) {
                self.sendInProgress = false
                dg.leave()
                return
            }
            
            self.logStream.sendEvents(events: self.logEvents) { (error, rejectedEventsInfo) in
                if let error = error {
                    print("An error occurred sending log events to AWS log stream. \(error)")
                }
                
                self.logEvents = CloudWatchLogEvents()
                self.lastSend = Date().timeIntervalSince1970
                self.sendInProgress = false
                dg.leave()
            }
            dg.wait()
        }
    }
        
}

#endif
