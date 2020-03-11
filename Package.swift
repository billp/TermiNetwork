// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "TermiNetwork",
    products: [
        .library(
            name: "TermiNetwork",
            targets: ["TermiNetwork"])
    ],
		dependencies: [
				.package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
		],
    targets: [
        .target(
            name: "TermiNetwork",
						dependencies: ["SwiftyJSON"],
						path: "TermiNetwork")
    ],
		swiftLanguageVersions: [.v5]
)
