//
//  ConsoleDestination.swift
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger on 05.12.15.
//  Copyright © 2015 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation
#if canImport(OSLog)
import OSLog
#endif

open class ConsoleDestination: BaseDestination {
    public enum LogPrintWay {
        case logger(subsystem: String, category: String)
        case nslog
        case print
    }
    
    /// Use this to change the logging method to the console. By default, it is set to .print. You can switch to .logger(subsystem:category:) to utilize the OSLog API.
    public var logPrintWay: LogPrintWay = .print
    /// use NSLog instead of print, default is false
    public var useNSLog = false {
        didSet {
            if useNSLog {
                logPrintWay = .nslog
            }
        }
    }
    /// uses colors compatible to Terminal instead of Xcode, default is false
    public var useTerminalColors: Bool = false {
        didSet {
            if useTerminalColors {
                // use Terminal colors
                reset = "\u{001b}[0m"
                escape = "\u{001b}[38;5;"
                levelColor.verbose = "251m"     // silver
                levelColor.debug = "35m"        // green
                levelColor.info = "38m"         // blue
                levelColor.warning = "178m"     // yellow
                levelColor.error = "197m"       // red
                levelColor.critical = "197m"    // red
                levelColor.fault = "197m"       // red
            } else {
                // use colored Emojis for better visual distinction
                // of log level for Xcode 8
                levelColor.verbose = "💜 "     // purple
                levelColor.debug = "💚 "        // green
                levelColor.info = "💙 "         // blue
                levelColor.warning = "💛 "     // yellow
                levelColor.error = "❤️ "       // red
                levelColor.critical = "❤️ "    // red
                levelColor.fault = "❤️ "       // red
            }
        }
    }

    override public var defaultHashValue: Int { return 1 }

    public override init() {
        super.init()
        levelColor.verbose = "💜 "     // purple
        levelColor.debug = "💚 "        // green
        levelColor.info = "💙 "         // blue
        levelColor.warning = "💛 "     // yellow
        levelColor.error = "❤️ "       // red
        levelColor.critical = "❤️ "    // red
        levelColor.fault = "❤️ "       // red
    }

    // print to Xcode Console. uses full base class functionality
    override open func send(_ level: SwiftyBeaver.Level, msg: String, thread: String,
                                file: String, function: String, line: Int, context: Any? = nil) -> String? {
        let formattedString = super.send(level, msg: msg, thread: thread, file: file, function: function, line: line, context: context)

        if let message = formattedString {
#if os(Linux)
            print(message)
#else
            switch logPrintWay {
            case let .logger(subsystem, category):
                _logger(message: message, level: level, subsystem: subsystem, category: category)
            case .nslog:
                _nslog(message: message)
            case .print:
                _print(message: message)
            }
#endif
        }
        return formattedString
    }

    private func _logger(message: String, level: SwiftyBeaver.Level, subsystem: String, category: String) {
#if canImport(OSLog)
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            let logger = Logger(subsystem: subsystem, category: category)
            switch level {
            case .verbose:
                logger.trace("\(message)")
            case .debug:
                logger.debug("\(message)")
            case .info:
                logger.info("\(message)")
            case .warning:
                logger.warning("\(message)")
            case .error:
                logger.error("\(message)")
            case .critical:
                logger.critical("\(message)")
            case .fault:
                logger.fault("\(message)")
            }
        } else {
            _print(message: message)
        }
#else
        _print(message: message)
#endif
    }
    
    private func _nslog(message: String) {
        NSLog("%@", message)
    }
    
    private func _print(message: String) {
        print(message)
    }
}
