//
//  Created by Christian Tietze (@ctietze) on 2017-12-15.
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation

internal func createFile(url: URL) {
    try! "".write(to: url, atomically: false, encoding: .utf8)
}

/// Creates a unique and thus empty temporary directory.
internal func createTempDirectory() -> URL {
    let fileUrl = generatedTempDirectoryURL()
    try! FileManager.default.createDirectory(at: fileUrl, withIntermediateDirectories: false, attributes: nil)
    return fileUrl
}

internal func generatedTempDirectoryURL() -> URL {
    let fileName = "swiftybeaver-temp-dir.\(UUID().uuidString)"
    return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName, isDirectory: true)
}

/// Creates a unique file name in a random temporary location
internal func createTempFileURL(content: String = "irrelevant content", ext: String? = nil) -> URL {
    let url = generatedTempFileURL(ext: ext)
    try! content.write(to: url, atomically: true, encoding: .utf8)
    return url
}

internal func generatedTempFileURL(ext: String? = nil) -> URL {
    let fileName = generatedFileName(ext: ext)
    let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
    return fileURL
}

fileprivate func generatedFileName(ext: String? = nil) -> String {
    let fileExtension: String
    if let ext = ext {
        fileExtension = ".\(ext)"
    } else {
        fileExtension = ""
    }

    return "swiftybeaver-temp.\(UUID().uuidString)\(fileExtension)"
}
