// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Calendar",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(
            name: "Calendar",
            targets: ["Calendar"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Calendar",
            dependencies: []),
        .testTarget(
            name: "CalendarTests",
            dependencies: ["Calendar"]),
    ]
)
