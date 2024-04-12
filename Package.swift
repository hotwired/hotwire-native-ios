// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "HotwireNative",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "HotwireNative",
            targets: ["HotwireNative"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs", .upToNextMajor(from: "9.0.0")),
        .package(url: "https://github.com/envoy/Embassy.git", .upToNextMajor(from: "4.1.4"))
    ],
    targets: [
        .target(
            name: "HotwireNative",
            dependencies: [],
            path: "Source",
            resources: [
                .copy("Turbo/WebView/turbo.js"),
                .copy("Bridge/bridge.js")
            ]
        ),
        .testTarget(
            name: "HotwireNativeTests",
            dependencies: [
                "HotwireNative",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
                .product(name: "Embassy", package: "Embassy")
            ],
            path: "Tests",
            resources: [
                .copy("Turbo/Fixtures"),
                .copy("Turbo/Server")
            ]
        ),
    ]
)
