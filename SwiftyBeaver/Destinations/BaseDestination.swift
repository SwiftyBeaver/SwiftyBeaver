//
//  BaseDestination.swift
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger (Twitter @skreutzb) on 05.12.15.
//  Copyright © 2015 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation

public class BaseDestination: Hashable, Equatable {
    
    public var detailOutput = true
    public var colored = true
    public var minLevel = SwiftyBeaver.Level.Verbose
    public var dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    
    let formatter = NSDateFormatter()

    // For a colored log level word in a logged line
    // XCode RGB colors
    var blue = "fg0,0,255;"
    var green = "fg0,255,0;"
    var yellow = "fg255,255,0;"
    var red = "fg255,0,0;"
    var magenta = "fg255,0,255;"
    var cyan = "fg0,255,255;"
    var silver = "fg200,200,200;"
    var reset = "\u{001b}[;"
    var escape = "\u{001b}["


    // each destination class must have an own hashValue Int
    lazy public var hashValue: Int = self.defaultHashValue
    var defaultHashValue: Int {return 0}
    
    // each destination instance must have an own serial queue to ensure serial output
    // GCD gives it a prioritization between User Initiated and Utility
    var queue: dispatch_queue_t?
    
    init() {
        let uuid = NSUUID().UUIDString
        let queueLabel = "swiftybeaver-queue-" + uuid
        //print("creating queue \(queueLabel)")
        queue = dispatch_queue_create(queueLabel, nil)
    }
    
    /// send / store the formatted log message to the destination
    /// returns the formatted log message for processing by inheriting method
    /// and for unit tests (nil if error)
    func send(level: SwiftyBeaver.Level, msg: String, path: String, function: String, line: Int) -> String? {
        var dateStr = ""
        var str = ""
        let levelStr = formattedLevel(level)
        
        dateStr = formattedDate(dateFormat)
        str = formattedMessage(dateStr, levelString: levelStr, msg: msg, path: path,
            function: function, line: line, detailOutput: detailOutput)
        return str
    }
    
    /// returns a formatted date string
    func formattedDate(dateFormat: String) -> String {
        //formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        formatter.dateFormat = dateFormat
        let dateStr = formatter.stringFromDate(NSDate())
        return dateStr
    }
    
    /// returns an optionally colored level noun (like INFO, etc.)
    func formattedLevel(level: SwiftyBeaver.Level) -> String {
        // optionally wrap the level string in color
        var color = ""
        var levelStr = ""
        
        switch level {
        case SwiftyBeaver.Level.Debug:
            color = blue
            levelStr = "DEBUG"
            
        case SwiftyBeaver.Level.Info:
            color = green
            levelStr = "INFO"
            
        case SwiftyBeaver.Level.Warning:
            color = yellow
            levelStr = "WARNING"
            
        case SwiftyBeaver.Level.Error:
            color = red
            levelStr = "ERROR"
            
        default:
            color = silver
            levelStr = "VERBOSE"
        }
        
        if colored {
            levelStr = escape + color + levelStr + reset
        }
        return levelStr
    }
    
    /// returns the formatted log message
    func formattedMessage(dateString: String, levelString: String, msg: String,
        path: String, function: String, line: Int, detailOutput: Bool) -> String {
        // just use the file name of the path and remove suffix
        let file = path.componentsSeparatedByString("/").last!.componentsSeparatedByString(".").first!
        var str = ""
        if detailOutput {
            str = "[\(dateString)] \(file).\(function):\(line) \(levelString): \(msg)"
        } else {
            str = "[\(dateString)] \(levelString): \(msg)"
        }
        return str
    }
}

public func == (lhs: BaseDestination, rhs: BaseDestination) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

