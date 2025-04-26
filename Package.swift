// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "MCClient",
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.81.0"),
        .package(url: "https://github.com/recp/cglm.git", from: "0.9.6"),
    ],
    targets: [
        .systemLibrary(name: "GLFW3", pkgConfig: "glfw3"),
        .target(name: "OpenGL", dependencies: ["GLFW3"]),
        .target(name: "STB", publicHeadersPath: "include"),
        .executableTarget(
            name: "MCClient",
            dependencies: [
               .product(name: "NIOCore", package: "swift-nio"),
               .product(name: "NIOPosix", package: "swift-nio"),
               "GLFW3",
               "OpenGL",
               "STB",
               .product(name: "cglm", package: "cglm")
            ],
            resources: [
                .embedInCode("basic.frag"),
                .embedInCode("basic.vert"),
                .embedInCode("atlas.png"),
            ],
        ),
    ],
)
