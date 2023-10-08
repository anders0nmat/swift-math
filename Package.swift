// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-math",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftMath",
            targets: ["swift-math"]),
		.executable(name: "SwiftMathCLI", targets: ["swift-math-cli"])
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "swift-math"),
		.executableTarget(
			name: "swift-math-cli",
			dependencies: ["swift-math"]),
        .testTarget(
            name: "swift-mathTests",
            dependencies: ["swift-math"]),
    ]
)
