//
//  SwiftyBeaver.swift
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger (Twitter @skreutzb) on 28.11.15.
//  Copyright © 2015 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation

public class SwiftyBeaver {
    
    public enum Level: Int {
        case Verbose = 0
        case Debug = 1
        case Info = 2
        case Warning = 3
        case Error = 4
    }
    
    static let fileManager = NSFileManager.defaultManager()
    static let documentsURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    
    // Options for Xcode console and File
    public struct Options {
        public struct Console {
            public static var active = true
            public static var detailOutput = true
            public static var colored = true
            public static var minLevel = Level.Verbose
            public static var dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        }
        
        public struct File {
            public static var active = false  // deactivated on default
            public static var detailOutput = true
            public static var colored = true
            public static var minLevel = Level.Verbose
            public static var dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            public static var logFileURL = documentsURL.URLByAppendingPathComponent("swiftybeaver.log", isDirectory: false)
        }
    }
    
    // SwiftyBeaver has an own serial queue to ensure serial output
    // GCD gives it a prioritization between User Initiated and Utility
    static var queue = dispatch_queue_create("swiftybeaver-serial-queue", nil)
    static let formatter = NSDateFormatter()
    
    // special character to escape color
    static let escape = "\u{001b}["
    
    // For a colored log level word in a logged line
    public struct Colors {
        // XCode RGB colors
        struct Console {
            static var blue = "fg0,0,255;"
            static var green = "fg0,255,0;"
            static var yellow = "fg255,255,0;"
            static var red = "fg255,0,0;"
            static var magenta = "fg255,0,255;"
            static var cyan = "fg0,255,255;"
            static var silver = "fg200,200,200;"
            static var reset = "\u{001b}[;"
        }
        
        // bash font color, first value is intensity, second is color
        // see http://bit.ly/1Otu3Zr to learn more
        struct File {
            static var blue = "0;34m"  // replace first 0 with 1 to make it bold
            static var green = "0;32m"
            static var yellow = "0;33m"
            static var red = "0;31m"
            static var magenta = "0;35m"
            static var cyan = "0;36m"
            static var silver = "0;37m"
            static var reset = "\u{001b}[0m"
        }
    }
    
    
    // MARK: Levels
    
    public class func verbose(msg: String = "", _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
        let level = Level.Verbose
        
        if (Options.Console.active && Options.Console.minLevel.rawValue <= level.rawValue) {
            dispatch_async(queue, {
                output(level, toFile: false, msg: msg, path: path, function: function, line: line)
            })
        }
        
        if (Options.File.active && Options.File.minLevel.rawValue <= level.rawValue) {
            dispatch_async(queue, {
                output(level, toFile: true, msg: msg, path: path, function: function, line: line)
            })
        }
    }
    
    public class func debug(msg: String = "", _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
        let level = Level.Debug
        
        if (Options.Console.active && Options.Console.minLevel.rawValue <= level.rawValue) {
            dispatch_async(queue, {
                output(level, toFile: false, msg: msg, path: path, function: function, line: line)
            })
        }
        
        if (Options.File.active && Options.File.minLevel.rawValue <= level.rawValue) {
            dispatch_async(queue, {
                output(level, toFile: true, msg: msg, path: path, function: function, line: line)
            })
        }
    }
    
    public class func info(msg: String = "", _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
        let level = Level.Info
        
        if (Options.Console.active && Options.Console.minLevel.rawValue <= level.rawValue) {
            dispatch_async(queue, {
                output(level, toFile: false, msg: msg, path: path, function: function, line: line)
            })
        }
        
        if (Options.File.active && Options.File.minLevel.rawValue <= level.rawValue) {
            dispatch_async(queue, {
                output(level, toFile: true, msg: msg, path: path, function: function, line: line)
            })
        }
    }
    
    public class func warning(msg: String = "", _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
        let level = Level.Warning
        
        if (Options.Console.active && Options.Console.minLevel.rawValue <= level.rawValue) {
            dispatch_async(queue, {
                output(level, toFile: false, msg: msg, path: path, function: function, line: line)
            })
        }
        
        if (Options.File.active && Options.File.minLevel.rawValue <= level.rawValue) {
            dispatch_async(queue, {
                output(level, toFile: true, msg: msg, path: path, function: function, line: line)
            })
        }
    }
    
    public class func error(msg: String = "", _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
        let level = Level.Error
        
        if (Options.Console.active && Options.Console.minLevel.rawValue <= level.rawValue) {
            dispatch_async(queue, {
                output(level, toFile: false, msg: msg, path: path, function: function, line: line)
            })
        }
        
        if (Options.File.active && Options.File.minLevel.rawValue <= level.rawValue) {
            dispatch_async(queue, {
                output(level, toFile: true, msg: msg, path: path, function: function, line: line)
            })
        }
    }
    
    
    // MARK: Output
    
    /// output formatted log message to Console or File
    /// returns the formatted log message for unit tests (nil of error)
    class func output(level: Level, toFile: Bool, msg: String, path: String, function: String, line: Int) -> String? {
        
        var dateStr = ""
        var str = ""
        let levelStr = formattedLevel(level, toFile:  toFile)
        
        if toFile {
            dateStr = formattedDate(Options.File.dateFormat)
            str = formattedMessage(dateStr, levelString: levelStr, msg: msg, path: path, function: function, line: line, detailOutput: Options.File.detailOutput)
        } else {
            dateStr = formattedDate(Options.Console.dateFormat)
            str = formattedMessage(dateStr, levelString: levelStr, msg: msg, path: path, function: function, line: line, detailOutput: Options.Console.detailOutput)
        }
        
        // finally do the output
        if toFile {
            saveToFile(str, url: Options.File.logFileURL)
        } else {
            print(str)
        }
        return str // for unit tests
    }
    
    /// returns a formatted date string
    class func formattedDate(dateFormat: String) -> String {
        //formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        formatter.dateFormat = dateFormat
        let dateStr = formatter.stringFromDate(NSDate())
        return dateStr
    }
    
    /// returns an optionally colored level noun (like INFO, etc.)
    class func formattedLevel(level: Level, toFile: Bool) -> String {
        var colored = Options.Console.colored
        if toFile {
            colored = Options.File.colored
        }
        
        // optionally wrap the level string in color
        var color = ""
        var levelStr = ""
        
        switch level {
        case Level.Debug:
            color = Colors.Console.blue
            if toFile {
                color = Colors.File.blue
            }
            levelStr = "DEBUG"
            
        case Level.Info:
            color = Colors.Console.green
            if toFile {
                color = Colors.File.green
            }
            levelStr = "INFO"
            
        case Level.Warning:
            color = Colors.Console.yellow
            if toFile {
                color = Colors.File.yellow
            }
            levelStr = "WARNING"
            
        case Level.Error:
            color = Colors.Console.red
            if toFile {
                color = Colors.File.red
            }
            levelStr = "ERROR"
            
        default:
            color = Colors.Console.silver
            if toFile {
                color = Colors.File.silver
            }
            levelStr = "VERBOSE"
        }
        
        if colored {
            levelStr = escape + color + levelStr
            if toFile {
                levelStr += Colors.File.reset
            } else {
                levelStr += Colors.Console.reset
            }
        }
        
        return levelStr
    }
    
    
    /// returns the formatted log message
    class func formattedMessage(dateString: String, levelString: String, msg: String, path: String, function: String, line: Int, detailOutput: Bool) -> String {
        
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
    
    /// appends a string as line to a file.
    /// returns boolean about success
    class func saveToFile(str: String, url: NSURL) -> Bool {
        do {
            if fileManager.fileExistsAtPath(url.path!) == false {
                // create file if not existing
                let line = str + "\n"
                try line.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
            } else {
                // append to end of file
                let fileHandle = try NSFileHandle(forWritingToURL: url)
                fileHandle.seekToEndOfFile()
                let line = str + "\n"
                let data = line.dataUsingEncoding(NSUTF8StringEncoding)!
                fileHandle.writeData(data)
                fileHandle.closeFile()
            }
            return true
        } catch let error {
            print("SwiftyBeaver could not write to file \(url). \(error)")
            return false
        }
    }
}