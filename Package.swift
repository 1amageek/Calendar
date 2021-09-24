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
    dependencies: [
        .package(name: "SwiftDate", url: "git@github.com:malcommac/SwiftDate.git", .upToNextMajor(from: "6.3.1")),
        .package(name: "RecurrenceRule", url: "git@github.com:1amageek/RecurrenceRule.git", .branch("main")),
        .package(name: "PageView", url: "git@github.com:1amageek/PageView.git", .branch("main")),
    ],
    targets: [
        .target(
            name: "Calendar",
            dependencies: ["SwiftDate", "RecurrenceRule", "PageView"]),
        .testTarget(
            name: "CalendarTests",
            dependencies: ["Calendar"]),
    ]
)
