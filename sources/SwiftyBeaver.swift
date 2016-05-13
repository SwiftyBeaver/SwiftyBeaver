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
    public static let version = "0.5.3"  // UPDATE ON RELEASE!
    /// build number of framework
    public static let build = 531 // version 0.7.0 -> 700, UPDATE ON RELEASE!

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
    #if swift(>=3.0)
    public class func addDestination(_ destination: BaseDestination) -> Bool {
        if destinations.contains(destination) {
            return false
        }
        destinations.insert(destination)
        return true
    }
    #else
    public class func addDestination(destination: BaseDestination) -> Bool {
        if destinations.contains(destination) {
            return false
        }
        destinations.insert(destination)
        return true
    }
    #endif

    /// returns boolean about success
    #if swift(>=3.0)
    public class func removeDestination(_ destination: BaseDestination) -> Bool {
        if destinations.contains(destination) == false {
            return false
        }
        destinations.remove(destination)
        return true
    }
    #else
    public class func removeDestination(destination: BaseDestination) -> Bool {
        if destinations.contains(destination) == false {
            return false
        }
        destinations.remove(destination)
        return true
    }
    #endif



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
            #if swift(>=3.0)
            let threadName = NSThread.current().name
            if let threadName = threadName where !threadName.isEmpty {
                return threadName
            } else if let queueName = NSString(utf8String:
                dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)) as String? where !queueName.isEmpty {
                return queueName
            } else {
                return String(format: "%p", NSThread.current())
            }
            #else
            let threadName = NSThread.currentThread().name
            if let threadName = threadName where !threadName.isEmpty {
                return threadName
            } else if let queueName = String(UTF8String:
                dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)) where !queueName.isEmpty {
                return queueName
            } else {
                return String(format: "%p", NSThread.currentThread())
            }
            #endif

        }
    }

    // MARK: Levels

    /// log something generally unimportant (lowest priority)
    #if swift(>=3.0)
    public class func verbose(_ message: @autoclosure () -> Any, _
        path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(level: Level.Verbose, message: message, thread: threadName(), path: path, function: function, line: line)
    }
    #else
    public class func verbose(@autoclosure message: () -> Any, _
        path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(Level.Verbose, message: message, thread: threadName(), path: path, function: function, line: line)
    }
    #endif

    /// log something which help during debugging (low priority)
    #if swift(>=3.0)
    public class func debug(_ message: @autoclosure () -> Any, _
        path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(level: Level.Debug, message: message, thread: threadName(), path: path, function: function, line: line)
    }
    #else
    public class func debug(@autoclosure message: () -> Any, _
        path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(Level.Debug, message: message, thread: threadName(), path: path, function: function, line: line)
    }
    #endif



    /// log something which you are really interested but which is not an issue or error (normal priority)
    #if swift(>=3.0)
    public class func info(_ message: @autoclosure () -> Any, _
        path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(level: Level.Info, message: message, thread: threadName(), path: path, function: function, line: line)
    }
    #else
    public class func info(@autoclosure message: () -> Any, _
        path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(Level.Info, message: message, thread: threadName(), path: path, function: function, line: line)
    }
    #endif

    /// log something which may cause big trouble soon (high priority)
    #if swift(>=3.0)
    public class func warning(_ message: @autoclosure () -> Any, _
        path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(level: Level.Warning, message: message, thread: threadName(), path: path, function: function, line: line)
    }
    #else
    public class func warning(@autoclosure message: () -> Any, _
        path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(Level.Warning, message: message, thread: threadName(), path: path, function: function, line: line)
    }
    #endif

    /// log something which will keep you awake at night (highest priority)
    #if swift(>=3.0)
    public class func error(_ message: @autoclosure () -> Any, _
        path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(level: Level.Error, message: message, thread: threadName(), path: path, function: function, line: line)
    }
    #else
    public class func error(@autoclosure message: () -> Any, _
        path: String = #file, _ function: String = #function, line: Int = #line) {
        dispatch_send(Level.Error, message: message, thread: threadName(), path: path, function: function, line: line)
    }
    #endif

    /// internal helper which dispatches send to dedicated queue if minLevel is ok
    #if swift(>=3.0)
    class func dispatch_send(level: SwiftyBeaver.Level, message: @autoclosure () -> Any,
        thread: String, path: String, function: String, line: Int) {
        for dest in destinations {

            guard let queue = dest.queue else {
                continue
            }

            if dest.shouldLevelBeLogged(level, path: path, function: function) {
                // try to convert msg object to String and put it on queue
                let msgStr = "\(message())"

                if dest.asynchronously {
                    dispatch_async(queue) {
                        dest.send(level, msg: msgStr, thread: thread, path: path, function: function, line: line)
                    }
                } else {
                    dispatch_sync(queue) {
                        dest.send(level, msg: msgStr, thread: thread, path: path, function: function, line: line)
                    }
                }
            }
        }
    }
    #else
    class func dispatch_send(level: SwiftyBeaver.Level, @autoclosure message: () -> Any,
        thread: String, path: String, function: String, line: Int) {
        for dest in destinations {
            
            guard let queue = dest.queue else {
                continue
            }
            
            if dest.shouldLevelBeLogged(level, path: path, function: function) {
                // try to convert msg object to String and put it on queue
                let msgStr = "\(message())"
                
                if dest.asynchronously {
                    dispatch_async(queue) {
                        dest.send(level, msg: msgStr, thread: thread, path: path, function: function, line: line)
                    }
                } else {
                    dispatch_sync(queue) {
                        dest.send(level, msg: msgStr, thread: thread, path: path, function: function, line: line)
                    }
                }
            }
        }
    }
    #endif

    /**
    Flush all destinations to make sure all logging messages have been written out
    Returns after all messages flushed or timeout seconds

    - returns: true if all messages flushed, false if timeout occurred
    */
    #if swift(>=3.0)
    public class func flush(_ secondTimeout: Int64) -> Bool {
        guard let grp = dispatch_group_create() else {
            return false // Swift 3 semantic change. Should perhaps throw.
        }
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
    #else
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
    #endif

}
