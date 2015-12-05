//
//  FileDestination.swift
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger on 05.12.15.
//  Copyright © 2015 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation

public class FileDestination: BaseDestination {
    
    override var defaultHashValue: Int {return 2}
    
    public struct Options {
        // use BaseDestination’s defaults
        public static var detailOutput = BaseDestination.Options.detailOutput
        public static var colored = BaseDestination.Options.colored
        public static var minLevel = BaseDestination.Options.minLevel
        public static var dateFormat = BaseDestination.Options.dateFormat
        public static var logFileURL = documentsURL.URLByAppendingPathComponent("swiftybeaver.log", isDirectory: false)
    }
    
    static let fileManager = NSFileManager.defaultManager()
    static let documentsURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    
    
    // print to Xcode Console. uses full base class functionality
    override class func send(level: SwiftyBeaver.Level, msg: String, path: String, function: String, line: Int) -> String? {
        let formattedString = super.send(level, msg: msg, path: path, function: function, line: line)
        
        if let str = formattedString {
            saveToFile(str, url: Options.logFileURL)
        }
        return formattedString
    }

    /// appends a string as line to a file.
    /// returns boolean about success
    class func saveToFile(str: String, url: NSURL) -> Bool {
        do {
            if fileManager.fileExistsAtPath(url.path!) == false {
                // create file if not existing
                let line = str + "\n"
                try line.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
            } else {
                // append to end of file
                let fileHandle = try NSFileHandle(forWritingToURL: url)
                fileHandle.seekToEndOfFile()
                let line = str + "\n"
                let data = line.dataUsingEncoding(NSUTF8StringEncoding)!
                fileHandle.writeData(data)
                fileHandle.closeFile()
            }
            return true
        } catch let error {
            print("SwiftyBeaver could not write to file \(url). \(error)")
            return false
        }
    }
}

