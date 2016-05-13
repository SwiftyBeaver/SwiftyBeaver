//
//  SBPlatformDestination
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger on 22.01.16.
//  Copyright © 2016 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation

// platform-dependent import frameworks to get device details
// valid values for os(): OSX, iOS, watchOS, tvOS, Linux
#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
    var DEVICE_MODEL: String {
        get {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8 where value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            return identifier
        }
    }
#else
    let DEVICE_MODEL = ""
#endif

#if os(iOS) || os(tvOS)
    #if swift(>=3.0)
        var DEVICE_NAME = UIDevice.current().name
    #else
        var DEVICE_NAME = UIDevice.currentDevice().name
    #endif
#else
    // under watchOS UIDevice is not existing, http://apple.co/26ch5J1
    let DEVICE_NAME = ""
#endif


public class SBPlatformDestination: BaseDestination {

    public var appID = ""
    public var appSecret = ""
    public var encryptionKey = ""
    public var analyticsUserName = "" // user email, ID, name, etc.
    public var analyticsUUID: String {
        get {
            return uuid
        }
    }

    // when to send to server
    public struct SendingPoints {
        public var Verbose = 0
        public var Debug = 1
        public var Info = 5
        public var Warning = 8
        public var Error = 10
        public var Threshold = 10  // send to server if points reach that value
    }
    public var sendingPoints = SendingPoints()
    public var showNSLog = false // executes toNSLog statements to debug the class
    var points = 0

    public var serverURL = NSURL(string: "https://api.swiftybeaver.com/api/entries/")!
    private let maxAllowedThreshold = 1000  // over-rules SendingPoints.Threshold
    private var sendingInProgress = false
    private var initialSending = true

    var entriesFileURL = NSURL()
    var sendingFileURL = NSURL()
    var analyticsFileURL = NSURL()

    // analytics
    var uuid = ""

    // destination
    override public var defaultHashValue: Int {return 3}
    #if swift(>=3.0)
    let fileManager = NSFileManager.default()
    #else
    let fileManager = NSFileManager.defaultManager()
    #endif
    let isoDateFormatter = NSDateFormatter()


    public init(appID: String, appSecret: String, encryptionKey: String) {
        super.init()
        self.appID = appID
        self.appSecret = appSecret
        self.encryptionKey = encryptionKey

        // setup where to write the json files
        var baseURL: NSURL?
        if OS == "OSX" {
            #if swift(>=3.0)
            if let url = fileManager.urlsForDirectory(.applicationSupportDirectory, inDomains: .userDomainMask).first {
                baseURL = url
            }
            #else
            if let url = fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask).first {
                baseURL = url
            }
            #endif

        } else {
            // iOS, watchOS, etc. are using the document directory of the app
            #if swift(>=3.0)
            if let url = fileManager.urlsForDirectory(.documentDirectory, inDomains: .userDomainMask).first {
                baseURL = url
            }
            #else
            if let url = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first {
                baseURL = url
            }
            #endif

        }

        if let baseURL = baseURL {
            #if swift(>=3.0)
            entriesFileURL = baseURL.appendingPathComponent("sbplatform_entries.json", isDirectory: false)
            sendingFileURL = baseURL.appendingPathComponent("sbplatform_entries_sending.json", isDirectory: false)
            analyticsFileURL = baseURL.appendingPathComponent("sbplatform_analytics.json", isDirectory: false)
                
            // get, update loaded and save analytics data to file on start
            let dict = analytics(analyticsFileURL, update: true)
            #else
            entriesFileURL = baseURL.URLByAppendingPathComponent("sbplatform_entries.json", isDirectory: false)
            sendingFileURL = baseURL.URLByAppendingPathComponent("sbplatform_entries_sending.json", isDirectory: false)
            analyticsFileURL = baseURL.URLByAppendingPathComponent("sbplatform_analytics.json", isDirectory: false)
                
            // get, update loaded and save analytics data to file on start
            let dict = analytics(analyticsFileURL, update: true)
            #endif
            saveDictToFile(dict, url: analyticsFileURL)
        }
    }


    // append to file, each line is a JSON dict
    #if swift(>=3.0)
    override public func send(_ level: SwiftyBeaver.Level, msg: String, thread: String,
        path: String, function: String, line: Int) -> String? {

        var jsonString: String?

        let dict: [String: AnyObject] = [
            "timestamp": NSDate().timeIntervalSince1970 as AnyObject,
            "level": level.rawValue as AnyObject,
            "message": msg as AnyObject,
            "thread": thread as AnyObject,
            "fileName": path.components(separatedBy: "/").last! as AnyObject,
            "function": function as AnyObject,
            "line":line as AnyObject]
        
        jsonString = jsonStringFromDict(dict)
        
        if let str = jsonString {
            toNSLog("saving '\(msg)' to file")
            saveToFile(str, url: entriesFileURL)
            //toNSLog(entriesFileURL.path!)
            
            // now decide if the stored log entries should be sent to the server
            // add level points to current points amount and send to server if threshold is hit
            let newPoints = sendingPointsForLevel(level)
            points += newPoints
            toNSLog("current sending points: \(points)")
            
            if points >= sendingPoints.Threshold || points > maxAllowedThreshold {
                toNSLog("\(points) points is >= threshold")
                // above threshold, send to server
                sendNow()
                
            } else if initialSending {
                initialSending = false
                // first logging at this session
                // send if json file still contains old log entries
                if let logEntries = logsFromFile(entriesFileURL) {
                    let lines = logEntries.count
                    if lines > 1 {
                        var msg = "initialSending: \(points) points is below threshold "
                        msg += "but json file already has \(lines) lines."
                        toNSLog(msg)
                        sendNow()
                    }
                }
            }
        }

        return jsonString
    }
    #else
    override public func send(level: SwiftyBeaver.Level, msg: String, thread: String,
        path: String, function: String, line: Int) -> String? {

        var jsonString: String?

        let dict: [String: AnyObject] = [
            "timestamp": NSDate().timeIntervalSince1970,
            "level": level.rawValue,
            "message": msg,
            "thread": thread,
            "fileName": path.componentsSeparatedByString("/").last!,
            "function": function,
            "line":line]
        
        jsonString = jsonStringFromDict(dict)
        
        if let str = jsonString {
            toNSLog("saving '\(msg)' to file")
            saveToFile(str, url: entriesFileURL)
            //toNSLog(entriesFileURL.path!)
            
            // now decide if the stored log entries should be sent to the server
            // add level points to current points amount and send to server if threshold is hit
            let newPoints = sendingPointsForLevel(level)
            points += newPoints
            toNSLog("current sending points: \(points)")
            
            if points >= sendingPoints.Threshold || points > maxAllowedThreshold {
                toNSLog("\(points) points is >= threshold")
                // above threshold, send to server
                sendNow()
                
            } else if initialSending {
                initialSending = false
                // first logging at this session
                // send if json file still contains old log entries
                if let logEntries = logsFromFile(entriesFileURL) {
                    let lines = logEntries.count
                    if lines > 1 {
                        var msg = "initialSending: \(points) points is below threshold "
                        msg += "but json file already has \(lines) lines."
                        toNSLog(msg)
                        sendNow()
                    }
                }
            }
        }

        return jsonString
    }
    #endif


    // MARK: Send-to-Server Logic

    /// does a (manual) sending attempt of all unsent log entries to SwiftyBeaver Platform
    public func sendNow() {

        if sendFileExists() {
            toNSLog("reset points to 0")
            points = 0
        } else {
            if !renameJsonToSendFile() {
                return
            }
        }

        if !sendingInProgress {
            sendingInProgress = true
            //let (jsonString, lines) = logsFromFile(sendingFileURL)
            var lines = 0
            
            guard let logEntries = logsFromFile(sendingFileURL) else {
                sendingInProgress = false
                return
            }
            
            lines = logEntries.count


            if lines > 0 {
                var payload = [String:AnyObject]()
                // merge device and analytics dictionaries
                let deviceDetailsDict = deviceDetails()
                
                var analyticsDict = analytics(analyticsFileURL)

                #if swift(>=3.0)
                for key in deviceDetailsDict.keys {
                    analyticsDict[key] = deviceDetailsDict[key] as AnyObject?
                }
                payload["device"] = analyticsDict as AnyObject
                payload["entries"] = logEntries as AnyObject
                #else
                for key in deviceDetailsDict.keys {
                    analyticsDict[key] = deviceDetailsDict[key]
                }
                payload["device"] = analyticsDict
                payload["entries"] = logEntries
                #endif
                
                if let str = jsonStringFromDict(payload) {
                    //toNSLog(str)  // uncomment to see full payload
                    toNSLog("Encrypting \(lines) log entries ...")
                    if let encryptedStr = encrypt(str) {
                        var msg = "Sending \(lines) encrypted log entries "
                        msg += "(\(encryptedStr.characters.count) chars) to server ..."
                        toNSLog(msg)
                        //toNSLog("Sending \(encryptedStr) ...")
                        
                        sendToServerAsync(encryptedStr) {
                            ok, status in
                            
                            self.toNSLog("Sent \(lines) encrypted log entries to server, received ok: \(ok)")
                            if ok {
                                self.deleteFile(self.sendingFileURL)
                            }
                            self.sendingInProgress = false
                            self.points = 0
                        }
                    }
                }
            } else {
                sendingInProgress = false
            }
        }
    }

    /// sends a string to the SwiftyBeaver Platform server, returns ok if status 200 and HTTP status
    
    #if swift(>=3.0)
    func sendToServerAsync(_ str: String?, complete: (ok: Bool, status: Int) -> ()) {

        if let payload = str, let queue = self.queue {

            // create operation queue which uses current serial queue of destination
            let operationQueue = NSOperationQueue()
            operationQueue.underlyingQueue = queue

            let session = NSURLSession(configuration:
                NSURLSessionConfiguration.default(),
                delegate: nil, delegateQueue: operationQueue)

            // assemble request
            let request = NSMutableURLRequest(url: serverURL)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            // basic auth header
            let credentials = "\(appID):\(appSecret)".data(using: NSUTF8StringEncoding)!
            let base64Credentials = credentials.base64EncodedString([])
            request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")

            // POST parameters
            let params = ["payload": payload]
            do {
                request.httpBody = try NSJSONSerialization.data(withJSONObject: params as AnyObject, options: [])
            } catch let error as NSError {
                toNSLog("Error! Could not create JSON for server payload. \(error)")
            }
            //toNSLog("sending params: \(params)")
            //toNSLog("\n\nbefore sendToServer on thread '\(threadName())'")

            sendingInProgress = true
            // send request async to server on destination queue
            let task = session.dataTask(with: request) {
                _, response, error in
                var ok = false
                var status = 0
                //toNSLog("callback of sendToServer on thread '\(self.threadName())'")

                if let error = error {
                    // an error did occur
                    self.toNSLog("Error! Could not send entries to server. \(error)")
                } else {
                    if let response = response as? NSHTTPURLResponse {
                        status = response.statusCode
                        if status == 200 {
                            // all went well, entries were uploaded to server
                            ok = true
                        } else {
                            // status code was not 200
                            var msg = "Error! Sending entries to server failed "
                            msg += "with status code \(status)"
                            self.toNSLog(msg)
                        }
                    }
                }
                return complete(ok: ok, status: status)
            }
            task.resume()
        }
    }
    #else
    func sendToServerAsync(str: String?, complete: (ok: Bool, status: Int) -> ()) {
        
        if let payload = str, let queue = self.queue {
            
            // create operation queue which uses current serial queue of destination
            let operationQueue = NSOperationQueue()
            operationQueue.underlyingQueue = queue
            
            let session = NSURLSession(configuration:
                NSURLSessionConfiguration.defaultSessionConfiguration(),
                                       delegate: nil, delegateQueue: operationQueue)
            
            // assemble request
            let request = NSMutableURLRequest(URL: serverURL)
            request.HTTPMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            // basic auth header
            let credentials = "\(appID):\(appSecret)".dataUsingEncoding(NSUTF8StringEncoding)!
            let base64Credentials = credentials.base64EncodedStringWithOptions([])
            request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
            
            // POST parameters
            let params = ["payload": payload]
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
            } catch let error as NSError {
                toNSLog("Error! Could not create JSON for server payload. \(error)")
            }
            //toNSLog("sending params: \(params)")
            //toNSLog("\n\nbefore sendToServer on thread '\(threadName())'")
            
            sendingInProgress = true
            // send request async to server on destination queue
            let task = session.dataTaskWithRequest(request) {
                _, response, error in
                var ok = false
                var status = 0
                //toNSLog("callback of sendToServer on thread '\(self.threadName())'")
                
                if let error = error {
                    // an error did occur
                    self.toNSLog("Error! Could not send entries to server. \(error)")
                } else {
                    if let response = response as? NSHTTPURLResponse {
                        status = response.statusCode
                        if status == 200 {
                            // all went well, entries were uploaded to server
                            ok = true
                        } else {
                            // status code was not 200
                            var msg = "Error! Sending entries to server failed "
                            msg += "with status code \(status)"
                            self.toNSLog(msg)
                        }
                    }
                }
                return complete(ok: ok, status: status)
            }
            task.resume()
        }
    }
    #endif


    /// returns sending points based on level
    #if swift(>=3.0)
    func sendingPointsForLevel(_ level: SwiftyBeaver.Level) -> Int {

        switch level {
        case SwiftyBeaver.Level.Debug:
            return sendingPoints.Debug
        case SwiftyBeaver.Level.Info:
            return sendingPoints.Info
        case SwiftyBeaver.Level.Warning:
            return sendingPoints.Warning
        case SwiftyBeaver.Level.Error:
            return sendingPoints.Error
        default:
            return sendingPoints.Verbose
        }
    }
    #else
    func sendingPointsForLevel(level: SwiftyBeaver.Level) -> Int {
        
        switch level {
        case SwiftyBeaver.Level.Debug:
            return sendingPoints.Debug
        case SwiftyBeaver.Level.Info:
            return sendingPoints.Info
        case SwiftyBeaver.Level.Warning:
            return sendingPoints.Warning
        case SwiftyBeaver.Level.Error:
            return sendingPoints.Error
        default:
            return sendingPoints.Verbose
        }
    }
    #endif


    // MARK: File Handling

    /// appends a string as line to a file.
    /// returns boolean about success
    #if swift(>=3.0)
    func saveToFile(_ str: String, url: NSURL, overwrite: Bool = false) -> Bool {
        do {
            if fileManager.fileExists(atPath: url.path!) == false || overwrite {
                // create file if not existing
                let line = str + "\n"
                try line.write(to: url, atomically: true, encoding: NSUTF8StringEncoding)
            } else {
                // append to end of file
                let fileHandle = try NSFileHandle(forWritingTo: url)
                fileHandle.seekToEndOfFile()
                let line = str + "\n"
                let data = line.data(using: NSUTF8StringEncoding)!
                fileHandle.write(data)
                fileHandle.closeFile()
            }
            return true
        } catch let error {
            toNSLog("Error! Could not write to file \(url). \(error)")
            return false
        }
    }
    #else
    func saveToFile(str: String, url: NSURL, overwrite: Bool = false) -> Bool {
        do {
            if fileManager.fileExistsAtPath(url.path!) == false || overwrite {
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
            toNSLog("Error! Could not write to file \(url). \(error)")
            return false
        }
    }
    #endif

    #if swift(>=3.0)
    func sendFileExists() -> Bool {
        return fileManager.fileExists(atPath: sendingFileURL.path!)
    }
    #else
    func sendFileExists() -> Bool {
        return fileManager.fileExistsAtPath(sendingFileURL.path!)
    }
    #endif

    #if swift(>=3.0)
    func renameJsonToSendFile() -> Bool {
        do {
            try fileManager.moveItem(at: entriesFileURL, to: sendingFileURL)
            return true
        } catch let error as NSError {
            toNSLog("SwiftyBeaver Platform Destination could not rename json file. \(error)")
            return false
        }
    }
    #else
    func renameJsonToSendFile() -> Bool {
        do {
            try fileManager.moveItemAtURL(entriesFileURL, toURL: sendingFileURL)
            return true
        } catch let error as NSError {
            toNSLog("SwiftyBeaver Platform Destination could not rename json file. \(error)")
            return false
        }
    }
    #endif

    /// returns optional array of log dicts from a file which has 1 json string per line
    #if swift(>=3.0)
    func logsFromFile(_ url: NSURL) -> [[String:AnyObject]]? {
        var lines = 0
        do {
            // try to read file, decode every JSON line and put dict from each line in array
            let fileContent = try NSString(contentsOfFile: url.path!, encoding: NSUTF8StringEncoding)
            let linesArray = fileContent.components(separatedBy: "\n")
            var dicts = [[String: AnyObject]()] // array of dictionaries
            for lineJSON in linesArray {
                lines += 1
                if lineJSON.characters.first == "{" && lineJSON.characters.last == "}" {
                    // try to parse json string into dict
                    if let data = lineJSON.data(using: NSUTF8StringEncoding) {
                        do {
                            if let dict = try NSJSONSerialization.jsonObject(with: data,
                                options: .mutableContainers) as? [String:AnyObject] {
                                if !dict.isEmpty {
                                    dicts.append(dict)
                                }
                            }
                        } catch let error {
                            var msg = "Error! Could not parse "
                            msg += "line \(lines) in file \(url). \(error)"
                            toNSLog(msg)
                        }
                    }
                }
            }
            dicts.removeFirst()
            return dicts
        } catch let error {
            toNSLog("Error! Could not read file \(url). \(error)")
        }
        return nil
    }
    #else
    func logsFromFile(url: NSURL) -> [[String:AnyObject]]? {
        var lines = 0
        do {
            // try to read file, decode every JSON line and put dict from each line in array
            let fileContent = try NSString(contentsOfFile: url.path!, encoding: NSUTF8StringEncoding)
            let linesArray = fileContent.componentsSeparatedByString("\n")
            var dicts = [[String: AnyObject]()] // array of dictionaries
            for lineJSON in linesArray {
                lines += 1
                if lineJSON.characters.first == "{" && lineJSON.characters.last == "}" {
                    // try to parse json string into dict
                    if let data = lineJSON.dataUsingEncoding(NSUTF8StringEncoding) {
                        do {
                            if let dict = try NSJSONSerialization.JSONObjectWithData(data,
                                                                                     options: .MutableContainers) as? [String:AnyObject] {
                                if !dict.isEmpty {
                                    dicts.append(dict)
                                }
                            }
                        } catch let error {
                            var msg = "Error! Could not parse "
                            msg += "line \(lines) in file \(url). \(error)"
                            toNSLog(msg)
                        }
                    }
                }
            }
            dicts.removeFirst()
            return dicts
        } catch let error {
            toNSLog("Error! Could not read file \(url). \(error)")
        }
        return nil
    }
    #endif
    

    /// returns AES-256 CBC encrypted optional string
    #if swift(>=3.0)
    func encrypt(_ str: String) -> String? {
        return AES256CBC.encryptString(str, password: encryptionKey)
    }
    #else
    func encrypt(str: String) -> String? {
        return AES256CBC.encryptString(str, password: encryptionKey)
    }
    #endif

    /// Delete file to get started again
    #if swift(>=3.0)
    func deleteFile(_ url: NSURL) -> Bool {
        do {
            try NSFileManager.default().removeItem(at: url)
            return true
        } catch let error {
            toNSLog("Warning! Could not delete file \(url). \(error)")
        }
        return false
    }
    #else
    func deleteFile(url: NSURL) -> Bool {
        do {
            try NSFileManager.defaultManager().removeItemAtURL(url)
            return true
        } catch let error {
            toNSLog("Warning! Could not delete file \(url). \(error)")
        }
        return false
    }
    #endif


    // MARK: Device & Analytics

    // returns dict with device details. Amount depends on platform
    func deviceDetails() -> [String: String] {
        var details = [String: String]()

        details["os"] = OS
        let osVersion = NSProcessInfo.processInfo().operatingSystemVersion
        // becomes for example 10.11.2 for El Capitan
        var osVersionStr = String(osVersion.majorVersion)
        osVersionStr += "." + String(osVersion.minorVersion)
        osVersionStr += "." + String(osVersion.patchVersion)
        details["osVersion"] = osVersionStr
        details["hostName"] = NSProcessInfo.processInfo().hostName
        details["deviceName"] = ""
        details["deviceModel"] = ""

        if DEVICE_NAME != "" {
            details["deviceName"] = DEVICE_NAME
        }
        if DEVICE_MODEL != "" {
            details["deviceModel"] = DEVICE_MODEL
        }
        return details
    }

    /// returns (updated) analytics dict, optionally loaded from file.
    #if swift(>=3.0)
    func analytics(_ url: NSURL, update: Bool = false) -> [String:AnyObject] {

        var dict = [String:AnyObject]()
        let now = NSDate().timeIntervalSince1970

        uuid =  NSUUID().uuidString
        dict["uuid"] = uuid as AnyObject
        dict["firstStart"] = now as AnyObject
        dict["lastStart"] = now as AnyObject
        dict["starts"] = 1 
        dict["userName"] = analyticsUserName as AnyObject
        dict["firstAppVersion"] = appVersion() as AnyObject
        dict["appVersion"] = appVersion() as AnyObject
        dict["firstAppBuild"] = appBuild() as AnyObject
        dict["appBuild"] = appBuild() as AnyObject

        if let loadedDict = dictFromFile(analyticsFileURL) {
            if let val = loadedDict["firstStart"] as? Double {
                dict["firstStart"] = val as AnyObject?
            }
            if let val = loadedDict["lastStart"] as? Double {
                if update {
                    dict["lastStart"] = now as AnyObject
                } else {
                    dict["lastStart"] = val as AnyObject?
                }
            }
            if let val = loadedDict["starts"] as? Int {
                if update {
                    dict["starts"] = val + 1 as AnyObject?
                } else {
                    dict["starts"] = val as AnyObject?
                }
            }
            if let val = loadedDict["uuid"] as? String {
                dict["uuid"] = val as AnyObject?
                uuid = val
            }
            if let val = loadedDict["userName"] as? String {
                if update && !analyticsUserName.isEmpty {
                    dict["userName"] = analyticsUserName as AnyObject
                } else {
                    if !val.isEmpty {
                        dict["userName"] = val as AnyObject?
                    }
                }
            }
            if let val = loadedDict["firstAppVersion"] as? String {
                dict["firstAppVersion"] = val as AnyObject?
            }
            if let val = loadedDict["firstAppBuild"] as? Int {
                dict["firstAppBuild"] = val as AnyObject?
            }
        }
        return dict
    }
    #else
    func analytics(url: NSURL, update: Bool = false) -> [String:AnyObject] {
        
        var dict = [String:AnyObject]()
        let now = NSDate().timeIntervalSince1970
        
        uuid =  NSUUID().UUIDString
        dict["uuid"] = uuid
        dict["firstStart"] = now
        dict["lastStart"] = now
        dict["starts"] = 1
        dict["userName"] = analyticsUserName
        dict["firstAppVersion"] = appVersion()
        dict["appVersion"] = appVersion()
        dict["firstAppBuild"] = appBuild()
        dict["appBuild"] = appBuild()
        
        if let loadedDict = dictFromFile(analyticsFileURL) {
            if let val = loadedDict["firstStart"] as? Double {
                dict["firstStart"] = val
            }
            if let val = loadedDict["lastStart"] as? Double {
                if update {
                    dict["lastStart"] = now
                } else {
                    dict["lastStart"] = val
                }
            }
            if let val = loadedDict["starts"] as? Int {
                if update {
                    dict["starts"] = val + 1
                } else {
                    dict["starts"] = val
                }
            }
            if let val = loadedDict["uuid"] as? String {
                dict["uuid"] = val
                uuid = val
            }
            if let val = loadedDict["userName"] as? String {
                if update && !analyticsUserName.isEmpty {
                    dict["userName"] = analyticsUserName
                } else {
                    if !val.isEmpty {
                        dict["userName"] = val
                    }
                }
            }
            if let val = loadedDict["firstAppVersion"] as? String {
                dict["firstAppVersion"] = val
            }
            if let val = loadedDict["firstAppBuild"] as? Int {
                dict["firstAppBuild"] = val
            }
        }
        return dict
    }
    #endif

    /// Returns the current app version string (like 1.2.5) or empty string on error
    func appVersion() -> String {
        #if swift(>=3.0)
        if let version = NSBundle.main().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
                return version
        }
        #else
        if let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
            return version
        }
        #endif
        return ""
    }

    /// Returns the current app build as integer (like 563, always incrementing) or 0 on error
    func appBuild() -> Int {
        #if swift(>=3.0)
        if let version = NSBundle.main().infoDictionary?["CFBundleVersion"] as? String {
            if let intVersion = Int(version) {
                return intVersion
            }
        }
        #else
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            if let intVersion = Int(version) {
                return intVersion
            }
        }
        #endif
        return 0
    }

    // turns dict into JSON-encoded string
    #if swift(>=3.0)
    func jsonStringFromDict(_ dict: [String: AnyObject]) -> String? {
        var jsonString: String?
        // try to create JSON string
        do {
            let jsonData = try NSJSONSerialization.data(withJSONObject: dict as AnyObject, options: [])
            if let str = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as? String {
                jsonString = str
            }
        } catch let error as NSError {
            toNSLog("SwiftyBeaver Platform Destination could not create JSON from dict. \(error)")
        }
        return jsonString
    }
    #else
    func jsonStringFromDict(dict: [String: AnyObject]) -> String? {
        var jsonString: String?
        // try to create JSON string
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(dict, options: [])
            if let str = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as? String {
                jsonString = str
            }
        } catch let error as NSError {
            toNSLog("SwiftyBeaver Platform Destination could not create JSON from dict. \(error)")
        }
        return jsonString
    }
    #endif

    /// returns optional dict from a json encoded file
    #if swift(>=3.0)
    func dictFromFile(_ url: NSURL) -> [String:AnyObject]? {
        do {
            // try to read file, decode every JSON line and put dict from each line in array
            let fileContent = try NSString(contentsOfFile: url.path!, encoding: NSUTF8StringEncoding)
            // try to parse json string into dict
            if let data = fileContent.data(using: NSUTF8StringEncoding) {
                do {
                    return try NSJSONSerialization.jsonObject(with: data,
                        options: .mutableContainers) as? [String:AnyObject]
                } catch let error {
                    toNSLog("SwiftyBeaver Platform Destination could not parse file \(url). \(error)")
                }
            }
        } catch let error {
            toNSLog("SwiftyBeaver Platform Destination could not read file \(url). \(error)")
        }
        return nil
    }
    #else
    func dictFromFile(url: NSURL) -> [String:AnyObject]? {
        do {
            // try to read file, decode every JSON line and put dict from each line in array
            let fileContent = try NSString(contentsOfFile: url.path!, encoding: NSUTF8StringEncoding)
            // try to parse json string into dict
            if let data = fileContent.dataUsingEncoding(NSUTF8StringEncoding) {
                do {
                    return try NSJSONSerialization.JSONObjectWithData(data,
                                                                      options: .MutableContainers) as? [String:AnyObject]
                } catch let error {
                    toNSLog("SwiftyBeaver Platform Destination could not parse file \(url). \(error)")
                }
            }
        } catch let error {
            toNSLog("SwiftyBeaver Platform Destination could not read file \(url). \(error)")
        }
        return nil
    }
    #endif

    // turns dict into JSON and saves it to file
    #if swift(>=3.0)
    func saveDictToFile(_ dict: [String: AnyObject], url: NSURL) -> Bool {
        let jsonString = jsonStringFromDict(dict)

        if let str = jsonString {
            toNSLog("saving '\(str)' to \(url)")
            return saveToFile(str, url: url, overwrite: true)
        }
        return false
    }
    #else
    func saveDictToFile(dict: [String: AnyObject], url: NSURL) -> Bool {
        let jsonString = jsonStringFromDict(dict)
        
        if let str = jsonString {
            toNSLog("saving '\(str)' to \(url)")
            return saveToFile(str, url: url, overwrite: true)
        }
        return false
    }
    #endif
    



    // MARK: Debug Helpers

    /// log String to toNSLog. Used to debug the class logic
    #if swift(>=3.0)
    func toNSLog(_ str: String) {
        if showNSLog {
            NSLog("SBPlatform: \(str)")
        }
    }
    #else
    func toNSLog(str: String) {
        if showNSLog {
            NSLog("SBPlatform: \(str)")
        }
    }
    #endif

    /// helper function for thread logging during development
    #if swift(>=3.0)
    // Swift 3 Semantic Change. 
    // This function is already available as the class function SwiftyBeaver.threadName()
    #else
    func threadName() -> String {
        if NSThread.isMainThread() {
            return "main"
        } else {
            if let threadName = NSThread.currentThread().name where !threadName.isEmpty {
                return threadName
            } else if let queueName = String(UTF8String:
                dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)) where !queueName.isEmpty {
                return queueName
            } else {
                return String(format: "%p", NSThread.currentThread())
            }
        }
    }
    #endif
}
