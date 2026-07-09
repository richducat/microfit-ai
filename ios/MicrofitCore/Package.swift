// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MicrofitCore",
    platforms: [.iOS(.v18), .macOS(.v14)],
    products: [
        .library(name: "MicrofitCore", targets: ["MicrofitCore"])
    ],
    targets: [
        .target(name: "MicrofitCore"),
        .testTarget(name: "MicrofitCoreTests", dependencies: ["MicrofitCore"])
    ]
)
