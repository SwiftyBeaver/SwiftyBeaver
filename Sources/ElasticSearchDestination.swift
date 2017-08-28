//
//  SBPlatformDestination
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger on 22.01.16.
//  Copyright © 2016 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation

public class ElasticSearchDestination: BaseDestination {
    public var analyticsUserName = "" // user email, ID, name, etc.
    public var analyticsUUID: String { return uuid }
    
    // when to send to server
    public struct SendingPoints {
        public var verbose = 0
        public var debug = 1
        public var info = 5
        public var warning = 8
        public var error = 10
        public var threshold = 10  // send to server if points reach that value
    }
    public var sendingPoints = SendingPoints()
    public var showNSLog = false // executes toNSLog statements to debug the class
    var points = 0

    public var esServerURL: URL
    private var esLogIndex: String
    private var esAnalyticsIndex: String
    
    public var entriesFileURL = URL(fileURLWithPath: "") // not optional
    public var sendingFileURL = URL(fileURLWithPath: "")
    public var analyticsFileURL = URL(fileURLWithPath: "")

    private let minAllowedThreshold = 1  // over-rules SendingPoints.Threshold
    private let maxAllowedThreshold = 1000  // over-rules SendingPoints.Threshold
    private var sendingInProgress = false
    private var initialSending = true

    // analytics
    var uuid = ""

    // destination
    override public var defaultHashValue: Int {return 3}
    let fileManager = FileManager.default
    let isoDateFormatter = DateFormatter()

    /// init platform with default internal filenames
    public init(esServerURL: URL, esLogIndex: String = "sblog", esAnalyticsIndex: String = "sbanalytics",
        entriesFileName: String = "elasticsearch_entries.json",
        sendingfileName: String = "elasticsearch_entries_sending.json",
        analyticsFileName: String = "elasticsearch_analytics.json") {
        self.esServerURL = esServerURL.appendingPathComponent("_bulk")  // use bulk api
        self.esLogIndex = esLogIndex.lowercased()       // elasticsearch index must be all lower case
        self.esAnalyticsIndex = esAnalyticsIndex.lowercased()       // index must be all lower case
        super.init()

        // setup where to write the json files
        var baseURL: URL?
        #if os(OSX)
            if let url = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                baseURL = url
                // try to use ~/Library/Application Support/APP NAME instead of ~/Library/Application Support
                if let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleExecutable") as? String {
                    do {
                        if let appURL = baseURL?.appendingPathComponent(appName, isDirectory: true) {
                            try fileManager.createDirectory(at: appURL,
                                                            withIntermediateDirectories: true, attributes: nil)
                            baseURL = appURL
                        }
                    } catch {
                        // it is too early in the class lifetime to be able to use toNSLog()
                        print("Warning! Could not create folder ~/Library/Application Support/\(appName).")
                    }
                }
            }
        #else
            #if os(tvOS)
                // tvOS can just use the caches directory
                if let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
                    baseURL = url
                }
            #elseif os(Linux)
                // Linux is using /var/cache
                let baseDir = "/var/cache/"
                entriesFileURL = URL(fileURLWithPath: baseDir + entriesFileName)
                sendingFileURL = URL(fileURLWithPath: baseDir + sendingfileName)
                analyticsFileURL = URL(fileURLWithPath: baseDir + analyticsFileName)
            #else
                // iOS and watchOS are using the app’s document directory
                if let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                    baseURL = url
                }
            #endif
        #endif

        #if os(Linux)
            // get, update loaded and save analytics data to file on start
            let dict = analytics(analyticsFileURL, update: true)
            _ = saveDictToFile(dict, url: analyticsFileURL)
        #else
            if let baseURL = baseURL {
                // is just set for everything but not Linux
                entriesFileURL = baseURL.appendingPathComponent(entriesFileName,
                                                                isDirectory: false)
                sendingFileURL = baseURL.appendingPathComponent(sendingfileName,
                                                                isDirectory: false)
                analyticsFileURL = baseURL.appendingPathComponent(analyticsFileName,
                                                                  isDirectory: false)

                // get, update loaded and save analytics data to file on start
                let dict = analytics(analyticsFileURL, update: true)
                _ = saveDictToFile(dict, url: analyticsFileURL)
            }
        #endif
    }

    // append to file, each line is a JSON dict
    override public func send(_ level: SwiftyBeaver.Level, msg: String, thread: String,
        file: String, function: String, line: Int, context: Any? = nil) -> String? {

        var jsonString: String?

        let dict: [String: Any] = [
            "uuid": analyticsUUID,
            "timestamp": Date().timeIntervalSince1970,
            "level": level.rawValue,
            "message": msg,
            "thread": thread,
            "fileName": file.components(separatedBy: "/").last!,
            "function": function,
            "line": line]

        jsonString = jsonStringFromDict(dict)

        if let str = jsonString {
            toNSLog("saving '\(msg)' to \(entriesFileURL)")
            _ = saveToFile(str, url: entriesFileURL)
            //toNSLog(entriesFileURL.path!)

            // now decide if the stored log entries should be sent to the server
            // add level points to current points amount and send to server if threshold is hit
            let newPoints = sendingPointsForLevel(level)
            points += newPoints
            toNSLog("current sending points: \(points)")

            if (points >= sendingPoints.threshold && points >= minAllowedThreshold) || points > maxAllowedThreshold {
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
                var payload = [String: Any]()
                // merge device and analytics dictionaries
                let deviceDetailsDict = deviceDetails()

                var analyticsDict = analytics(analyticsFileURL)

                for key in deviceDetailsDict.keys {
                    analyticsDict[key] = deviceDetailsDict[key]
                }
                payload["device"] = analyticsDict
                payload["entries"] = logEntries

                if let str = elasticBulkCmdFromDict(payload) {
//                    toNSLog(str)  // uncomment to see full payload
//                    toNSLog("Encrypting \(lines) log entries ...")
                    var msg = "Sending \(lines) log entries "
                    msg += "(\(str.characters.count) chars) to server ..."
                    toNSLog(msg)
                    //toNSLog("Sending \(encryptedStr) ...")
                    
                    sendToServerAsync(str) { ok, _ in
                        
                        self.toNSLog("Sent \(lines) log entries to server, received ok: \(ok)")
                        if ok {
                            _ = self.deleteFile(self.sendingFileURL)
                        }
                        self.sendingInProgress = false
                        self.points = 0
                    }
                }
            } else {
                sendingInProgress = false
            }
        }
    }

    /// sends a string to the SwiftyBeaver Platform server, returns ok if status 200 and HTTP status
    func sendToServerAsync(_ str: String?, complete: @escaping (_ ok: Bool, _ status: Int) -> Void) {

        let timeout = 10.0

        if let payload = str, let queue = self.queue {

            // create operation queue which uses current serial queue of destination
            let operationQueue = OperationQueue()
            operationQueue.underlyingQueue = queue

            let session = URLSession(configuration:
                URLSessionConfiguration.default,
                delegate: nil, delegateQueue: operationQueue)

            toNSLog("assembling request ...")

             // assemble request
             var request = URLRequest(url: esServerURL,
                                     cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                     timeoutInterval: timeout)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            // basic auth header (just works on Linux for Swift 3.1+, macOS is fine)
//            guard let credentials = "\(appID):\(appSecret)".data(using: String.Encoding.utf8) else {
//                    toNSLog("Error! Could not set basic auth header")
//                    return complete(false, 0)
//            }
//
//            #if os(Linux)
//            let base64Credentials = Base64.encode([UInt8](credentials))
//            #else
//            let base64Credentials = credentials.base64EncodedString(options: [])
//            #endif
//            request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
            //toNSLog("\nrequest:")
            //print(request)

            // POST parameters
            request.httpBody = payload.data(using: .utf8)
   
            toNSLog("Request body: \(request.httpBody!)")

            sendingInProgress = true

            // send request async to server on destination queue
            let task = session.dataTask(with: request) { [unowned self] data, response, error in
                var ok = false
                var status = 0
                self.toNSLog("received response from server")
                
                defer {
                    complete(ok, status)
                }

                if let error = error {
                    // an error did occur
                    self.toNSLog("Error! Could not send entries to server. \(error)")
                } else {
                    if let response = response as? HTTPURLResponse {
                        status = response.statusCode
                        if status == 200 {
                            ok = true       // to prevent logging getting stuck due to misformed entry, return ok if server was reached (200)
                            // verify status codes for individual entries
                            if let data = data {
                                // TODO: provide better messaging on failure
                                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return }
                                guard let jsonDict = json as? [String: Any] else { return }
                                guard let items = jsonDict["items"] as? [[String: Any]] else { return }
                                for case let item in items {
                                    guard let index = item["index"] as? [String: Any] else { break }
                                    guard let status = index["status"] as? Int else { break }
                                    if status != 201 {
                                        self.toNSLog("Error! Failed to create entry (status code \(status))")
                                    }
                                }
                            } // end if data
                        } else {
                            // status code was not 201
                            var msg = "Error! Sending entries to server failed"
                            msg += "with status code \(status)"
                            self.toNSLog(msg)
                        }
                    }
                } // end if error
            } // end dataTask
            task.resume()
        }
    }
    
    /// turns dict into JSON-encoded string
    func elasticBulkCmdFromDict(_ dict: [String: Any]) -> String? {
        var elasticBulk: String?
        
        if let deviceInfo = dict["device"] {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: deviceInfo, options: [])
                elasticBulk = "{ \"index\": { \"_index\": \"\(esAnalyticsIndex)\", \"_type\": \"\(esAnalyticsIndex)\" } }\n"
                elasticBulk = "\(elasticBulk!)\(String(data: jsonData, encoding: .utf8) ?? "")\n"
            } catch {
                print("SwiftyBeaver could no create JSON from device info dict.")
            }
        }
        
        if let entries = dict["entries"] as? [[String: Any]] {
            for entry in entries {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: entry, options: [])
                    elasticBulk = "\(elasticBulk ?? ""){ \"index\": { \"_index\": \"\(esLogIndex)\", \"_type\": \"\(esLogIndex)\" } }\n"
                    elasticBulk = "\(elasticBulk!)\(String(data: jsonData, encoding: .utf8) ?? "")\n"
                } catch {
                    print("SwiftyBeaver could no create JSON from entries dict.")
                }
            }
        }

        return elasticBulk
    }


    /// returns sending points based on level
    func sendingPointsForLevel(_ level: SwiftyBeaver.Level) -> Int {

        switch level {
        case SwiftyBeaver.Level.debug:
            return sendingPoints.debug
        case SwiftyBeaver.Level.info:
            return sendingPoints.info
        case SwiftyBeaver.Level.warning:
            return sendingPoints.warning
        case SwiftyBeaver.Level.error:
            return sendingPoints.error
        default:
            return sendingPoints.verbose
        }
    }

    // MARK: File Handling

    /// appends a string as line to a file.
    /// returns boolean about success
    func saveToFile(_ str: String, url: URL, overwrite: Bool = false) -> Bool {
        do {
            if fileManager.fileExists(atPath: url.path) == false || overwrite {
                // create file if not existing
                let line = str + "\n"
                try line.write(to: url, atomically: true, encoding: String.Encoding.utf8)
            } else {
                // append to end of file
                let fileHandle = try FileHandle(forWritingTo: url)
                _ = fileHandle.seekToEndOfFile()
                let line = str + "\n"
                if let data = line.data(using: String.Encoding.utf8) {
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            }
            return true
        } catch {
            toNSLog("Error! Could not write to file \(url).")
            return false
        }
    }

    func sendFileExists() -> Bool {
        return fileManager.fileExists(atPath: sendingFileURL.path)
    }

    func renameJsonToSendFile() -> Bool {
        do {
            try fileManager.moveItem(at: entriesFileURL, to: sendingFileURL)
            return true
        } catch {
            toNSLog("SwiftyBeaver Platform Destination could not rename json file.")
            return false
        }
    }

    /// returns optional array of log dicts from a file which has 1 json string per line
    func logsFromFile(_ url: URL) -> [[String:Any]]? {
        var lines = 0
        do {
            // try to read file, decode every JSON line and put dict from each line in array
            let fileContent = try String(contentsOfFile: url.path, encoding: .utf8)
            let linesArray = fileContent.components(separatedBy: "\n")
            var dicts = [[String: Any]()] // array of dictionaries
            for lineJSON in linesArray {
                lines += 1
                if lineJSON.characters.first == "{" && lineJSON.characters.last == "}" {
                    // try to parse json string into dict
                    if let data = lineJSON.data(using: .utf8) {
                        do {
                            if let dict = try JSONSerialization.jsonObject(with: data,
                                options: .mutableContainers) as? [String:Any] {
                                if !dict.isEmpty {
                                    dicts.append(dict)
                                }
                            }
                        } catch {
                            var msg = "Error! Could not parse "
                            msg += "line \(lines) in file \(url)."
                            toNSLog(msg)
                        }
                    }
                }
            }
            dicts.removeFirst()
            return dicts
        } catch {
            toNSLog("Error! Could not read file \(url).")
        }
        return nil
    }

    /// returns AES-256 CBC encrypted optional string
//    func encrypt(_ str: String) -> String? {
//        return AES256CBC.encryptString(str, password: encryptionKey)
//    }

    /// Delete file to get started again
    func deleteFile(_ url: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            toNSLog("Warning! Could not delete file \(url).")
        }
        return false
    }

    // MARK: Device & Analytics

    // returns dict with device details. Amount depends on platform
    func deviceDetails() -> [String: String] {
        var details = [String: String]()

        details["os"] = OS
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        // becomes for example 10.11.2 for El Capitan
        var osVersionStr = String(osVersion.majorVersion)
        osVersionStr += "." + String(osVersion.minorVersion)
        osVersionStr += "." + String(osVersion.patchVersion)
        details["osVersion"] = osVersionStr
        details["hostName"] = ProcessInfo.processInfo.hostName
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
    func analytics(_ url: URL, update: Bool = false) -> [String:Any] {

        var dict = [String: Any]()
        let now = NSDate().timeIntervalSince1970

        uuid =  NSUUID().uuidString
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

    /// Returns the current app version string (like 1.2.5) or empty string on error
    func appVersion() -> String {
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
                return version
        }
        return ""
    }

    /// Returns the current app build as integer (like 563, always incrementing) or 0 on error
    func appBuild() -> Int {
        if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            if let intVersion = Int(version) {
                return intVersion
            }
        }
        return 0
    }

    /// returns optional dict from a json encoded file
    func dictFromFile(_ url: URL) -> [String:Any]? {
        do {
            let fileContent = try String(contentsOfFile: url.path, encoding: .utf8)
            if let data = fileContent.data(using: .utf8) {
                return try JSONSerialization.jsonObject(with: data,
                                    options: .mutableContainers) as? [String:Any]
            }
        } catch {
            toNSLog("SwiftyBeaver Platform Destination could not read file \(url)")
        }
        return nil
    }

    // turns dict into JSON and saves it to file
    func saveDictToFile(_ dict: [String: Any], url: URL) -> Bool {
        let jsonString = jsonStringFromDict(dict)

        if let str = jsonString {
            toNSLog("saving '\(str)' to \(url)")
            return saveToFile(str, url: url, overwrite: true)
        }
        return false
    }

    // MARK: Debug Helpers

    /// log String to toNSLog. Used to debug the class logic
    func toNSLog(_ str: String) {
        if showNSLog {
            #if os(Linux)
                print("ElasticSearch: \(str)")
            #else
                NSLog("ElasticSearch: \(str)")
            #endif
        }
    }

    /// returns the current thread name
    class func threadName() -> String {

        #if os(Linux)
            // on 9/30/2016 not yet implemented in server-side Swift:
            // > import Foundation
            // > Thread.isMainThread
            return ""
        #else
            if Thread.isMainThread {
                return ""
            } else {
                let threadName = Thread.current.name
                if let threadName = threadName, !threadName.isEmpty {
                    return threadName
                } else {
                    return String(format: "%p", Thread.current)
                }
            }
        #endif
    }
}
