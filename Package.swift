// swift-tools-version:4.0

import PackageDescription

let package = Package(
	name: "LogFile",
	products: [
		.library(name: "LogFile", targets: ["LogFile"])
	],
	targets: [
		.target(name: "LogFile")
	]
)
