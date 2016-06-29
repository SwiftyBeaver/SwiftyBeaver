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
    public static let version = "0.6.3"  // UPDATE ON RELEASE!
    /// build number of framework
    public static let build = 630 // version 0.7.1 -> 710, UPDATE ON RELEASE!

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
    public class func addDestination(destination: BaseDestination) -> Bool {
        if destinations.contains(destination) {
            return false
        }
        destinations.insert(destination)
        return true
    }

    /// returns boolean about success
    public class func removeDestination(destination: BaseDestination) -> Bool {
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
        if NSThread.isMainThread() {
            return ""
        } else {
            if let threadName = NSThread.currentThread().name where !threadName.isEmpty {
                return threadName
            } else if let queueName = String(UTF8String:
                dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)) where !queueName.isEmpty {
                return queueName
            } else {
                return String(format: "%p", NSThread.currentThread())
            }
        }
    }

    // MARK: Levels

    /// log something generally unimportant (lowest priority)
    public class func verbose(@autoclosure message: () -> Any, _
        path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(Level.Verbose, message: message, thread: threadName(), path: path, function: function, line: line)
    }

    /// log something which help during debugging (low priority)
    public class func debug(@autoclosure message: () -> Any, _
        path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(Level.Debug, message: message, thread: threadName(), path: path, function: function, line: line)
    }

    /// log something which you are really interested but which is not an issue or error (normal priority)
    public class func info(@autoclosure message: () -> Any, _
        path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(Level.Info, message: message, thread: threadName(), path: path, function: function, line: line)
    }

    /// log something which may cause big trouble soon (high priority)
    public class func warning(@autoclosure message: () -> Any, _
        path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(Level.Warning, message: message, thread: threadName(), path: path, function: function, line: line)
    }

    /// log something which will keep you awake at night (highest priority)
    public class func error(@autoclosure message: () -> Any, _
        path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(Level.Error, message: message, thread: threadName(), path: path, function: function, line: line)
    }

    /// internal helper which dispatches send to dedicated queue if minLevel is ok
    class func dispatch_send(level: SwiftyBeaver.Level, @autoclosure message: () -> Any,
        thread: String, path: String, function: String, line: Int) {
        var resolvedMessage: String?
        for dest in destinations {

            guard let queue = dest.queue else {
                continue
            }

            resolvedMessage = resolvedMessage == nil && dest.hasMessageFilters() ? "\(message())" : nil
            if dest.shouldLevelBeLogged(level, path: path, function: function, message: resolvedMessage) {
                // try to convert msg object to String and put it on queue
                let msgStr = resolvedMessage == nil ? "\(message())" : resolvedMessage!
                let f = stripParams(function)

                if dest.asynchronously {
                    dispatch_async(queue) {
                        dest.send(level, msg: msgStr, thread: thread, path: path, function: f, line: line)
                    }
                } else {
                    dispatch_sync(queue) {
                        dest.send(level, msg: msgStr, thread: thread, path: path, function: f, line: line)
                    }
                }
            }
        }
    }

    /**
     Flush all destinations to make sure all logging messages have been written out
     Returns after all messages flushed or timeout seconds

     - returns: true if all messages flushed, false if timeout occurred
     */
    public class func flush(secondTimeout: Int64) -> Bool {
        let grp = dispatch_group_create()
        for dest in destinations {
            if let queue = dest.queue {
                dispatch_group_enter(grp)
                dispatch_async(queue, {
                    dest.flush()
                    dispatch_group_leave(grp)
                })
            }
        }
        let waitUntil = dispatch_time(DISPATCH_TIME_NOW, secondTimeout * 1000000000)
        return dispatch_group_wait(grp, waitUntil) == 0
    }

    /// removes the parameters from a function because it looks weird with a single param
    class func stripParams(function: String) -> String {
        var f = function
        if let indexOfBrace = f.characters.indexOf("(") {
            f = f.substringToIndex(indexOfBrace)
        }
        f = f + "()"
        return f
    }
}
