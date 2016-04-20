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

    public enum Level: Int {
        case Verbose = 0
        case Debug = 1
        case Info = 2
        case Warning = 3
        case Error = 4
    }

    // a set of active destinations
    static var destinations = Set<BaseDestination>() //[BaseDestination]()


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


        var builtMessage: Any?
        var builtAsString: String?
        var builtAsStringDebugDescription: String?

        for dest in destinations {

            if case .Disabled = dest.executionContext {
                continue
            }

            if dest.shouldLevelBeLogged(level, path: path, function: function) {
                // try to convert msg object to String and put it on queue

                // only call message() for the first valid destination
                if builtMessage == nil {
                    builtMessage = message()
                }
                // only convert these to strings as needed once
                if !dest.useDebugDescription && (builtAsString == nil) {
                    builtAsString = "\(builtMessage!)"
                }
                if dest.useDebugDescription && (builtAsStringDebugDescription == nil) {
                    builtAsStringDebugDescription = String(reflecting: builtMessage)
                }

                let msgStr = dest.useDebugDescription ? builtAsStringDebugDescription! : builtAsString!

                if !msgStr.isEmpty {

                    dest.executionContext.dispatch {
                        dest.send(level, msg: msgStr, thread: thread, path: path, function: function, line: line)
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

        if case .Disabled = dest.executionContext {
            continue
        }
        dispatch_group_enter(grp)
        dest.executionContext.dispatch({
            dest.flushAsync {
                dispatch_group_leave(grp)
            }
        })
    }
    let waitUntil = dispatch_time(DISPATCH_TIME_NOW, secondTimeout * 1000000000)
    return dispatch_group_wait(grp, waitUntil) == 0
   }


    // doesn't block the calling thread when calling!
    public class func flush(secondTimeout: Int64, flushDone: (Bool) -> ()) {

        let uuid = NSUUID().UUIDString
        let queueLabel = "swiftybeaver-queue-flush" + uuid
        let flush_queue = dispatch_queue_create(queueLabel, nil)

        dispatch_async(flush_queue) {
            flushDone(self.flush(secondTimeout))
        }
    }

}
