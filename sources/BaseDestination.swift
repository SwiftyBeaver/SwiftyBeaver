//
//  BaseDestination.swift
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger (Twitter @skreutzb) on 05.12.15.
//  Copyright © 2015 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation

// store operating system / platform
#if os(iOS)
let OS = "iOS"
#elseif os(OSX)
let OS = "OSX"
#elseif os(watchOS)
let OS = "watchOS"
#elseif os(tvOS)
let OS = "tvOS"
#elseif os(Linux)
let OS = "Linux"
#else
let OS = "Unknown"
#endif

struct MinLevelFilter {
    var minLevel = SwiftyBeaver.Level.Verbose
    var path = ""
    var function = ""
}

/// destination which all others inherit from. do not directly use
public class BaseDestination: Hashable, Equatable {

    /// if true additionally logs file, function & line
    public var detailOutput = true
    /// adds colored log levels where possible
    public var colored = true
    /// colors entire log
    public var coloredLines = false
    /// runs in own serial background thread for better performance
    public var asynchronously = true
    /// do not log any message which has a lower level than this one
    public var minLevel = SwiftyBeaver.Level.Verbose
    /// standard log format; set to "" to not log date at all
    public var dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    /// set custom log level words for each level
    public var levelString = LevelString()
    /// set custom log level colors for each level
    public var levelColor = LevelColor()

    public struct LevelString {
        public var Verbose = "VERBOSE"
        public var Debug = "DEBUG"
        public var Info = "INFO"
        public var Warning = "WARNING"
        public var Error = "ERROR"
    }

    // For a colored log level word in a logged line
    // XCode RGB colors
    public struct LevelColor {
        public var Verbose = "fg150,178,193;"     // silver
        public var Debug = "fg32,155,124;"        // green
        public var Info = "fg70,204,221;"         // blue
        public var Warning = "fg253,202,78;"      // yellow
        public var Error = "fg243,36,73;"         // red
    }

    var minLevelFilters = [MinLevelFilter]()
    let formatter = NSDateFormatter()

    var reset = "\u{001b}[;"
    var escape = "\u{001b}["

    // each destination class must have an own hashValue Int
    lazy public var hashValue: Int = self.defaultHashValue
    public var defaultHashValue: Int {return 0}

    // each destination instance must have an own serial queue to ensure serial output
    // GCD gives it a prioritization between User Initiated and Utility
    var queue: dispatch_queue_t?

    public init() {
        let uuid = NSUUID().UUIDString
        let queueLabel = "swiftybeaver-queue-" + uuid
        queue = dispatch_queue_create(queueLabel, DISPATCH_QUEUE_SERIAL)
    }

    /// overrule the destination’s minLevel for a given path and optional function
    public func addMinLevelFilter(minLevel: SwiftyBeaver.Level, path: String, function: String = "") {
        let filter = MinLevelFilter(minLevel: minLevel, path: path, function: function)
        minLevelFilters.append(filter)
    }

    /// send / store the formatted log message to the destination
    /// returns the formatted log message for processing by inheriting method
    /// and for unit tests (nil if error)
    public func send(level: SwiftyBeaver.Level, msg: String, thread: String,
        path: String, function: String, line: Int) -> String? {
        var dateStr = ""
        var str = ""
        let levelStr = formattedLevel(level)
        let formattedMsg = coloredMessage(msg, forLevel: level)

        dateStr = formattedDate(dateFormat)
        str = formattedMessage(dateStr, levelString: levelStr, msg: formattedMsg, thread: thread, path: path,
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

    /// returns the log message entirely colored
    func coloredMessage(msg: String, forLevel level: SwiftyBeaver.Level) -> String {
        if !(colored && coloredLines) {
            return msg
        }

        let color = colorForLevel(level)
        let coloredMsg = escape + color + msg + reset
        return coloredMsg
    }

    /// returns color string for level
    func colorForLevel(level: SwiftyBeaver.Level) -> String {
        var color = ""

        switch level {
        case SwiftyBeaver.Level.Debug:
            color = levelColor.Debug

        case SwiftyBeaver.Level.Info:
            color = levelColor.Info

        case SwiftyBeaver.Level.Warning:
            color = levelColor.Warning

        case SwiftyBeaver.Level.Error:
            color = levelColor.Error

        default:
            color = levelColor.Verbose
        }

        return color
    }

    /// returns an optionally colored level noun (like INFO, etc.)
    func formattedLevel(level: SwiftyBeaver.Level) -> String {
        // optionally wrap the level string in color
        let color = colorForLevel(level)
        var levelStr = ""

        switch level {
        case SwiftyBeaver.Level.Debug:
            levelStr = levelString.Debug

        case SwiftyBeaver.Level.Info:
            levelStr = levelString.Info

        case SwiftyBeaver.Level.Warning:
            levelStr = levelString.Warning

        case SwiftyBeaver.Level.Error:
            levelStr = levelString.Error

        default:
            // Verbose is default
            levelStr = levelString.Verbose
        }

        if colored {
            levelStr = escape + color + levelStr + reset
        }
        return levelStr
    }

    /// returns the formatted log message
    func formattedMessage(dateString: String, levelString: String, msg: String,
        thread: String, path: String, function: String, line: Int, detailOutput: Bool) -> String {
        // just use the file name of the path and remove suffix
        let file = path.componentsSeparatedByString("/").last!.componentsSeparatedByString(".").first!
        var str = ""
        if dateString != "" {
             str += "[\(dateString)] "
        }
        if detailOutput {
            if thread != "main" && thread != "" {
                str += "|\(thread)| "
            }

            str += "\(file).\(function):\(line) \(levelString): \(msg)"
        } else {
            str += "\(levelString): \(msg)"
        }
        return str
    }

    /// checks if level is at least minLevel or if a minLevel filter for that path does exist
    /// returns boolean and can be used to decide if a message should be logged or not
    func shouldLevelBeLogged(level: SwiftyBeaver.Level, path: String, function: String) -> Bool {
        // at first check the instance’s global minLevel property
        if minLevel.rawValue <= level.rawValue {
            return true
        }
        // now go through all minLevelFilters and see if there is a match
        for filter in minLevelFilters {
            // rangeOfString returns nil if both values are the same!
            if filter.minLevel.rawValue <= level.rawValue {
                if filter.path == "" || path == filter.path || path.rangeOfString(filter.path) != nil {
                    if filter.function == "" || function == filter.function ||
                        function.rangeOfString(filter.function) != nil {
                        return true
                    }
                }
            }
        }
        return false
    }

  /**
    Triggered by main flush() method on each destination. Runs in background thread.
   Use for destinations that buffer log items, implement this function to flush those
   buffers to their final destination (web server...)
   */
  func flush() {
    // no implementation in base destination needed
  }
}

public func == (lhs: BaseDestination, rhs: BaseDestination) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}
