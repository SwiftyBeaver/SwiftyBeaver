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

    override public var defaultHashValue: Int {return 2}
    let fileManager = NSFileManager.defaultManager()
    var fileHandle: NSFileHandle? = nil

    public override init() {
        // platform-dependent logfile directory default
        var logsBaseDir: NSSearchPathDirectory = .CachesDirectory

        if OS == "OSX" {
            logsBaseDir = .DocumentDirectory
        }

        if let url = fileManager.URLsForDirectory(logsBaseDir, inDomains: .UserDomainMask).first {
            logFileURL = url.URLByAppendingPathComponent("swiftybeaver.log", isDirectory: false)
        } else {
            logFileURL = NSURL()
        }
        super.init()

        // bash font color, first value is intensity, second is color
        // see http://bit.ly/1Otu3Zr to learn more
        // replace first 0 with 1 to make it bold
        levelColor.Verbose = "0;37m"
        levelColor.Debug = "0;34m"
        levelColor.Info = "0;32m"
        levelColor.Warning = "0;33m"
        levelColor.Error = "0;31m"

        reset = "\u{001b}[0m"
    }

    // append to file. uses full base class functionality
    override public func send(level: SwiftyBeaver.Level, msg: String, thread: String,
        path: String, function: String, line: Int) -> String? {
        let formattedString = super.send(level, msg: msg, thread: thread, path: path, function: function, line: line)

        if let str = formattedString {
            saveToFile(str, url: logFileURL)
        }
        return formattedString
    }

    deinit {
        // close file handle if set
        if let fileHandle = fileHandle {
            fileHandle.closeFile()
        }
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
                if fileHandle == nil {
                    // initial setting of file handle
                    fileHandle = try NSFileHandle(forWritingToURL: url)
                }
                if let fileHandle = fileHandle {
                    fileHandle.seekToEndOfFile()
                    let line = str + "\n"
                    let data = line.dataUsingEncoding(NSUTF8StringEncoding)!
                    fileHandle.writeData(data)
                }
            }
            return true
        } catch let error {
            print("SwiftyBeaver could not write to file \(url). \(error)")
            return false
        }
    }
}
