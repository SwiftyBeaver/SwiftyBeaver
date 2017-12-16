//
//  Created by Christian Tietze (@ctietze) on 2017-12-15.
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation

public struct Directory {
    public let url: URL
    public let inspector: DirectoryInspector

    public init?(url: URL, inspector: DirectoryInspector = FileManager.default) {
        guard inspector.directoryExists(at: url) else { return nil }
        self.url = url
        self.inspector = inspector
    }

    public func fileURLs(sortedBy sortOrder: SortOrder) throws -> [URL] {
        let fileURLs = try inspector.filesInDirectory(at: url)
        return fileURLs.sorted { (lhs, rhs) -> Bool in
            lhs.lastPathComponent < rhs.lastPathComponent
        }
    }

    public enum SortOrder {
        case fileName
    }
}

public protocol DirectoryInspector: class {
    func directoryExists(at url: URL) -> Bool

    /// - returns: Unsorted collection of file URLs that are not themselves directories inside `url`.
    /// - throws: `DirectoryError` when there a directory listing failed for `url`.
    func filesInDirectory(at url: URL) throws -> [URL]
}

extension FileManager: DirectoryInspector {
    public func directoryExists(at url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = fileExists(atPath: url.path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    public func filesInDirectory(at url: URL) throws -> [URL] {
        guard directoryExists(at: url) else { throw DirectoryError.notADirectory(url) }

        let contents: [URL]

        do {
            contents = try contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants])
        } catch {
            throw DirectoryError.listingFailed(wrapped: error)
        }

        return contents.filter { !directoryExists(at: $0) }
    }
}

public enum DirectoryError: Error, Equatable {
    case notADirectory(URL)
    case listingFailed(wrapped: Error)
}

public func ==(lhs: DirectoryError, rhs: DirectoryError) -> Bool {

    switch (lhs, rhs) {
    case let (.notADirectory(lURL),
              .notADirectory(rURL)):
        return lURL == rURL

    case (.listingFailed(_),
          .listingFailed(_)):
        return true

    default:
        return false
    }
}
