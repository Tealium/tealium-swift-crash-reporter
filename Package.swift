// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "TealiumCrashModule",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_11),
        .tvOS(.v9),
    ],
    products: [
        .library(name: "TealiumCrashModule", targets: ["TealiumCrashModule"])
    ],
    dependencies: [
        .package(name: "TealiumSwift", url: "https://github.com/tealium/tealium-swift", .upToNextMajor(from: "2.6.0")),
        .package(name: "PLCrashReporter", url: "https://github.com/microsoft/plcrashreporter", .upToNextMajor(from: "1.10.0")),
    ],
    targets: [
        .target(
            name: "TealiumCrashModule",
            dependencies: [.product(name: "CrashReporter", package: "PLCrashReporter"),
                           .product(name: "TealiumCore", package: "TealiumSwift")],
            path: "./TealiumCrashModule/TealiumCrashModule",
            exclude: ["Support"]),
        .testTarget(
            name: "TealiumCrashModuleTests",
            dependencies: ["TealiumCrashModule"],
            path: "./TealiumCrashModule/TealiumCrashModuleTests/test_tealium_crash",
        resources: [
            .process("resources/")
        ])
    ]
)
