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
    
    public var logFileURL: NSURL

    override var defaultHashValue: Int {return 2}
    let fileManager = NSFileManager.defaultManager()
    
    public override init() {
        if let url = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
            logFileURL = url.URLByAppendingPathComponent("swiftybeaver.log", isDirectory: false)
        } else {
            logFileURL = NSURL()
        }
        super.init()
        
        // bash font color, first value is intensity, second is color
        // see http://bit.ly/1Otu3Zr to learn more
        blue = "0;34m"  // replace first 0 with 1 to make it bold
        green = "0;32m"
        yellow = "0;33m"
        red = "0;31m"
        magenta = "0;35m"
        cyan = "0;36m"
        silver = "0;37m"
        reset = "\u{001b}[0m"
    }
    
    // append to file. uses full base class functionality
    override func send(level: SwiftyBeaver.Level, msg: String, path: String, function: String, line: Int) -> String? {
        let formattedString = super.send(level, msg: msg, path: path, function: function, line: line)
        
        if let str = formattedString {
            saveToFile(str, url: logFileURL)
        }
        return formattedString
    }

    /// appends a string as line to a file.
    /// returns boolean about success
    func saveToFile(str: String, url: NSURL) -> Bool {
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

