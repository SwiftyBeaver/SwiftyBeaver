//
//  ConsoleDestination.swift
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger on 05.12.15.
//  Copyright © 2015 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation

public class ConsoleDestination: BaseDestination {

    /// use NSLog instead of print, default is false
    public var useNSLog = false
    /// use colored output compatible with Xcode, default is true
    /// if false then it uses colors compatible with Terminal
    public var useXcode = true

    override public var defaultHashValue: Int { return 1 }

    public override init() {
        super.init()

        // use colored Emojis for better visual distinction
        // of log level for Xcode 8
        if useXcode {
            // use colored Emojis for better visual distinction
            // of log level for Xcode 8
            levelColor.verbose = "💜 "     // silver
            levelColor.debug = "💚 "        // green
            levelColor.info = "💙 "         // blue
            levelColor.warning = "💛 "     // yellow
            levelColor.error = "❤️ "       // red

        } else {
            // use Terminal colors
            reset = "\u{001b}[0m"
            escape = "\u{001b}[38;5;"
            levelColor.verbose = "251m"     // silver
            levelColor.debug = "35m"        // green
            levelColor.info = "38m"         // blue
            levelColor.warning = "178m"     // yellow
            levelColor.error = "197m"       // red
        }
    }

    // print to Xcode Console. uses full base class functionality
    override public func send(_ level: SwiftyBeaver.Level, msg: String, thread: String,
                                file: String, function: String, line: Int) -> String? {
        let formattedString = super.send(level, msg: msg, thread: thread, file: file, function: function, line: line)

        if let str = formattedString {
            if useNSLog {
                #if os(Linux)
                    print(str)
                #else
                    NSLog("%@", str)
                #endif
            } else {
                print(str)
            }
        }
        return formattedString
    }

}
