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
    
    public struct Options {
        //public static var active = true
        public static var detailOutput = true
        public static var colored = true
        public static var minLevel = SwiftyBeaver.Level.Verbose
        public static var dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }
    
    public var x = 1
    
    static let formatter = NSDateFormatter()

    // For a colored log level word in a logged line
    struct Colors {
        // XCode RGB colors
        static var blue = "fg0,0,255;"
        static var green = "fg0,255,0;"
        static var yellow = "fg255,255,0;"
        static var red = "fg255,0,0;"
        static var magenta = "fg255,0,255;"
        static var cyan = "fg0,255,255;"
        static var silver = "fg200,200,200;"
        static var reset = "\u{001b}[;"
        static var escape = "\u{001b}["
    }

    //public let hashValue = 0
    lazy public var hashValue: Int = self.defaultHashValue
    var defaultHashValue: Int {return 0}

    /// send / store the formatted log message to the destination
    /// returns the formatted log message for processing by inheriting method
    /// and for unit tests (nil if error)
    class func send(level: SwiftyBeaver.Level, msg: String, path: String, function: String, line: Int) -> String? {
        var dateStr = ""
        var str = ""
        let levelStr = formattedLevel(level)
        
        dateStr = formattedDate(Options.dateFormat)
        str = formattedMessage(dateStr, levelString: levelStr, msg: msg, path: path,
            function: function, line: line, detailOutput: Options.detailOutput)
        return str
    }
    
    /// returns a formatted date string
    class func formattedDate(dateFormat: String) -> String {
        //formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        formatter.dateFormat = dateFormat
        let dateStr = formatter.stringFromDate(NSDate())
        return dateStr
    }
    
    /// returns an optionally colored level noun (like INFO, etc.)
    class func formattedLevel(level: SwiftyBeaver.Level) -> String {
        let colored = Options.colored
        // optionally wrap the level string in color
        var color = ""
        var levelStr = ""
        
        switch level {
        case SwiftyBeaver.Level.Debug:
            color = Colors.blue
            levelStr = "DEBUG"
            
        case SwiftyBeaver.Level.Info:
            color = Colors.green
            levelStr = "INFO"
            
        case SwiftyBeaver.Level.Warning:
            color = Colors.yellow
            levelStr = "WARNING"
            
        case SwiftyBeaver.Level.Error:
            color = Colors.red
            levelStr = "ERROR"
            
        default:
            color = Colors.silver
            levelStr = "VERBOSE"
        }
        
        if colored {
            levelStr = Colors.escape + color + levelStr + Colors.reset
        }
        return levelStr
    }
    
    /// returns the formatted log message
    class func formattedMessage(dateString: String, levelString: String, msg: String,
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

