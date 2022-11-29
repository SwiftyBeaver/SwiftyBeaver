// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyBeaver-SVMK",
    products: [
        .library(name: "SwiftyBeaver-SVMK", targets: ["SwiftyBeaver"])
    ],
    targets: [
        .target(name: "SwiftyBeaver", path: "Sources"),
        .testTarget(name: "SwiftyBeaverTests", dependencies: ["SwiftyBeaver"]),
    ],
    swiftLanguageVersions: [.v5]
)
