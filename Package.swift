// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "command-line-tool",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2)
    ]
)
