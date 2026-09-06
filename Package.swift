// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CalculatorCore",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "CalculatorCore",
            targets: ["CalculatorCore"]
        )
    ],
    targets: [
        .target(
            name: "CalculatorCore",
            path: "Sources/CalculatorCore"
        ),
        .testTarget(
            name: "CalculatorCoreTests",
            dependencies: ["CalculatorCore"],
            path: "Tests/CalculatorCoreTests"
        )
    ]
)