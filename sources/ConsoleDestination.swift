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

    public var useNSLog = false

    override public var defaultHashValue: Int { return 1 }

    public override init() {
        super.init()

        #if swift(>=2.3)
        #else
            levelColor.Verbose = "fg150,178,193;"     // silver
            levelColor.Debug = "fg32,155,124;"        // green
            levelColor.Info = "fg70,204,221;"         // blue
            levelColor.Warning = "fg253,202,78;"      // yellow
            levelColor.Error = "fg243,36,73;"         // red
            reset = "\u{001b}[;"
            escape = "\u{001b}["
        #endif
    }

    // print to Xcode Console. uses full base class functionality
    override public func send(level: SwiftyBeaver.Level, msg: String, thread: String,
        path: String, function: String, line: Int) -> String? {
        let formattedString = super.send(level, msg: msg, thread: thread, path: path, function: function, line: line)

        if let str = formattedString {
            if useNSLog {
                NSLog("%@", str)
            } else {
                print(str)
            }
        }
        return formattedString
    }
}
