//
//  NullDestination.swift
//  SwiftyBeaver
//
//  Created by Kehrig, Andrew on 4/14/17.

import Foundation

public class NullDestination : BaseDestination {
    override public func send(_ level: SwiftyBeaver.Level, msg: String, thread: String,
                              file: String, function: String, line: Int) -> String? {
        let formattedString = super.send(level, msg: msg, thread: thread, file: file, function: function, line: line)
        return formattedString
    }
}
