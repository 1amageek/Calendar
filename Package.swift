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
        .package(name: "RecurrenceRulePicker", url: "git@github.com:1amageek/RecurrenceRulePicker.git", .branch("main"))
    ],
    targets: [
        .target(
            name: "Calendar",
            dependencies: ["RecurrenceRulePicker"]),
        .testTarget(
            name: "CalendarTests",
            dependencies: ["Calendar", "RecurrenceRulePicker"]),
    ]
)
