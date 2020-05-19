// swift-tools-version:5.2

import PackageDescription

let package = Package(
	name: "LogFile",
	products: [
		.library(name: "LogFile", targets: ["LogFile"])
	],
	targets: [
		.target(name: "LogFile"),
		.testTarget(name: "LogFileTests", dependencies: ["LogFile"])
	],
	swiftLanguageVersions: [.v4, .v4_2, .v5]
)
