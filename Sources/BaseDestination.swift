//
//  BaseDestination.swift
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger (Twitter @skreutzb) on 05.12.15.
//  Copyright © 2015 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation
import Dispatch

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

/// destination which all others inherit from. do not directly use
open class BaseDestination: Hashable, Equatable {

    /// output format pattern, see documentation for syntax
    open var format = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"

    /// runs in own serial background thread for better performance
    open var asynchronously = true

    /// do not log any message which has a lower level than this one
    open var minLevel = SwiftyBeaver.Level.verbose

    /// set custom log level words for each level
    open var levelString = LevelString()

    /// set custom log level colors for each level
    open var levelColor = LevelColor()

    public struct LevelString {
        public var verbose = "VERBOSE"
        public var debug = "DEBUG"
        public var info = "INFO"
        public var warning = "WARNING"
        public var error = "ERROR"
    }

    // For a colored log level word in a logged line
    // empty on default
    public struct LevelColor {
        public var verbose = ""     // silver
        public var debug = ""       // green
        public var info = ""        // blue
        public var warning = ""     // yellow
        public var error = ""       // red
    }

    var reset = ""
    var escape = ""

    var filters = [FilterType]()
    let formatter = DateFormatter()

    // each destination class must have an own hashValue Int
    lazy public var hashValue: Int = self.defaultHashValue
    open var defaultHashValue: Int {return 0}

    // each destination instance must have an own serial queue to ensure serial output
    // GCD gives it a prioritization between User Initiated and Utility
    var queue: DispatchQueue? //dispatch_queue_t?
    var debugPrint = false // set to true to debug the internal filter logic of the class

    public init() {
        let uuid = NSUUID().uuidString
        let queueLabel = "swiftybeaver-queue-" + uuid
        queue = DispatchQueue(label: queueLabel, target: queue)
    }

    /// send / store the formatted log message to the destination
    /// returns the formatted log message for processing by inheriting method
    /// and for unit tests (nil if error)
    open func send(_ level: SwiftyBeaver.Level, msg: String, thread: String, file: String,
        function: String, line: Int) -> String? {

        if format.hasPrefix("$J") {
            return messageToJSON(level, msg: msg, thread: thread,
                                 file: file, function: function, line: line)

        } else {
            return formatMessage(format, level: level, msg: msg, thread: thread,
                                 file: file, function: function, line: line)
        }
    }

    ////////////////////////////////
    // MARK: Format
    ////////////////////////////////

    /// returns the log message based on the format pattern
    func formatMessage(_ format: String, level: SwiftyBeaver.Level, msg: String, thread: String,
        file: String, function: String, line: Int) -> String {

        var text = ""
        let phrases: [String] = format.components(separatedBy: "$")

        for phrase in phrases {
            if !phrase.isEmpty {
                let firstChar = phrase[phrase.startIndex]
                let rangeAfterFirstChar = phrase.index(phrase.startIndex, offsetBy: 1)..<phrase.endIndex
                let remainingPhrase = phrase[rangeAfterFirstChar]

                switch firstChar {
                case "L":
                    text += levelWord(level) + remainingPhrase
                case "M":
                    text += msg + remainingPhrase
                case "T":
                    text += thread + remainingPhrase
                case "N":
                    // name of file without suffix
                    text += fileNameWithoutSuffix(file) + remainingPhrase
                case "n":
                    // name of file with suffix
                    text += fileNameOfFile(file) + remainingPhrase
                case "F":
                    text += function + remainingPhrase
                case "l":
                    text += String(line) + remainingPhrase
                case "D":
                    // start of datetime format
                    text += formatDate(remainingPhrase)
                case "d":
                    text += remainingPhrase
                case "Z":
                    // start of datetime format in UTC timezone
                    text += formatDate(remainingPhrase, timeZone: "UTC")
                case "z":
                    text += remainingPhrase
                case "C":
                    // color code ("" on default)
                    text += escape + colorForLevel(level) + remainingPhrase
                case "c":
                    text += reset + remainingPhrase
                default:
                    text += phrase
                }
            }
        }
        return text
    }

    /// returns the log payload as optional JSON string
    func messageToJSON(_ level: SwiftyBeaver.Level, msg: String,
        thread: String, file: String, function: String, line: Int) -> String? {
        let dict: [String: Any] = [
            "timestamp": Date().timeIntervalSince1970,
            "level": level.rawValue,
            "message": msg,
            "thread": thread,
            "file": file,
            "function": function,
            "line": line]
        return jsonStringFromDict(dict)
    }

    /// returns the string of a level
    func levelWord(_ level: SwiftyBeaver.Level) -> String {

        var str = ""

        switch level {
        case SwiftyBeaver.Level.debug:
            str = levelString.debug

        case SwiftyBeaver.Level.info:
            str = levelString.info

        case SwiftyBeaver.Level.warning:
            str = levelString.warning

        case SwiftyBeaver.Level.error:
            str = levelString.error

        default:
            // Verbose is default
            str = levelString.verbose
        }
        return str
    }

    /// returns color string for level
    func colorForLevel(_ level: SwiftyBeaver.Level) -> String {
        var color = ""

        switch level {
        case SwiftyBeaver.Level.debug:
            color = levelColor.debug

        case SwiftyBeaver.Level.info:
            color = levelColor.info

        case SwiftyBeaver.Level.warning:
            color = levelColor.warning

        case SwiftyBeaver.Level.error:
            color = levelColor.error

        default:
            color = levelColor.verbose
        }
        return color
    }

    /// returns the filename of a path
    func fileNameOfFile(_ file: String) -> String {
        let fileParts = file.components(separatedBy: "/")
        if let lastPart = fileParts.last {
            return lastPart
        }
        return ""
    }

    /// returns the filename without suffix (= file ending) of a path
    func fileNameWithoutSuffix(_ file: String) -> String {
        let fileName = fileNameOfFile(file)

        if !fileName.isEmpty {
            let fileNameParts = fileName.components(separatedBy: ".")
            if let firstPart = fileNameParts.first {
                return firstPart
            }
        }
        return ""
    }

    /// returns a formatted date string
    /// optionally in a given abbreviated timezone like "UTC"
    func formatDate(_ dateFormat: String, timeZone: String = "") -> String {
        if !timeZone.isEmpty {
            formatter.timeZone = TimeZone(abbreviation: timeZone)
        }
        formatter.dateFormat = dateFormat
        //let dateStr = formatter.string(from: NSDate() as Date)
        let dateStr = formatter.string(from: Date())
        return dateStr
    }

    /// returns the json-encoded string value
    /// after it was encoded by jsonStringFromDict
    func jsonStringValue(_ jsonString: String?, key: String) -> String {
        guard let str = jsonString else {
            return ""
        }

        // remove the leading {"key":" from the json string and the final }
        let offset = key.characters.count + 5
        let endIndex = str.index(str.startIndex,
                                 offsetBy: str.characters.count - 2)
        let range = str.index(str.startIndex, offsetBy: offset)..<endIndex
        return str[range]
    }

    /// turns dict into JSON-encoded string
    func jsonStringFromDict(_ dict: [String: Any]) -> String? {
        var jsonString: String?

        // try to create JSON string
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
            jsonString = String(data: jsonData, encoding: .utf8)
        } catch {
            print("SwiftyBeaver could not create JSON from dict.")
        }
        return jsonString
    }

    ////////////////////////////////
    // MARK: Filters
    ////////////////////////////////

    /// Add a filter that determines whether or not a particular message will be logged to this destination
    public func addFilter(_ filter: FilterType) {
        filters.append(filter)
    }

    /// Remove a filter from the list of filters
    public func removeFilter(_ filter: FilterType) {
        let index = filters.index {
            return ObjectIdentifier($0) == ObjectIdentifier(filter)
        }

        guard let filterIndex = index else {
            return
        }

        filters.remove(at: filterIndex)
    }

    /// Answer whether the destination has any message filters
    /// returns boolean and is used to decide whether to resolve 
    /// the message before invoking shouldLevelBeLogged
    func hasMessageFilters() -> Bool {
        return !getFiltersTargeting(Filter.TargetType.Message(.Equals([], true)),
                                    fromFilters: self.filters).isEmpty
    }

    /// checks if level is at least minLevel or if a minLevel filter for that path does exist
    /// returns boolean and can be used to decide if a message should be logged or not
    func shouldLevelBeLogged(_ level: SwiftyBeaver.Level, path: String,
                             function: String, message: String? = nil) -> Bool {

        if filters.isEmpty {
            if level.rawValue >= minLevel.rawValue {
                if debugPrint {
                    print("filters is empty and level >= minLevel")
                }
                return true
            } else {
                if debugPrint {
                    print("filters is empty and level < minLevel")
                }
                return false
            }
        }

        let (matchedExclude, allExclude) = passedExcludedFilters(level, path: path,
                                                                 function: function, message: message)
        if allExclude > 0 && matchedExclude != allExclude {
            if debugPrint {
                print("filters is not empty and message was excluded")
            }
            return false
        }

        let (matchedRequired, allRequired) = passedRequiredFilters(level, path: path,
                                                                   function: function, message: message)
        let (matchedNonRequired, allNonRequired) = passedNonRequiredFilters(level, path: path,
                                                                    function: function, message: message)
        if allRequired > 0 {
            if matchedRequired == allRequired {
                return true
            }
        } else {
            // no required filters are existing so at least 1 optional needs to match
            if allNonRequired > 0 {
                if matchedNonRequired > 0 {
                    return true
                }
            } else if allExclude == 0 {
                // no optional is existing, so all is good
                return true
            }
        }

        if level.rawValue < minLevel.rawValue {
            if debugPrint {
                print("filters is not empty and level < minLevel")
            }
            return false
        }

        return false
    }

    func getFiltersTargeting(_ target: Filter.TargetType, fromFilters: [FilterType]) -> [FilterType] {
        return fromFilters.filter { filter in
            return filter.getTarget() == target
        }
    }

    /// returns a tuple of matched and all filters
    func passedRequiredFilters(_ level: SwiftyBeaver.Level, path: String,
                               function: String, message: String?) -> (Int, Int) {
        let requiredFilters = self.filters.filter { filter in
            return filter.isRequired() && !filter.isExcluded()
        }

        let matchingFilters = applyFilters(requiredFilters, level: level, path: path,
                                           function: function, message: message)
        if debugPrint {
            print("matched \(matchingFilters) of \(requiredFilters.count) required filters")
        }

        return (matchingFilters, requiredFilters.count)
    }

    /// returns a tuple of matched and all filters
    func passedNonRequiredFilters(_ level: SwiftyBeaver.Level,
                                  path: String, function: String, message: String?) -> (Int, Int) {
        let nonRequiredFilters = self.filters.filter { filter in
            return !filter.isRequired() && !filter.isExcluded()
        }

        let matchingFilters = applyFilters(nonRequiredFilters, level: level,
                                           path: path, function: function, message: message)
        if debugPrint {
            print("matched \(matchingFilters) of \(nonRequiredFilters.count) non-required filters")
        }
        return (matchingFilters, nonRequiredFilters.count)
    }

    /// returns a tuple of matched and all exclude filters
    func passedExcludedFilters(_ level: SwiftyBeaver.Level,
                               path: String, function: String, message: String?) -> (Int, Int) {
        let excludeFilters = self.filters.filter { filter in
            return filter.isExcluded()
        }

        let matchingFilters = applyFilters(excludeFilters, level: level,
                                           path: path, function: function, message: message)
        if debugPrint {
            print("matched \(matchingFilters) of \(excludeFilters.count) exclude filters")
        }
        return (matchingFilters, excludeFilters.count)
    }

    func applyFilters(_ targetFilters: [FilterType], level: SwiftyBeaver.Level,
                      path: String, function: String, message: String?) -> Int {
        return targetFilters.filter { filter in

            let passes: Bool

            if !filter.reachedMinLevel(level) {
                return false
            }

            switch filter.getTarget() {
            case .Path(_):
                passes = filter.apply(path)

            case .Function(_):
                passes = filter.apply(function)

            case .Message(_):
                guard let message = message else {
                    return false
                }

                passes = filter.apply(message)
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
