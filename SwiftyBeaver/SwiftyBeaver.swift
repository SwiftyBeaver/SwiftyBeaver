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
    
    // SwiftyBeaver has an own serial queue to ensure serial output
    // GCD gives it a prioritization between User Initiated and Utility
    static var queue = dispatch_queue_create("swiftybeaver-serial-queue", nil)

    
    // MARK: Destination Handling
    
    /// returns boolean about success
    public class func addDestination(destination: AnyObject) -> Bool {
        let dest = destination as? BaseDestination
        
        if let dest = dest {
            destinations.insert(dest)  // if not already in (it’s a set)
            return true
        } else {
            print("SwiftyBeaver: adding of destination failed")
            return false
        }
    }

    /// returns boolean about success
    public class func removeDestination(destination: AnyObject) -> Bool {
        let dest = destination as? BaseDestination
        
        if let dest = dest {
            destinations.remove(dest)
            return true
        } else {
            print("SwiftyBeaver: removing of destination failed")
            return false
        }
    }
    
    /// returns the amount of destinations
    public class func countDestinations() -> Int {
        return destinations.count
    }
    
    
    // MARK: Levels
    
    public class func verbose(msg: String = "", _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
        let level = Level.Verbose
        
        for dest in destinations {
            if dest.Options.minLevel.rawValue <= level.rawValue {
            }
        }
    }

    /*
    public class func verbose(msg: String = "", _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
        let level = Level.Verbose
        
        if (Options.Console.active && Options.Console.minLevel.rawValue <= level.rawValue) {
            dispatch_async(queue, {
                output(level, toFile: false, msg: msg, path: path, function: function, line: line)
            })
        }
        
        if (Options.File.active && Options.File.minLevel.rawValue <= level.rawValue) {
            dispatch_async(queue, {
                output(level, toFile: true, msg: msg, path: path, function: function, line: line)
            })
        }
    }
    
    public class func debug(msg: String = "", _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
        let level = Level.Debug
        
        if (Options.Console.active && Options.Console.minLevel.rawValue <= level.rawValue) {
            dispatch_async(queue, {
                output(level, toFile: false, msg: msg, path: path, function: function, line: line)
            })
        }
        
        if (Options.File.active && Options.File.minLevel.rawValue <= level.rawValue) {
            dispatch_async(queue, {
                output(level, toFile: true, msg: msg, path: path, function: function, line: line)
            })
        }
    }
    
    public class func info(msg: String = "", _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
        let level = Level.Info
        
        if (Options.Console.active && Options.Console.minLevel.rawValue <= level.rawValue) {
            dispatch_async(queue, {
                output(level, toFile: false, msg: msg, path: path, function: function, line: line)
            })
        }
        
        if (Options.File.active && Options.File.minLevel.rawValue <= level.rawValue) {
            dispatch_async(queue, {
                output(level, toFile: true, msg: msg, path: path, function: function, line: line)
            })
        }
    }
    
    public class func warning(msg: String = "", _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
        let level = Level.Warning
        
        if (Options.Console.active && Options.Console.minLevel.rawValue <= level.rawValue) {
            dispatch_async(queue, {
                output(level, toFile: false, msg: msg, path: path, function: function, line: line)
            })
        }
        
        if (Options.File.active && Options.File.minLevel.rawValue <= level.rawValue) {
            dispatch_async(queue, {
                output(level, toFile: true, msg: msg, path: path, function: function, line: line)
            })
        }
    }
    
    public class func error(msg: String = "", _ path: String = __FILE__, _ function: String = __FUNCTION__, line: Int = __LINE__) {
        let level = Level.Error
        
        if (Options.Console.active && Options.Console.minLevel.rawValue <= level.rawValue) {
            dispatch_async(queue, {
                output(level, toFile: false, msg: msg, path: path, function: function, line: line)
            })
        }
        
        if (Options.File.active && Options.File.minLevel.rawValue <= level.rawValue) {
            dispatch_async(queue, {
                output(level, toFile: true, msg: msg, path: path, function: function, line: line)
            })
        }
    }
    */
    
}