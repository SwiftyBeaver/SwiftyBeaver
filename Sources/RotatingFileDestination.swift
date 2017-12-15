//
//  Created by Christian Tietze (@ctietze) on 2017-12-14.
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import struct Foundation.URL
import struct Foundation.Date
import class Foundation.DateFormatter

public class RotatingFileDestination: BaseDestination {

    public let rotation: Rotation
    public var baseURL: URL?
    public let fileName: FileName
    internal let clock: Clock

    public override convenience init() {
        let baseURL = defaultBaseURL()
        self.init(rotation: .daily,
                  logDirectoryURL: baseURL,
                  fileName: FileName(name: "swiftybeaver", pathExtension: "log"),
                  clock: SystemClock())
    }

    public init(rotation: Rotation,
                logDirectoryURL baseURL: URL?,
                fileName: FileName,
                clock: Clock) {

        self.rotation = rotation
        self.baseURL = baseURL
        self.fileName = fileName
        self.clock = clock

        super.init()

        // Use the same formatting as `FileDestination`
        FileDestination.applyDefaultSettings(destination: self)
    }

    public var currentURL: URL? {
        return baseURL.map { $0.appendingPathComponent(currentFileName, isDirectory: false) }
    }

    public var currentFileName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = rotation.dateFormat
        let dateSuffix = formatter.string(from: clock.now())
        return fileName.pathComponent(suffix: dateSuffix)
    }

    /// Creates a new `FileDestination` according to the current rotation. Inherits base settings from `self`.
    internal func currentFileDestination() -> FileDestination {
        let fileDestination = FileDestination()
        copySettings(from: self, to: fileDestination)
        fileDestination.logFileURL = self.currentURL
        return fileDestination
    }

    public enum Rotation {
        case daily

        public var dateFormat: String {
            switch self {
            case .daily: return "yyyy-MM-dd"
            }
        }
    }

    public struct FileName {
        public let name: String
        public let pathExtension: String

        public init(name: String, pathExtension: String) {
            self.name = name
            self.pathExtension = pathExtension
        }

        public func pathComponent(suffix: String) -> String {
            return "\(name)-\(suffix).\(pathExtension)"
        }
    }

    // MARK: - Rotation of underlying `FileDestination`

    // Internal visibility to be a testing seam.
    internal var fileDestination: FileDestination? {
        get {
            replaceFileDestinationOnRotation()

            return _currentFileDestination?.fileDestination
        }
    }

    fileprivate lazy var _currentFileDestination: CachedFileDestination? = self.currentCachedFileDestination()

    fileprivate func currentCachedFileDestination() -> CachedFileDestination? {
        guard let currentURL = self.currentURL else { return nil }
        return CachedFileDestination(
            fileDestination: self.currentFileDestination(),
            url: currentURL)
    }

    fileprivate func replaceFileDestinationOnRotation() {
        guard let currentURL = self.currentURL else { return }

        let needsRotation = _currentFileDestination?.isOutdated(currentURL: currentURL)
            ?? true

        guard needsRotation else { return }

        rotateFileDestination()
    }

    fileprivate func rotateFileDestination() {
        _currentFileDestination = self.currentCachedFileDestination()
    }

    /// `FileDestination` and `URL` should vary together, so this type
    /// represents their combined values.
    struct CachedFileDestination {
        let fileDestination: FileDestination
        let url: URL

        func isOutdated(currentURL: URL) -> Bool {
            return url != currentURL
        }
    }

    // MARK: - Forward log commands to `FileDestination`

    public override func send(
        _ level: SwiftyBeaver.Level,
        msg: String,
        thread: String,
        file: String, function: String, line: Int,
        context: Any?) -> String? {

        return fileDestination?.send(level, msg: msg, thread: thread, file: file, function: function, line: line, context: context)
    }

    // MARK: - Forwarding settings to `FileDestination`

    public override var format: String {
        didSet {
            fileDestination?.format = format
        }
    }

    public override var asynchronously: Bool {
        didSet {
            fileDestination?.asynchronously = asynchronously
        }
    }

    public override var minLevel: SwiftyBeaver.Level {
        didSet {
            fileDestination?.minLevel = minLevel
        }
    }

    public override var levelString: BaseDestination.LevelString {
        didSet {
            fileDestination?.levelString = levelString
        }
    }

    public override var levelColor: BaseDestination.LevelColor {
        didSet {
            fileDestination?.levelColor = levelColor
        }
    }

    override var reset: String {
        didSet {
            fileDestination?.reset = reset
        }
    }

    override var escape: String {
        didSet {
            fileDestination?.escape = escape
        }
    }

    override var filters: [FilterType] {
        didSet {
            fileDestination?.filters = filters
        }
    }

    override var debugPrint: Bool {
        didSet {
            fileDestination?.debugPrint = debugPrint
        }
    }
}

fileprivate func copySettings(from: BaseDestination, to: BaseDestination) {

    to.format = from.format
    to.reset = from.reset
    to.escape = from.escape

    to.asynchronously = from.asynchronously
    to.filters = from.filters

    to.minLevel = from.minLevel
    to.levelString = from.levelString
    to.levelColor = from.levelColor
}
