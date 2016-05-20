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

    public var logFileURL: NSURL?

    override public var defaultHashValue: Int {return 2}
    let fileManager = NSFileManager.defaultManager()
    var fileHandle: NSFileHandle? = nil

    public override init() {
        // platform-dependent logfile directory default
        var baseURL: NSURL?

        if OS == "OSX" {
            if let url = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first {
                baseURL = url
                // try to use ~/Library/Caches/APP NAME instead of ~/Library/Caches
                if let appName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleExecutable") as? String {
                    do {
                        if let appURL = baseURL?.URLByAppendingPathComponent(appName, isDirectory: true) {
                            try fileManager.createDirectoryAtURL(appURL,
                                                                 withIntermediateDirectories: true, attributes: nil)
                            baseURL = appURL
                        }
                    } catch let error as NSError {
                        print("Warning! Could not create folder /Library/Caches/\(appName). \(error)")
                    }
                }
            }
        } else {
            // iOS, watchOS, etc. are using the caches directory
            if let url = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask).first {
                baseURL = url
            }
        }

        if let baseURL = baseURL {
            logFileURL = baseURL.URLByAppendingPathComponent("swiftybeaver.log", isDirectory: false)
        }
        super.init()

        // bash font color, first value is intensity, second is color
        // see http://bit.ly/1Otu3Zr & for syntax http://bit.ly/1Tp6Fw9
        // uses the 256-color table from http://bit.ly/1W1qJuH
        reset = "\u{001b}[0m"
        escape = "\u{001b}[38;5;"
        levelColor.Verbose = "251m"
        levelColor.Debug = "35m"
        levelColor.Info = "38m"
        levelColor.Warning = "178m"
        levelColor.Error = "197m"
    }

    // append to file. uses full base class functionality
    override public func send(level: SwiftyBeaver.Level, msg: String, thread: String,
        path: String, function: String, line: Int) -> String? {
        let formattedString = super.send(level, msg: msg, thread: thread, path: path, function: function, line: line)

        if let str = formattedString {
            saveToFile(str)
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
    func saveToFile(str: String) -> Bool {
        guard let url = logFileURL else { return false }
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
            print("SwiftyBeaver File Destination could not write to file \(url). \(error)")
            return false
        }
    }
}
