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

    /// version string of framework
    public static let version = "0.6.4"  // UPDATE ON RELEASE!
    /// build number of framework
    public static let build = 640 // version 0.7.1 -> 710, UPDATE ON RELEASE!

    public enum Level: Int {
        case Verbose = 0
        case Debug = 1
        case Info = 2
        case Warning = 3
        case Error = 4
    }

    // a set of active destinations
    public private(set) static var destinations = Set<BaseDestination>()

    // MARK: Destination Handling

    /// returns boolean about success
    @discardableResult
    public class func addDestination(_ destination: BaseDestination) -> Bool {
        if destinations.contains(destination) {
            return false
        }
        destinations.insert(destination)
        return true
    }

    /// returns boolean about success
    @discardableResult
    public class func removeDestination(_ destination: BaseDestination) -> Bool {
        if destinations.contains(destination) == false {
            return false
        }
        destinations.remove(destination)
        return true
    }

    /// if you need to start fresh
    public class func removeAllDestinations() {
        destinations.removeAll()
    }

    /// returns the amount of destinations
    public class func countDestinations() -> Int {
        return destinations.count
    }

    /// returns the current thread name
    class func threadName() -> String {
        if Thread.isMainThread {
            return ""
        } else {
            let threadName = Thread.current.name
            if let threadName = threadName, !threadName.isEmpty {
                return threadName
            } else {
                return String(format: "%p", Thread.current)
            }

            /*
             // had to remove the following block.
             // dispatch_queue_get_label seems not to be existing anymore in Swift 3
             else if let queueName = NSString(utf8String:
             dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)) as String? where !queueName.isEmpty {
             return queueName*/
        }
    }

    // MARK: Levels

    /// log something generally unimportant (lowest priority)
    public class func verbose(_ message: @autoclosure () -> Any, _
        path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(level: Level.Verbose, message: message, thread: threadName(),
                      path: path, function: function, line: line)
    }

    /// log something which help during debugging (low priority)
    public class func debug(_ message: @autoclosure () -> Any, _
        path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(level: Level.Debug, message: message, thread: threadName(),
                      path: path, function: function, line: line)
    }

    /// log something which you are really interested but which is not an issue or error (normal priority)
    public class func info(_ message: @autoclosure () -> Any, _
        path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(level: Level.Info, message: message, thread: threadName(),
                      path: path, function: function, line: line)
    }

    /// log something which may cause big trouble soon (high priority)
    public class func warning(_ message: @autoclosure () -> Any, _
        path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(level: Level.Warning, message: message, thread: threadName(),
                      path: path, function: function, line: line)
    }

    /// log something which will keep you awake at night (highest priority)
    public class func error(_ message: @autoclosure () -> Any, _
        path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(level: Level.Error, message: message, thread: threadName(),
                      path: path, function: function, line: line)
    }

    /// internal helper which dispatches send to dedicated queue if minLevel is ok
    class func dispatch_send(level: SwiftyBeaver.Level, message: @autoclosure () -> Any,
        thread: String, path: String, function: String, line: Int) {
        var resolvedMessage: String?
        for dest in destinations {

            guard let queue = dest.queue else {
                continue
            }

            resolvedMessage = resolvedMessage == nil && dest.hasMessageFilters() ? "\(message())" : nil
            if dest.shouldLevelBeLogged(level: level, path: path, function: function, message: resolvedMessage) {
                // try to convert msg object to String and put it on queue
                let msgStr = resolvedMessage == nil ? "\(message())" : resolvedMessage!
                let f = stripParams(function: function)

                if dest.asynchronously {
                    queue.async() {
                        let _ = dest.send(level, msg: msgStr, thread: thread, path: path, function: f, line: line)
                    }
                } else {
                    queue.sync() {
                        let _ = dest.send(level, msg: msgStr, thread: thread, path: path, function: f, line: line)
                    }
                }
            }
        }
    }

    /**
     DEPRECATED & NEEDS COMPLETE REWRITE DUE TO SWIFT 3 AND GENERAL INCORRECT LOGIC
     Flush all destinations to make sure all logging messages have been written out
     Returns after all messages flushed or timeout seconds

     - returns: true if all messages flushed, false if timeout or error occurred
     */
    public class func flush(secondTimeout: Int64) -> Bool {

        /*
        guard let grp = dispatch_group_create() else { return false }
        for dest in destinations {
            if let queue = dest.queue {
                dispatch_group_enter(grp)
                queue.asynchronously(execute: {
                    dest.flush()
                    grp.leave()
                })
            }
        }
        let waitUntil = DispatchTime.now(dispatch_time_t(DISPATCH_TIME_NOW), secondTimeout * 1000000000)
        return dispatch_group_wait(grp, waitUntil) == 0
         */
        return true
    }

    /// removes the parameters from a function because it looks weird with a single param
    class func stripParams(function: String) -> String {
        var f = function
        if let indexOfBrace = f.characters.index(of: "(") {
            f = f.substring(to: indexOfBrace)
        }
        f = f + "()"
        return f
    }
}
