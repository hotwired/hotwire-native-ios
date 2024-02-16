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
    dependencies: [],
    targets: [
        .target(
            name: "Hotwire",
            dependencies: [],
            resources: [
                .copy("Turbo/WebView/turbo.js"),
                .copy("Strada/strada.js"),
            ]
        ),
        .testTarget(
            name: "HotwireTests",
            dependencies: ["Hotwire"]
        ),
    ]
)
