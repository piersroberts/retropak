// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RetropakSchema",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "RetropakSchema",
            targets: ["RetropakSchema"]
        )
    ],
    targets: [
        .target(
            name: "RetropakSchema",
            path: "packages/swift/Sources/RetropakSchema",
            resources: [
                .copy("schemas/v1/retropak.schema.json"),
                .copy("locales/en.json"),
            ]
        )
    ]
)
