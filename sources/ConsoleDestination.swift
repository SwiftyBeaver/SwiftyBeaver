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

    override public var defaultHashValue: Int {return 1}

    public override init() {
        super.init(queue: dispatch_get_main_queue())
    }

    // print to Xcode Console. uses full base class functionality
    override public func send(level: SwiftyBeaver.Level, msg: String, thread: String,
        path: String, function: String, line: Int) -> String? {
        let formattedString = super.send(level, msg: msg, thread: thread, path: path, function: function, line: line)

        if let str = formattedString {
            print(str)
        }
        return formattedString
    }
}
