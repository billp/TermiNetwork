// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TermiNetwork",
    products: [
        .library(
            name: "TermiNetwork",
            targets: ["TermiNetwork"]),
    ],
    targets: [
        .target(
            name: "TermiNetwork",
						path: "TermiNetwork"),
    ]
)
