// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "SDLTests",
    platforms: [
        .macOS(.v11)
    ],
    dependencies: [
        .package(name: "SDL2", url: "git@github.com:ctreffs/SwiftSDL2.git", from: "1.2.0"),
    ],
    targets: [
        .testTarget(
            name: "SDLTests",
            dependencies: [.product(name: "CSDL2", package: "SDL2")]
        )
    ]
)
