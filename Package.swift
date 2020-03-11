import PackageDescription

let package = Package(
    name: "TermiNetwork",
    products: [
        .library(
            name: "TermiNetwork",
            targets: ["TermiNetwork"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "TermiNetwork",
						path: "TermiNetwork",
            dependencies: []),
    ]
)
