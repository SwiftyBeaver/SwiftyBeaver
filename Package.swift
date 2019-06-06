// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(name: "SwiftyBeaver")

package.platforms = [.macOS(.v10_12), .iOS(.v11), .tvOS(.v11), .watchOS(.v2)]
package.products = [.library(name: "SwiftyBeaver", targets: ["SwiftyBeaver"])]
package.swiftLanguageVersions = [.v5]
package.targets = [
    .target(name: "SwiftyBeaver", dependencies: [], path: "Sources"),
    .testTarget(name: "SwiftyBeaverTests", dependencies: ["SwiftyBeaver"])
]
