//
//  BaseDestination.swift
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger (Twitter @skreutzb) on 05.12.15.
//  Copyright © 2015 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation

struct MinLevelFilter {
    var minLevel = SwiftyBeaver.Level.Verbose
    var path = ""
    var function = ""
}

public class BaseDestination: Hashable, Equatable {
    
    public var detailOutput = true
    public var colored = true
    public var minLevel = SwiftyBeaver.Level.Verbose
    public var dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    public var levelString = LevelString()
    
    public struct LevelString {
        public var Verbose = "VERBOSE"
        public var Debug = "DEBUG"
        public var Info = "INFO"
        public var Warning = "WARNING"
        public var Error = "ERROR"
    }
    
    var minLevelFilters = [MinLevelFilter]()
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
        queue = dispatch_queue_create(queueLabel, nil)
    }
    
    /// overrule the destination’s minLevel for a given path and optional function
    public func addMinLevelFilter(minLevel: SwiftyBeaver.Level, path: String, function:String = "") {
        let filter = MinLevelFilter(minLevel: minLevel, path: path, function: function)
        minLevelFilters.append(filter)
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
            levelStr = levelString.Debug
            
        case SwiftyBeaver.Level.Info:
            color = green
            levelStr = levelString.Info
            
        case SwiftyBeaver.Level.Warning:
            color = yellow
            levelStr = levelString.Warning
            
        case SwiftyBeaver.Level.Error:
            color = red
            levelStr = levelString.Error

        default:
            // Verbose is default
            color = silver
            levelStr = levelString.Verbose
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
        if dateString != "" {
             str += "[\(dateString)] "
        }
        if detailOutput {
            str += "\(file).\(function):\(line) \(levelString): \(msg)"
        } else {
            str += "\(levelString): \(msg)"
        }
        return str
    }

    /// checks if level is at least minLevel or if a minLevel filter for that path does exist
    /// returns boolean and can be used to decide if a message should be logged or not
    func shouldLevelBeLogged(level: SwiftyBeaver.Level, path: String, function: String) -> Bool {
        var ok = false
        // at first check the instance’s global minLevel property
        if minLevel.rawValue <= level.rawValue {
            ok = true
        }
        // now go through all minLevelFilters and see if there is a match
        for filter in minLevelFilters {
            // rangeOfString returns nil if both values are the same!
            if filter.minLevel.rawValue <= level.rawValue {
                if filter.path == "" || path == filter.path || path.rangeOfString(filter.path) != nil {
                    if filter.function == "" || function == filter.function || function.rangeOfString(filter.function) != nil {
                        ok = true
                    }
                }
            }
        }
        return ok
    }
}

public func == (lhs: BaseDestination, rhs: BaseDestination) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

