// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "MSScrollViewSwift",
    products: [
        .library(name: "MSScrollViewSwift", targets: ["MSScrollViewSwift"])
    ],
    targets: [
        .target(
            name: "MSScrollViewSwift",
            path: "MSScrollViewSwift"
        )
    ]
)
