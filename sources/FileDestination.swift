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
    public let ioQueue = DispatchQueue(label: "com.SwiftyBeaver.SwiftyBeaver.logfileIO", attributes: .serial)

    override public var defaultHashValue: Int {return 2}

    let fileManager = FileManager.default
    var fileHandle: FileHandle? = nil


    public convenience init(at path: String){
        let url = URL(fileURLWithPath: path)
        self.init(at: url)
    }

    public init(at url: URL) {

        super.init()
        guard let url = try? createFile(at: url) else {
            fatalError("No valid file location provided")
        }

        logFileURL = url

        initializeColors()
        initializeIO()
    }

    public override init() {
        super.init()
        guard let url = try? createFile() else {
            fatalError("No valid file location provided")
        }

        logFileURL = url
        initializeColors()
        initializeIO()
    }


    func initializeIO(){
        fileHandle = try! FileHandle(forWritingTo: logFileURL as! URL)
    }

    func write(string: String){
        let value = string + "\n"

        ioQueue.async {
            self.fileHandle!.seekToEndOfFile()
            self.fileHandle!.write(value.data(using: .utf8)!)
        }
    }


    func initializeColors(){
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


    public func createFile(at url: URL? = nil) throws -> URL?{

        let result: URL
        if OS == "OSX" {

            guard let url = url ?? macOSDefaultLogfileUrl, let logFileURL = createMacOSFile(at: url) else{
                fatalError("No valid file location provided")
            }

            result = logFileURL

        } else {
            guard let url = url ?? deviceDefaultLogfileUrl, let logFileURL = createDeviceFile(at: url) else{
                fatalError("No valid file location provided")
            }

            result = logFileURL
        }

        return result
    }

    @available(iOS 8.0, watchOS 3.0, tvOS 2.0, *)
    public func createDeviceFile(at url: URL) -> URL?{

        guard let _ = try? createDirectory(at: url.deletingLastPathComponent()) else {
            return nil
        }

        return url
        
    }

    @available(iOS 8.0, watchOS 3.0, tvOS 2.0, *)
    public lazy var deviceCacheDirUrl: URL? = {
        // for now this is the same as macOSCacheDirUrl
        // but we split it out for possible maintenance/refactor needs later.
        guard let url = self.fileManager.urlsForDirectory(.cachesDirectory, inDomains: .userDomainMask).first else {
            return nil
        }

        return url
    }()


    @available(iOS 8.0, watchOS 3.0, tvOS 2.0, *)
    public lazy var deviceDefaultLogfileUrl: URL? = {

        guard let cacheDirUrl = self.deviceCacheDirUrl else {
            return nil
        }

        guard let logFileUrl = try? cacheDirUrl.appendingPathComponent("swiftybeaver.log", isDirectory: false) else {
            return nil
        }

        return logFileUrl
    }()

    @available(OSX 10.11, *)
    public func createMacOSFile(at url: URL) -> URL?{

        guard let _ = try? createDirectory(at: url.deletingLastPathComponent()) else {
            return nil
        }

        return url
        
    }

    @available(OSX 10.11, *)
    public lazy var macOSDefaultLogfileUrl: URL? = {

        let appName = self.macOSAppName
        let logFileDir: URL

        guard let cacheDirUrl = self.macOSCacheDirUrl else {
            print("Unable to locate macOS Cache Dir")
            return nil
        }


        if let appName = self.macOSAppName, let appLogFileDir = try? cacheDirUrl.appendingPathComponent(appName, isDirectory: true){
            logFileDir = appLogFileDir
        } else {
            logFileDir = cacheDirUrl
        }

        guard let logFileUrl = try? logFileDir.appendingPathComponent("swiftybeaver.log", isDirectory: false) else {
            return nil
        }

        return logFileUrl
    }()

    @available(OSX 10.11, *)
    public lazy var macOSCacheDirUrl: URL? = {
        guard let url = self.fileManager.urlsForDirectory(.cachesDirectory, inDomains: .userDomainMask).first else {
            return nil
        }

        return url
    }()

    @available(OSX 10.11, *)
    public lazy var macOSAppName: String? = {

        guard let name = Bundle.main.objectForInfoDictionaryKey("CFBundleExecutable") as? String else {
            return nil
        }

        return name
    }()


    @discardableResult
    public func createDirectory(at url: URL) throws -> URL {
        do {
                try fileManager.createDirectory(
                    at: url,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
        } catch let error as NSError {
            print("Warning! Could not create folder '\(url)'. \(error)")
            throw error
        }

        return url
    }



    // append to file. uses full base class functionality
    override public func send(_ level: SwiftyBeaver.Level, msg: String, thread: String,
        path: String, function: String, line: Int) -> String? {
        let formattedString = super.send(level, msg: msg, thread: thread, path: path, function: function, line: line)

        if let str = formattedString {
            write(string: str)
        }
        return formattedString
    }

    deinit {
        // close file handle if set
        if let fileHandle = fileHandle {
            fileHandle.closeFile()
        }
    }

}
