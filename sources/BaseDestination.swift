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
#elseif os(FreeBSD)
let OS = "FreeBSD"
#elseif os(Windows)
let OS = "Windows"
#elseif os(Android)
let OS = "Android"
#else
let OS = "Unknown"
#endif

@available(*, deprecated:0.5.5)
struct MinLevelFilter {
    var minLevel = SwiftyBeaver.Level.Verbose
    var path = ""
    var function = ""
}

/// destination which all others inherit from. do not directly use
open class BaseDestination: Hashable, Equatable {

    /// if true additionally logs file, function & line
    open var detailOutput = true
    /// adds colored log levels where possible
    open var colored = true
    /// colors entire log
    open var coloredLines = false
    /// runs in own serial background thread for better performance
    open var asynchronously = true
    /// do not log any message which has a lower level than this one
    open var minLevel = SwiftyBeaver.Level.Verbose {
        didSet {
            // Craft a new level filter and add it
            self.addFilter(filter: Filters.Level.atLeast(level: minLevel))
        }
    }
    /// standard log format; set to "" to not log date at all
    open var dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    /// set custom log level words for each level
    open var levelString = LevelString()
    /// set custom log level colors for each level
    open var levelColor = LevelColor()

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

    var filters = [FilterType]()
    let formatter = DateFormatter()

    var reset = "\u{001b}[;"
    var escape = "\u{001b}["

    // each destination class must have an own hashValue Int
    lazy public var hashValue: Int = self.defaultHashValue
    open var defaultHashValue: Int {return 0}

    // each destination instance must have an own serial queue to ensure serial output
    // GCD gives it a prioritization between User Initiated and Utility
    var queue: DispatchQueue? //dispatch_queue_t?

    public init() {
        let uuid = NSUUID().uuidString
        let queueLabel = "swiftybeaver-queue-" + uuid
        queue = DispatchQueue(label: queueLabel, target: queue)
        addFilter(filter: Filters.Level.atLeast(level: minLevel))
    }

    /// Add a filter that determines whether or not a particular message will be logged to this destination
    public func addFilter(filter: FilterType) {
        // There can only be a maximum of one level filter in the filters collection.
        // When one is set, remove any others if there are any and then add
        let isNewLevelFilter = self.getFiltersTargeting(target: Filter.TargetType.LogLevel(minLevel),
                                                        fromFilters: [filter]).count == 1
        if isNewLevelFilter {
            let levelFilters = self.getFiltersTargeting(target: Filter.TargetType.LogLevel(minLevel),
                                                        fromFilters: self.filters)
            levelFilters.forEach {
                filter in
                self.removeFilter(filter: filter)
            }
        }
        filters.append(filter)
    }

    /// Remove a filter from the list of filters
    public func removeFilter(filter: FilterType) {
        let index = filters.index {
            return ObjectIdentifier($0) == ObjectIdentifier(filter)
        }

        guard let filterIndex = index else {
            return
        }

        filters.remove(at: filterIndex)
    }

    /// send / store the formatted log message to the destination
    /// returns the formatted log message for processing by inheriting method
    /// and for unit tests (nil if error)
    open func send(_ level: SwiftyBeaver.Level, msg: String, thread: String,
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
    func formattedDate(_ dateFormat: String) -> String {
        //formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        formatter.dateFormat = dateFormat
        let dateStr = formatter.string(from: NSDate() as Date)
        return dateStr
    }

    /// returns the log message entirely colored
    func coloredMessage(_ msg: String, forLevel level: SwiftyBeaver.Level) -> String {
        if !(colored && coloredLines) {
            return msg
        }

        let color = colorForLevel(level: level)
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
    func formattedLevel(_ level: SwiftyBeaver.Level) -> String {
        // optionally wrap the level string in color
        let color = colorForLevel(level: level)
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
    func formattedMessage(_ dateString: String, levelString: String, msg: String,
        thread: String, path: String, function: String, line: Int, detailOutput: Bool) -> String {
        var str = ""
        if dateString != "" {
             str += "[\(dateString)] "
        }
        if detailOutput {
            if thread != "main" && thread != "" {
                str += "|\(thread)| "
            }

            // just use the file name of the path and remove suffix
            //let file = path.components(separatedBy: "/").last!.components(".").first!
            let pathComponents = path.components(separatedBy: "/")
            if let lastComponent = pathComponents.last {
                if let file = lastComponent.components(separatedBy: ".").first {
                    str += "\(file).\(function):\(String(line)) \(levelString): \(msg)"
                }
            }
        } else {
            str += "\(levelString): \(msg)"
        }
        return str
    }

    /// Answer whether the destination has any message filters
    /// returns boolean and is used to decide whether to resolve the message before invoking shouldLevelBeLogged
    func hasMessageFilters() -> Bool {
        return !getFiltersTargeting(target: Filter.TargetType.Message(.Equals([], true)),
                                    fromFilters: self.filters).isEmpty
    }

    /// checks if level is at least minLevel or if a minLevel filter for that path does exist
    /// returns boolean and can be used to decide if a message should be logged or not
    func shouldLevelBeLogged(level: SwiftyBeaver.Level, path: String, function: String, message: String? = nil) -> Bool {
        return passesAllRequiredFilters(level: level, path: path, function: function, message: message) &&
            passesAtLeastOneNonRequiredFilter(level: level, path: path, function: function, message: message)
    }

    func getFiltersTargeting(target: Filter.TargetType, fromFilters: [FilterType]) -> [FilterType] {
        return fromFilters.filter {
            filter in
            return filter.getTarget() == target
        }
    }

    func passesAllRequiredFilters(level: SwiftyBeaver.Level, path: String, function: String, message: String?) -> Bool {
        let requiredFilters = self.filters.filter {
            filter in
            return filter.isRequired()
        }

        return applyFilters(targetFilters: requiredFilters, level: level, path: path,
                            function: function, message: message) == requiredFilters.count
    }

    func passesAtLeastOneNonRequiredFilter(level: SwiftyBeaver.Level,
                                           path: String, function: String, message: String?) -> Bool {
        let nonRequiredFilters = self.filters.filter {
            filter in
            return !filter.isRequired()
        }

        return nonRequiredFilters.isEmpty ||
            applyFilters(targetFilters: nonRequiredFilters, level: level, path: path,
                         function: function, message: message) > 0
    }

    func passesLogLevelFilters(level: SwiftyBeaver.Level) -> Bool {
        let logLevelFilters = getFiltersTargeting(target: Filter.TargetType.LogLevel(level), fromFilters: self.filters)
        return logLevelFilters.filter {
            filter in

            return filter.apply(value: level.rawValue)
        }.count == logLevelFilters.count
    }

    func applyFilters(targetFilters: [FilterType], level: SwiftyBeaver.Level,
                      path: String, function: String, message: String?) -> Int {
        return targetFilters.filter {
            filter in

            let passes: Bool

            switch filter.getTarget() {
            case .LogLevel(_):
                passes = filter.apply(value: level.rawValue)

            case .Path(_):
                passes = filter.apply(value: path)

            case .Function(_):
                passes = filter.apply(value: function)

            case .Message(_):
                guard let message = message else {
                    return false
                }

                passes = filter.apply(value: message)
            }

            return passes
        }.count
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
