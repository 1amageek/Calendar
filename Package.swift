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
        .library(
            name: "DateExtension",
            targets: ["DateExtension"])
    ],
    dependencies: [
        .package(name: "RecurrenceRule", url: "git@github.com:1amageek/RecurrenceRule.git", .branch("main")),
    ],
    targets: [
        .target(
            name: "DateExtension",
            dependencies: []),
        .target(
            name: "Calendar",
            dependencies: ["RecurrenceRule", "DateExtension"]),
        .testTarget(
            name: "CalendarTests",
            dependencies: ["Calendar"]),
    ]
)
