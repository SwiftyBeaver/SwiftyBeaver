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
#elseif os(OSX) // elseif os(macOS) // <- available very soon, see https://git.io/vobEG
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

/// destination which all others inherit from. do not directly use
public class BaseDestination: Hashable, Equatable {

    /// output format pattern, see documentation for syntax
    public var format = "[$Dyyyy-MM-dd HH:mm:ss.SSS$d] $N.$F:$l $C$L$c: $M"

    /// runs in own serial background thread for better performance
    public var asynchronously = true

    /// do not log any message which has a lower level than this one
    public var minLevel = SwiftyBeaver.Level.Verbose

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
        public var Verbose = ""
        public var Debug = ""
        public var Info = ""
        public var Warning = ""
        public var Error = ""
    }

    var reset = ""
    var escape = ""

    var filters = [FilterType]()
    let formatter = NSDateFormatter()

    // each destination class must have an own hashValue Int
    lazy public var hashValue: Int = self.defaultHashValue
    public var defaultHashValue: Int {return 0}

    // each destination instance must have an own serial queue to ensure serial output
    // GCD gives it a prioritization between User Initiated and Utility
    var queue: dispatch_queue_t?

    var debugPrint = false // set to true to debug the internal logic of the class

    public init() {
        let uuid = NSUUID().UUIDString
        let queueLabel = "swiftybeaver-queue-" + uuid
        queue = dispatch_queue_create(queueLabel, DISPATCH_QUEUE_SERIAL)
    }

    /// send / store the formatted log message to the destination
    /// returns the formatted log message for processing by inheriting method
    /// and for unit tests (nil if error)
    public func send(level: SwiftyBeaver.Level, msg: String, thread: String,
        path: String, function: String, line: Int) -> String? {
        return formatMessage(format, level: level, msg: msg,
                             thread: thread, file: path, function: function, line: line)
    }


    ////////////////////////////////
    // MARK: Format
    ////////////////////////////////

    /// returns the log message based on the format pattern
    func formatMessage(format: String, level: SwiftyBeaver.Level, msg: String, thread: String,
        file: String, function: String, line: Int) -> String {

        var text = ""
        let phrases: [String] = format.componentsSeparatedByString("$")

        for phrase in phrases {
            if !phrase.isEmpty {
                let firstChar = phrase[phrase.startIndex]
                let indexAfterFirstChar = phrase.startIndex.advancedBy(1)
                let remainingPhrase = phrase.substringFromIndex(indexAfterFirstChar)

                switch firstChar {
                case "L":
                    text += levelWord(level) + remainingPhrase
                case "M":
                    text += msg + remainingPhrase
                case "m":
                    // json-encoded message
                    let dict = ["message": msg]
                    let jsonString = jsonStringFromDict(dict)
                    text += jsonStringValue(jsonString, key: "message") + remainingPhrase
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

    /// returns the string of a level
    func levelWord(level: SwiftyBeaver.Level) -> String {

        var str = ""

        switch level {
        case SwiftyBeaver.Level.Debug:
            str = levelString.Debug

        case SwiftyBeaver.Level.Info:
            str = levelString.Info

        case SwiftyBeaver.Level.Warning:
            str = levelString.Warning

        case SwiftyBeaver.Level.Error:
            str = levelString.Error

        default:
            // Verbose is default
            str = levelString.Verbose
        }
        return str
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

    /// returns the filename of a path
    func fileNameOfFile(file: String) -> String {
        let fileParts = file.componentsSeparatedByString("/")
        if let lastPart = fileParts.last {
            return lastPart
        }
        return ""
    }

    /// returns the filename without suffix (= file ending) of a path
    func fileNameWithoutSuffix(file: String) -> String {
        let fileName = fileNameOfFile(file)

        if !fileName.isEmpty {
            let fileNameParts = fileName.componentsSeparatedByString(".")
            if let firstPart = fileNameParts.first {
                return firstPart
            }
        }
        return ""
    }

    /// returns a formatted date string
    func formatDate(dateFormat: String) -> String {
        //formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        formatter.dateFormat = dateFormat
        let dateStr = formatter.stringFromDate(NSDate())
        return dateStr
    }

    /// returns the json-encoded string value
    /// after it was encoded by jsonStringFromDict
    func jsonStringValue(jsonString: String?, key: String) -> String {
        guard let str = jsonString else {
            return ""
        }

        let startIndex = str.startIndex.advancedBy(key.characters.count + 5)
        let endIndex = str.endIndex.advancedBy(-2)
        let range = Range(startIndex..<endIndex)
        return str.substringWithRange(range)
    }

    // turns dict into JSON-encoded string
    func jsonStringFromDict(dict: [String: AnyObject]) -> String? {
        var jsonString: String?
        // try to create JSON string
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(dict, options: [])
            if let str = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as? String {
                jsonString = str
            }
        } catch let error as NSError {
            print("SwiftyBeaver could not create JSON from dict. \(error)")
        }
        return jsonString
    }

    ////////////////////////////////
    // MARK: Filters
    ////////////////////////////////

    /// Add a filter that determines whether or not a particular message will be logged to this destination
    public func addFilter(filter: FilterType) {
        filters.append(filter)
    }

    /// Remove a filter from the list of filters
    public func removeFilter(filter: FilterType) {
        let index = filters.indexOf {
            return ObjectIdentifier($0) == ObjectIdentifier(filter)
        }

        guard let filterIndex = index else {
            return
        }

        filters.removeAtIndex(filterIndex)
    }

    /// Answer whether the destination has any message filters
    /// returns boolean and is used to decide whether to resolve the message before invoking shouldLevelBeLogged
    func hasMessageFilters() -> Bool {
        return !getFiltersTargeting(Filter.TargetType.Message(.Equals([], true)), fromFilters: self.filters).isEmpty
    }

    /// checks if level is at least minLevel or if a minLevel filter for that path does exist
    /// returns boolean and can be used to decide if a message should be logged or not
    func shouldLevelBeLogged(level: SwiftyBeaver.Level, path: String, function: String, message: String? = nil) -> Bool {

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

        if level.rawValue >= minLevel.rawValue {
            if debugPrint {
                print("filters is not empty and level >= minLevel")
            }
            return true
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
        return false
    }

    func getFiltersTargeting(target: Filter.TargetType, fromFilters: [FilterType]) -> [FilterType] {
        return fromFilters.filter {
            filter in
            return filter.getTarget() == target
        }
    }

    /// returns a tuple of matched and all filters
    func passedRequiredFilters(level: SwiftyBeaver.Level, path: String,
                               function: String, message: String?) -> (Int, Int) {
        let requiredFilters = self.filters.filter {
            filter in
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
    func passedNonRequiredFilters(level: SwiftyBeaver.Level,
                                           path: String, function: String, message: String?) -> (Int, Int) {
        let nonRequiredFilters = self.filters.filter {
            filter in
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
    func passedExcludedFilters(level: SwiftyBeaver.Level,
                              path: String, function: String, message: String?) -> (Int, Int) {
        let excludeFilters = self.filters.filter {
            filter in
            return filter.isExcluded()
        }

        let matchingFilters = applyFilters(excludeFilters, level: level,
                                           path: path, function: function, message: message)
        if debugPrint {
            print("matched \(matchingFilters) of \(excludeFilters.count) exclude filters")
        }
        return (matchingFilters, excludeFilters.count)
    }

    func applyFilters(targetFilters: [FilterType], level: SwiftyBeaver.Level,
                      path: String, function: String, message: String?) -> Int {
        return targetFilters.filter {
            filter in

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
