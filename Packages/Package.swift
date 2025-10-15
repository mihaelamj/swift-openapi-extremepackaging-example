// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Main",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .singleTargetLibrary("AppFeature"),
        .singleTargetLibrary("SharedApiModels"),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", from: "0.57.0"),
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-vapor", from: "1.0.0"),
        .package(url: "https://github.com/vapor/vapor", from: "4.89.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-async-http-client", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client", from: "1.19.0")
    ],
    targets: {
        
        let sharedModelsTarget = Target.target(
            name: "SharedModels",
            dependencies: [],
        )
        
        let appFeatureTarget = Target.target(
            name: "AppFeature",
            dependencies: [
                "SharedModels"
            ]
        )
        
        let appFeatureTestsTarget = Target.testTarget(
            name: "AppFeatureTests",
            dependencies: [
                "AppFeature"
            ]
        )
        
        let yamlMergerTarget = Target.target(
            name: "YAMLMerger",
            dependencies: []
        )
        
        let yamlMergerTestsTarget = Target.testTarget(
            name: "YAMLMergerTests",
            dependencies: [
                "YAMLMerger"
            ],
            resources: [
                .copy("Schema")
            ]
        )
        
        let sharedApiModelsTarget = Target.target(
            name: "SharedApiModels",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIVapor", package: "swift-openapi-vapor"),
                .product(name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
            ]
        )
        
        let sharedApiModelsTestsTarget = Target.testTarget(
            name: "SharedApiModelsTests",
            dependencies: [
                "SharedApiModels",
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "OpenAPIVapor", package: "swift-openapi-vapor"),
                .product(name: "Vapor", package: "vapor")
            ]
        )
        
        return [
            sharedModelsTarget,
            appFeatureTarget,
            appFeatureTestsTarget,
            yamlMergerTarget,
            yamlMergerTestsTarget,
            sharedApiModelsTarget,
            sharedApiModelsTestsTarget
        ]
        
    }()
)

// Inject base plugins into each target
package.targets = package.targets.map { target in
    var plugins = target.plugins ?? []
    plugins.append(.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint"))
    target.plugins = plugins
    return target
}

extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}
