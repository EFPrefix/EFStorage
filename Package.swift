// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EFStorage",
    products: [
        .library(
            name: "EFStorage",
            targets: [
                "EFStorageCore",
                "EFStorageKeychainAccess",
                "EFStorageUserDefaults",
                "EFStorageYYCache",
        ]),
        .library(
            name: "EFStorageCore",
            targets: ["EFStorageCore"]),
        .library(
            name: "EFStorageKeychainAccess",
            targets: ["EFStorageKeychainAccess"]),
        .library(
            name: "EFStorageUserDefaults",
            targets: ["EFStorageUserDefaults"]),
        .library(
            name: "EFStorageYYCache",
            targets: ["EFStorageYYCache"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", .upToNextMajor(from: "3.2.0")),
        .package(url: "https://github.com/EFPrefix/YYCache.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "EFStorageCore",
            dependencies: []),
        .target(
            name: "EFStorageKeychainAccess",
            dependencies: ["EFStorageCore", "KeychainAccess"]),
        .target(
            name: "EFStorageUserDefaults",
            dependencies: ["EFStorageCore"]),
        .target(
            name: "EFStorageYYCache",
            dependencies: ["EFStorageCore", "YYCache"]),
        .testTarget(
            name: "EFStorageTests",
            dependencies: [
                "EFStorageCore",
                "EFStorageKeychainAccess",
                "EFStorageUserDefaults",
        ]),
    ]
)
