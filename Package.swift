// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "TealiumCrashModule",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(name: "TealiumCrashModule", targets: ["TealiumCrashModule"])
    ],
    dependencies: [
        .package(url: "https://github.com/tealium/tealium-swift", from: "2.6.5"),
        .package(url: "https://github.com/tealium/plcrashreporter", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "TealiumCrashModule",
            dependencies: ["CrashReporter", "TealiumCore"],
            path: "./TealiumCrashModule/TealiumCrashModule"),
        .testTarget(
            name: "TealiumCrashModuleTests",
            dependencies: ["TealiumCrashModule"],
            path: "./TealiumCrashModule/TealiumCrashModuleTests/test_tealium_crash")
    ]
)
