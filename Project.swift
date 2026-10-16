import ProjectDescription

// Tuist generates the Xcode project from code: no .xcodeproj merge conflicts, and each
// module is a real framework with explicit dependencies (enforced at build time).
let iOS: DeploymentTargets = .iOS("15.0")

func framework(_ name: String, dependencies: [TargetDependency] = []) -> [Target] {
    [
        .target(name: name, destinations: .iOS, product: .framework, bundleId: "com.smsmurilo.\(name.lowercased())",
                deploymentTargets: iOS, sources: ["Modules/\(name)/Sources/**"], dependencies: dependencies),
        .target(name: "\(name)Tests", destinations: .iOS, product: .unitTests, bundleId: "com.smsmurilo.\(name.lowercased()).tests",
                deploymentTargets: iOS, sources: ["Modules/\(name)/Tests/**"], dependencies: [.target(name: name)]),
    ]
}

let project = Project(
    name: "MinhaLinha",
    targets: framework("TelecomCore")
        + framework("TelecomFeatures", dependencies: [.target(name: "TelecomCore")])
        + [
            .target(
                name: "MinhaLinha",
                destinations: .iOS,
                product: .app,
                bundleId: "com.smsmurilo.minhalinha",
                deploymentTargets: iOS,
                infoPlist: .extendingDefault(with: [
                    "UILaunchScreen": [:],
                    "CFBundleURLTypes": [["CFBundleURLSchemes": ["minhalinha"]]],
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": false,
                        "UISceneConfigurations": ["UIWindowSceneSessionRoleApplication": [[
                            "UISceneConfigurationName": "Default",
                            "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate",
                        ]]],
                    ],
                ]),
                sources: ["App/**"],
                dependencies: [.target(name: "TelecomCore"), .target(name: "TelecomFeatures")]
            ),
        ]
)
