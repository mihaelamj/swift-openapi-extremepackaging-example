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
        
        .executable(name: "apiserver", targets: ["ApiServer"]),
        .singleTargetLibrary("ApiClient")
        
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", from: "0.57.0"),
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-vapor", from: "1.0.0"),
        .package(url: "https://github.com/vapor/vapor", from: "4.89.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-async-http-client", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client", from: "1.19.0"),
        .package(url: "https://github.com/mihaelamj/OpenAPILoggingMiddleware", from: "1.0.0"),
        .package(url: "https://github.com/mihaelamj/BearerTokenAuthMiddleware", exact: "1.1.0")
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
        
        // MARK: API -
        
        let apiServerTarget = Target.executableTarget(
            name: "ApiServer",
            dependencies: [
                "SharedApiModels",
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIVapor", package: "swift-openapi-vapor"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "OpenAPILoggingMiddleware", package: "OpenAPILoggingMiddleware")
            ]
        )
        
        let apiServerTestsTarget = Target.testTarget(
            name: "ApiServerTests",
            dependencies: ["ApiServer"]
        )
        
        let apiClientTarget = Target.target(
            name: "ApiClient",
            dependencies: [
                "SharedApiModels",
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
                .product(name: "OpenAPILoggingMiddleware", package: "OpenAPILoggingMiddleware"),
                .product(name: "BearerTokenAuthMiddleware", package: "BearerTokenAuthMiddleware")
            ]
        )
        
        let apiClientTestsTarget = Target.testTarget(
            name: "ApiClientTests",
            dependencies: [
                "SharedApiModels",
                "ApiClient"
            ]
        )
        
        // MARK: Targets -
        
        let helperTargets: [Target] = [
            yamlMergerTarget,
            yamlMergerTestsTarget
        ]
        
        let apiTargets: [Target] = [
            sharedApiModelsTarget,
            sharedApiModelsTestsTarget,
            apiServerTarget,
            apiServerTestsTarget,
            apiClientTarget,
            apiClientTestsTarget,
        ]
        
        let modelTargets: [Target] = [
            sharedModelsTarget
        ]
        
        let uiTargets: [Target] = [
            appFeatureTarget,
            appFeatureTestsTarget
        ]
        
        return helperTargets + apiTargets + modelTargets + uiTargets
        
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
