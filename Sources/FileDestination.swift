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

    public var logFileURL: URL?
    public var syncAfterEachWrite: Bool = false

    override public var defaultHashValue: Int {return 2}
    let fileManager = FileManager.default
    var fileHandle: FileHandle?

    public override init() {
        // platform-dependent logfile directory default
        var baseURL: URL?
        #if os(OSX)
            if let url = fileManager.urls(for:.cachesDirectory, in: .userDomainMask).first {
                baseURL = url
                // try to use ~/Library/Caches/APP NAME instead of ~/Library/Caches
                if let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleExecutable") as? String {
                    do {
                        if let appURL = baseURL?.appendingPathComponent(appName, isDirectory: true) {
                            try fileManager.createDirectory(at: appURL,
                                                            withIntermediateDirectories: true, attributes: nil)
                            baseURL = appURL
                        }
                    } catch {
                        print("Warning! Could not create folder /Library/Caches/\(appName)")
                    }
                }
            }
        #else
            #if os(Linux)
                baseURL = URL(fileURLWithPath: "/var/cache")
            #else
                // iOS, watchOS, etc. are using the caches directory
                if let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
                    baseURL = url
                }
            #endif
        #endif

        if let baseURL = baseURL {
            logFileURL = baseURL.appendingPathComponent("swiftybeaver.log", isDirectory: false)
        }
        super.init()

        // bash font color, first value is intensity, second is color
        // see http://bit.ly/1Otu3Zr & for syntax http://bit.ly/1Tp6Fw9
        // uses the 256-color table from http://bit.ly/1W1qJuH
        reset = "\u{001b}[0m"
        escape = "\u{001b}[38;5;"
        levelColor.verbose = "251m"     // silver
        levelColor.debug = "35m"        // green
        levelColor.info = "38m"         // blue
        levelColor.warning = "178m"     // yellow
        levelColor.error = "197m"       // red
    }

    // append to file. uses full base class functionality
    override public func send(_ level: SwiftyBeaver.Level, msg: String, thread: String,
        file: String, function: String, line: Int, context: Any? = nil) -> String? {
        let formattedString = super.send(level, msg: msg, thread: thread, file: file, function: function, line: line, context: context)

        if let str = formattedString {
            _ = saveToFile(str: str)
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
            if fileManager.fileExists(atPath: url.path) == false {
                // create file if not existing
                let line = str + "\n"
                try line.write(to: url, atomically: true, encoding: .utf8)
                
                #if os(iOS) || os(watchOS)
                if #available(iOS 10.0, watchOS 3.0, *) {
                    var attributes = try fileManager.attributesOfItem(atPath: url.path)
                    attributes[FileAttributeKey.protectionKey] = FileProtectionType.none
                    try fileManager.setAttributes(attributes, ofItemAtPath: url.path)
                }
                #endif
            } else {
                // append to end of file
                if fileHandle == nil {
                    // initial setting of file handle
                    fileHandle = try FileHandle(forWritingTo: url as URL)
                }
                if let fileHandle = fileHandle {
                    _ = fileHandle.seekToEndOfFile()
                    let line = str + "\n"
                    if let data = line.data(using: String.Encoding.utf8) {
                        fileHandle.write(data)
                        if syncAfterEachWrite {
                            fileHandle.synchronizeFile()
                        }
                    }
                }
            }
            return true
        } catch {
            print("SwiftyBeaver File Destination could not write to file \(url).")
            return false
        }
    }

    /// deletes log file.
    /// returns true if file was removed or does not exist, false otherwise
    public func deleteLogFile() -> Bool {
        guard let url = logFileURL, fileManager.fileExists(atPath: url.path) == true else { return true }
        do {
            try fileManager.removeItem(at: url)
            fileHandle = nil
            return true
        } catch {
            print("SwiftyBeaver File Destination could not remove file \(url).")
            return false
        }
    }
}
