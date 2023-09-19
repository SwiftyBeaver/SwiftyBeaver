//
//  FileDestination.swift
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger on 05.12.15.
//  Copyright © 2015 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation

open class FileDestination: BaseDestination {

    public var logFileURL: URL?
    public var syncAfterEachWrite: Bool = false
    public var colored: Bool = false {
        didSet {
            if colored {
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
            } else {
                reset = ""
                escape = ""
                levelColor.verbose = ""
                levelColor.debug = ""
                levelColor.info = ""
                levelColor.warning = ""
                levelColor.error = ""
            }
        }
    }
    
    // LOGFILE ROTATION
    // ho many bytes should a logfile have until it is rotated?
    // default is 5 MB. Just is used if logFileAmount > 1
    public var logFileMaxSize = (5 * 1024 * 1024)
    // Number of log files used in rotation, default is 1 which deactivates file rotation
    public var logFileAmount = 1

    override public var defaultHashValue: Int {return 2}
    let fileManager = FileManager.default


    public init(logFileURL: URL? = nil) {
        if let logFileURL = logFileURL {
            self.logFileURL = logFileURL
            super.init()
            return
        }

        // platform-dependent logfile directory default
        var baseURL: URL?
        #if os(OSX)
            if let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
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
            self.logFileURL = baseURL.appendingPathComponent("swiftybeaver.log", isDirectory: false)
        }
        super.init()
    }

    // append to file. uses full base class functionality
    override open func send(_ level: SwiftyBeaver.Level, msg: String, thread: String,
        file: String, function: String, line: Int, context: Any? = nil) -> String? {
        let formattedString = super.send(level, msg: msg, thread: thread, file: file, function: function, line: line, context: context)

        if let str = formattedString {
            _ = validateSaveFile(str: str)
        }
        return formattedString
    }
    
    // check if filesize is bigger than wanted and if yes then rotate them
    func validateSaveFile(str: String) -> Bool {
        if self.logFileAmount > 1 {
            guard let url = logFileURL else { return false }
            let filePath = url.path
            if FileManager.default.fileExists(atPath: filePath) == true {
                do {
                    // Get file size
                    let attr = try FileManager.default.attributesOfItem(atPath: filePath)
                    let fileSize = attr[FileAttributeKey.size] as! UInt64
                    // Do file rotation
                    if fileSize > logFileMaxSize {
                        rotateFile(url)
                    }
                } catch {
                    print("validateSaveFile error: \(error)")
                }
            }
        }
        return saveToFile(str: str)
    }
    
    private func rotateFile(_ fileUrl: URL) {
       let filePath = fileUrl.path
       let lastIndex = (logFileAmount-1)
       let firstIndex = 1
       do {
           for index in stride(from: lastIndex, through: firstIndex, by: -1) {
               let oldFile = makeRotatedFileUrl(fileUrl, index: index).path

               if FileManager.default.fileExists(atPath: oldFile) {
                   if index == lastIndex {
                       // Delete the last file
                       try FileManager.default.removeItem(atPath: oldFile)
                   } else {
                       // Move the current file to next index
                       let newFile = makeRotatedFileUrl(fileUrl, index: index + 1).path
                       try FileManager.default.moveItem(atPath: oldFile, toPath: newFile)
                   }
               }
           }
        
           // Finally, move the current file
           let newFile = makeRotatedFileUrl(fileUrl, index: firstIndex).path
           try FileManager.default.moveItem(atPath: filePath, toPath: newFile)
       } catch {
           print("rotateFile error: \(error)")
       }
    }
    
    private func makeRotatedFileUrl(_ fileUrl: URL, index: Int) -> URL {
        // The index is appended to the file name, to preserve the original extension.
        fileUrl.deletingPathExtension()
            .appendingPathExtension("\(index).\(fileUrl.pathExtension)")
    }

    /// appends a string as line to a file.
    /// returns boolean about success
    func saveToFile(str: String) -> Bool {
        guard let url = logFileURL else { return false }

        let line = str + "\n"
        guard let data = line.data(using: String.Encoding.utf8) else { return false }

        return write(data: data, to: url)
    }

    private func write(data: Data, to url: URL) -> Bool {
        
        #if os(Linux)
            return true
        #else
        var success = false
        let coordinator = NSFileCoordinator(filePresenter: nil)
        var error: NSError?
        coordinator.coordinate(writingItemAt: url, error: &error) { url in
            do {
                if fileManager.fileExists(atPath: url.path) == false {

                    let directoryURL = url.deletingLastPathComponent()
                    if fileManager.fileExists(atPath: directoryURL.path) == false {
                        try fileManager.createDirectory(
                            at: directoryURL,
                            withIntermediateDirectories: true
                        )
                    }
                    fileManager.createFile(atPath: url.path, contents: nil)

                    #if os(iOS) || os(watchOS)
                    if #available(iOS 10.0, watchOS 3.0, *) {
                        var attributes = try fileManager.attributesOfItem(atPath: url.path)
                        attributes[FileAttributeKey.protectionKey] = FileProtectionType.none
                        try fileManager.setAttributes(attributes, ofItemAtPath: url.path)
                    }
                    #endif
                }

                let fileHandle = try FileHandle(forWritingTo: url)
                fileHandle.seekToEndOfFile()
                if #available(iOS 13.4, watchOS 6.2, tvOS 13.4, macOS 10.15.4, *) {
                    try fileHandle.write(contentsOf: data)
                } else {
                    fileHandle.write(data)
                }
                if syncAfterEachWrite {
                    fileHandle.synchronizeFile()
                }
                fileHandle.closeFile()
                success = true
            } catch {
                print("SwiftyBeaver File Destination could not write to file \(url).")
            }
        }

        if let error = error {
            print("Failed writing file with error: \(String(describing: error))")
            return false
        }

        return success
        #endif
    }

    /// deletes log file.
    /// returns true if file was removed or does not exist, false otherwise
    public func deleteLogFile() -> Bool {
        guard let url = logFileURL, fileManager.fileExists(atPath: url.path) == true else { return true }
        do {
            try fileManager.removeItem(at: url)
            return true
        } catch {
            print("SwiftyBeaver File Destination could not remove file \(url).")
            return false
        }
    }
}
