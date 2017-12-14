//
//  Created by Christian Tietze (@ctietze) on 2017-12-14.
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import struct Foundation.URL
import struct Foundation.Date
import class Foundation.DateFormatter

public class RotatingFileDestination {

    public let rotation: Rotation
    public var baseURL: URL?
    public let fileName: FileName
    internal let clock: Clock

    public convenience init() {
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
}
