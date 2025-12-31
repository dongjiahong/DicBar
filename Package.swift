// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DicBar",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "DicBar", targets: ["DicBar"])
    ],
    dependencies: [
        // SQLite ORM
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.24.0"),
        // Global Hotkey
        .package(url: "https://github.com/soffes/HotKey.git", from: "0.2.0")
    ],
    targets: [
        .executableTarget(
            name: "DicBar",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "HotKey", package: "HotKey")
            ],
            path: "DicBar/Sources",
            resources: [
                .copy("../Resources/dictionary.db"),
                .copy("../Resources/Assets.xcassets")
            ]
        )
    ]
)
