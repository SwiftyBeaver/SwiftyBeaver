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

    #if swift(>=2.3)
        override public var colored: Bool {
            // in Xcode 8 no color is possible so it is always false
            get { return false }
            set {}
        }
    #endif

    public override init() {
        super.init()
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
