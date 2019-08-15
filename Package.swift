// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EFStorage",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "EFStorage",
            targets: ["EFStorageCore", "EFStorageKeychain", "EFStorageUserDefaults"]),
        .library(
            name: "EFStorageCore",
            targets: ["EFStorageCore"]),
        .library(
            name: "EFStorageKeychain",
            targets: ["EFStorageKeychain"]),
        .library(
            name: "EFStorageUserDefaults",
            targets: ["EFStorageUserDefaults"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", .upToNextMajor(from: "3.2.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "EFStorageCore",
            dependencies: []),
        .target(
            name: "EFStorageKeychain",
            dependencies: ["EFStorageCore", "KeychainAccess"]),
        .target(
            name: "EFStorageUserDefaults",
            dependencies: ["EFStorageCore"]),
        .testTarget(
            name: "EFStorageTests",
            dependencies: ["EFStorageCore", "EFStorageKeychain", "EFStorageUserDefaults"]),
    ]
)
