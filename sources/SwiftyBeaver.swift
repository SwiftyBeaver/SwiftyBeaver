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
    
    public class func verbose(items: Any..., _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
        dispatch_send(Level.Verbose, items: items, path: path, function: function, line: line)
    }

    public class func debug(items: Any..., _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
        dispatch_send(Level.Debug, items: items, path: path, function: function, line: line)
    }
    
    public class func info(items: Any..., _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
        dispatch_send(Level.Info, items: items, path: path, function: function, line: line)
    }
    
    public class func warning(items: Any..., _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
        dispatch_send(Level.Warning, items: items, path: path, function: function, line: line)
    }
    
    public class func error(items: Any..., _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
       dispatch_send(Level.Error, items: items, path: path, function: function, line: line)
    }
    
    /// internal helper which dispatches send to dedicated queue if minLevel is ok
    class func dispatch_send(level: SwiftyBeaver.Level, items: [Any], path: String, function: String, line: Int) {
        let separator = " "
        var msgStr = ""
        for item in items {
            if !msgStr.isEmpty {
                msgStr += separator
            }
            if let itemStr = item as? String {
                msgStr += itemStr
            } else {
                msgStr += String(item)
            }
        }
        for dest in destinations {
            if let queue = dest.queue {
                if dest.shouldLevelBeLogged(level, path: path, function: function) && dest.queue != nil {
                    // try to convert msg object to String and put it on queue
                    if msgStr.characters.count > 0 {
                        dispatch_async(queue, {
                            dest.send(level, msg: msgStr, path: path, function: function, line: line)
                        })
                    }
                }
            }
        }
    }
}
