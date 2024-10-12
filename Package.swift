// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "SwiftSystemd",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .executable(name: "systemd", targets: ["systemd"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/console-kit", .upToNextMajor(from: "4.15.0")),
        .package(url: "https://github.com/MihaelIsaev/SwiftBash", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .executableTarget(name: "systemd", dependencies: [
            .product(name: "ConsoleKit", package: "console-kit"),
            .product(name: "Bash", package: "SwiftBash")
        ]),
        .testTarget(name: "systemdTests", dependencies: [
            .target(name: "systemd")
        ]),
    ]
)
