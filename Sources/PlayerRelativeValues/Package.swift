import PackageDescription

let package = Package(
    name: "PlayerRelativeValues",
    targets: [
        .target(
            name: "PlayerRelativeValues",
            dependencies: ["RotoSwift"]
        ),
        .target(name: "RotoSwift")
    ]
)
