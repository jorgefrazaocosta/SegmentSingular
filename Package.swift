// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SegmentSingular",
    platforms: [
        .macOS("10.15"),
        .iOS("13.0"),
        .tvOS("11.0"),
        .watchOS("7.1")
    ],
    products: [
        .library(
            name: "SegmentSingular",
            targets: ["SegmentSingular"]),
    ],
    dependencies: [
        .package(
            name: "Segment",
            url: "https://github.com/segmentio/analytics-swift.git",
            from: "1.5.2"
        ),
        .package(
            name: "Singular",
            url: "https://github.com/singular-labs/Singular-iOS-SDK.git",
            from: "12.2.0"
        )
    ],
    targets: [
        .target(
            name: "SegmentSingular",
            dependencies: [
                .product(name: "Segment", package: "Segment"),
                .product(name: "Singular", package: "Singular")
            ]
        )
    ]
)
