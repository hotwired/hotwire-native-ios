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
        .package(url: "https://github.com/hotwired/turbo-ios", branch: "turbo-navigator"),
        .package(url: "https://github.com/hotwired/strada-ios", branch: "main"),
    ],
    targets: [
        .target(
            name: "HotwireNative",
            dependencies: [
                .product(name: "Turbo", package: "turbo-ios"),
                .product(name: "Strada", package: "strada-ios"),
            ]
        ),
        .testTarget(
            name: "HotwireNativeTests",
            dependencies: ["HotwireNative"]
        ),
    ]
)
