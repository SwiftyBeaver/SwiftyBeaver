//
//  Created by Christian Tietze (@ctietze) on 2017-12-16.
//  Some rights reserved: http://opensource.org/licenses/MIT
//

public protocol RemoveLogFiles: class {
    /// Move to the trash if possible, or immediately delete the file from disk.
    ///
    /// - throws: `LogFileRemovalError`
    func removeLogFile(at url: URL) throws
}

public enum LogFileRemovalError: Error {
    case trashingFailed(URL, wrapping: Error)
    case removingFailed(URL, wrapping: Error)
}

import Foundation

extension FileManager: RemoveLogFiles {
    public func removeLogFile(at url: URL) throws {
        #if os(OSX)
            do {
                try trashItem(at: url, resultingItemURL: nil)
            } catch {
                throw LogFileRemovalError.trashingFailed(url, wrapping: error)
            }
        #else
            // Remove file directly on non-Mac devices, even though FileManager supports trashing on iOS.
            do {
                try removeItem(at: url)
            } catch {
                throw LogFileRemovalError.removingFailed(url, wrapping: error)
            }
        #endif
    }
}
