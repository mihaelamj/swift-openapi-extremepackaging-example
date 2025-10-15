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
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", exact: "0.52.3"),
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
        
        return [
            sharedModelsTarget,
            appFeatureTarget,
            appFeatureTestsTarget,
            yamlMergerTarget,
            yamlMergerTestsTarget
        ]
        
    }()
)

// Inject base plugins into each target
package.targets = package.targets.map { target in
    var plugins = target.plugins ?? []
    plugins.append(.plugin(name: "SwiftLintPlugin", package: "SwiftLint"))
    target.plugins = plugins
    return target
}

extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}
