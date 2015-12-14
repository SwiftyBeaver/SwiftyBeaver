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
    public class func addDestination(destination: AnyObject) -> Bool {
		guard let dest = destination as? BaseDestination else {
			print("SwiftyBeaver: adding of destination failed")
			return false
		}
		
		//print("insert hashValue \(dest.hashValue)")
		destinations.insert(dest)  // if not already in (it’s a set)
		return true

    }

    /// returns boolean about success
    public class func removeDestination(destination: AnyObject) -> Bool {
		guard let dest = destination as? BaseDestination else {
			print("SwiftyBeaver: removing of destination failed")
			return false
		}
		
		destinations.remove(dest)
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
    
    
    // MARK: Levels
    
    public class func verbose(msg: Any, _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
        dispatch_send(Level.Verbose, msg: msg, path: path, function: function, line: line)
    }

    public class func debug(msg: Any, _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
        dispatch_send(Level.Debug, msg: msg, path: path, function: function, line: line)
    }
    
    public class func info(msg: Any, _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
        dispatch_send(Level.Info, msg: msg, path: path, function: function, line: line)
    }
    
    public class func warning(msg: Any, _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
        dispatch_send(Level.Warning, msg: msg, path: path, function: function, line: line)
    }
    
    public class func error(msg: Any, _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
       dispatch_send(Level.Error, msg: msg, path: path, function: function, line: line)
    }
    
    /// internal helper which dispatches send to dedicated queue if minLevel is ok
    class func dispatch_send(level: SwiftyBeaver.Level, msg: Any, path: String, function: String, line: Int) {
        for dest in destinations {
            let msgStr = "\(msg)"
            // try to convert msg object to String and put it on queue
            // ensure the message object is not empty
            guard let queue = dest.queue where
                dest.minLevel.rawValue <= level.rawValue && msgStr.characters.count > 0
                else { break }
            dispatch_async(queue, {
                dest.send(level, msg: msgStr, path: path, function: function, line: line)
            })
        }
    }
}
