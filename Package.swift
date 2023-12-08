// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Hotwire",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "Hotwire",
            targets: ["Hotwire"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/hotwired/turbo-ios", branch: "turbo-navigator"),
        .package(url: "https://github.com/hotwired/strada-ios", branch: "main"),
    ],
    targets: [
        .target(
            name: "Hotwire",
            dependencies: [
                .product(name: "Turbo", package: "turbo-ios"),
                .product(name: "Strada", package: "strada-ios"),
            ]
        ),
        .testTarget(
            name: "HotwireTests",
            dependencies: ["Hotwire"]
        ),
    ]
)
