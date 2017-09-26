// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SwiftyBeaver",
    products: [
        .library(name: "SwiftyBeaver", targets: ["SwiftyBeaver"])
    ],
    targets:[
        .target(name: "SwiftyBeaver", dependencies: [], path: "Sources"),
        .testTarget(name: "SwiftyBeaverTests", dependencies: ["SwiftyBeaver"])
    ]
)
