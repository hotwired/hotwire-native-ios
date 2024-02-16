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
        .package(name: "Turbo", path: "Packages/Turbo"),
        .package(name: "Strada", path: "Packages/Strada"),
    ],
    targets: [
        .target(
            name: "Hotwire",
            dependencies: [
                .product(name: "Turbo", package: "Turbo"),
                .product(name: "Strada", package: "Strada"),
            ]
        ),
        .testTarget(
            name: "HotwireTests",
            dependencies: ["Hotwire"]
        ),
    ]
)
