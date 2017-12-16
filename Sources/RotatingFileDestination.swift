//
//  Created by Christian Tietze (@ctietze) on 2017-12-14.
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import struct Foundation.URL
import struct Foundation.Date
import class Foundation.DateFormatter
import class Foundation.FileManager

/// A logging destination that acts like a `FileDestination` with a changing URL
/// based on its `Rotation` setting.
public class RotatingFileDestination: BaseDestination {

    public let rotation: Rotation
    public let deletionPolicy: DeletionPolicy
    /// - Warning: Is optional only because `defaultBaseURL()` is. `nil` is a misconfiguration and the behavior undefined.
    public let directory: Directory?
    public var baseURL: URL? { return directory?.url }
    public let fileName: FileName
    internal let clock: Clock

    public lazy var removeLogFiles: RemoveLogFiles = FileManager.default

    /// Sets up daily rotation, keeping at most 5 log entries.
    /// Files are names `swiftybeaver-YYYY-MM-DD.log`
    public override convenience init() {
        let baseURL = defaultBaseURL()
        self.init(rotation: .daily,
                  deletionPolicy: .quantity(5),
                  logDirectoryURL: baseURL,
                  fileName: FileName(name: "swiftybeaver", pathExtension: "log"),
                  clock: SystemClock())
    }

    public convenience init(
        rotation: Rotation,
        deletionPolicy: DeletionPolicy,
        logDirectoryURL baseURL: URL?,
        fileName: FileName,
        clock: Clock) {

        let directory = baseURL.flatMap { Directory(url: $0) }

        self.init(rotation: rotation,
                  deletionPolicy: deletionPolicy,
                  logDirectory: directory,
                  fileName: fileName,
                  clock: clock)
    }

    public init(
        rotation: Rotation,
        deletionPolicy: DeletionPolicy,
        logDirectory: Directory?,
        fileName: FileName,
        clock: Clock) {

        self.rotation = rotation
        self.deletionPolicy = deletionPolicy
        self.directory = logDirectory
        self.fileName = fileName
        self.clock = clock

        super.init()

        // Use the same formatting as `FileDestination`
        // but do not forward them now, during initialization
        self.shouldForwardSettings = false
        FileDestination.applyDefaultSettings(destination: self)
        self.shouldForwardSettings = true
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

        public func matchingFiles(
            in directory: Directory,
            sortedBy sortOrder: Directory.SortOrder = .fileName) -> [URL] {
            let fileURLs = (try? directory.fileURLs(sortedBy: sortOrder)) ?? []
            return filterMatching(fileURLs: fileURLs)
        }

        public func filterMatching(fileURLs: [URL]) -> [URL] {
            return fileURLs.filter { fileURL -> Bool in
                return fileURL.lastPathComponent.hasPrefix(self.name)
                    && fileURL.pathExtension == self.pathExtension
            }
        }
    }

    public enum DeletionPolicy: Equatable {
        /// Keeps this amount of files, removing the rest; 0 does not remove any.
        case quantity(UInt)

        public func filterRemovable(
            assumingFileExistsAt currentURL: URL,
            logDirectory directory: Directory,
            fileName: FileName) -> [URL] {

            switch self {
            case .quantity(let capacity):
                guard capacity > 0 else { return [] }
                return fileName
                    .matchingFiles(in: directory, sortedBy: .fileName)
                    .appendingIfNotExists(currentURL)
                    .dropLast(capacity)
                    .asArray()
            }
        }

        public static func ==(lhs: DeletionPolicy, rhs: DeletionPolicy) -> Bool {
            switch (lhs, rhs) {
            case let (.quantity(lQuantity),
                      .quantity(rQuantity)):
                return lQuantity == rQuantity
            }
        }
    }

    // MARK: - Rotation of underlying `FileDestination`

    // Internal visibility to be a testing seam.
    internal var fileDestination: FileDestination? {
        get {
            replaceFileDestinationOnRotation()

            return _currentCachedFileDestination?.fileDestination
        }
    }

    fileprivate func currentCachedFileDestination() -> CachedFileDestination? {
        guard let currentURL = self.currentURL else { return nil }
        return CachedFileDestination(
            fileDestination: self.currentFileDestination(),
            url: currentURL)
    }

    // Start with `nil` so the first access triggers a regular rotation.
    fileprivate var _currentCachedFileDestination: CachedFileDestination? = nil

    fileprivate func replaceFileDestinationOnRotation() {
        guard let currentURL = self.currentURL else { return }

        let needsRotation = _currentCachedFileDestination?.isOutdated(currentURL: currentURL)
            ?? true

        guard needsRotation else { return }

        rotateFileDestination()
    }

    fileprivate func rotateFileDestination() {
        _currentCachedFileDestination = self.currentCachedFileDestination()

        cleanupLogDirectory()
    }

    fileprivate func cleanupLogDirectory() {
        guard let directory = self.directory else { return }
        guard let currentURL = self.currentURL else { return }

        let removableURLs = deletionPolicy.filterRemovable(
            assumingFileExistsAt: currentURL,
            logDirectory: directory,
            fileName: fileName)

        for url in removableURLs {
            do {
                try removeLogFiles.removeLogFile(at: url)
            } catch {
                print("Removing log file failed: \(error)")
            }
        }
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

    fileprivate var shouldForwardSettings = false

    public override var format: String {
        didSet {
            guard shouldForwardSettings else { return }
            fileDestination?.format = format
        }
    }

    public override var asynchronously: Bool {
        didSet {
            guard shouldForwardSettings else { return }
            fileDestination?.asynchronously = asynchronously
        }
    }

    public override var minLevel: SwiftyBeaver.Level {
        didSet {
            guard shouldForwardSettings else { return }
            fileDestination?.minLevel = minLevel
        }
    }

    public override var levelString: BaseDestination.LevelString {
        didSet {
            guard shouldForwardSettings else { return }
            fileDestination?.levelString = levelString
        }
    }

    public override var levelColor: BaseDestination.LevelColor {
        didSet {
            guard shouldForwardSettings else { return }
            fileDestination?.levelColor = levelColor
        }
    }

    override var reset: String {
        didSet {
            guard shouldForwardSettings else { return }
            fileDestination?.reset = reset
        }
    }

    override var escape: String {
        didSet {
            guard shouldForwardSettings else { return }
            fileDestination?.escape = escape
        }
    }

    override var filters: [FilterType] {
        didSet {
            guard shouldForwardSettings else { return }
            fileDestination?.filters = filters
        }
    }

    override var debugPrint: Bool {
        didSet {
            guard shouldForwardSettings else { return }
            fileDestination?.debugPrint = debugPrint
        }
    }
}

fileprivate extension Array {
    func dropLast(_ n: UInt) -> ArraySlice<Element> {
        return dropLast(Int(n))
    }
}

fileprivate extension Array where Element == URL {
    func appendingIfNotExists(_ element: Element) -> [Element] {
        guard !contains(where: { $0.resolvingSymlinksInPath() == element.resolvingSymlinksInPath() })
            else { return self }

        var result = self
        result.append(element)
        return result
    }
}

fileprivate extension ArraySlice {
    func asArray() -> [Element] {
        return Array(self)
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
