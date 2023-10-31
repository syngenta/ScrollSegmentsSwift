// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ScrollSegmentsSwift",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "ScrollSegmentsSwift",
            targets: ["ScrollSegmentsSwift"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ScrollSegmentsSwift",
            path: "ScrollSegmentsSwift"
        ),
    ],
    swiftLanguageVersions: [.v4]
)
