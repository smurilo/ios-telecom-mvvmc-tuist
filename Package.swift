// swift-tools-version:5.9
// SPM mirror of the UIKit-free modules so Core + ViewModels run with `swift test` on any CI (incl. Linux).
import PackageDescription

let package = Package(
    name: "MinhaLinhaModules",
    platforms: [.iOS(.v15), .macOS(.v12)],
    targets: [
        .target(name: "TelecomCore", path: "Modules/TelecomCore/Sources"),
        .target(name: "TelecomFeatures", dependencies: ["TelecomCore"], path: "Modules/TelecomFeatures/Sources"),
        .testTarget(name: "TelecomCoreTests", dependencies: ["TelecomCore"], path: "Modules/TelecomCore/Tests"),
        .testTarget(name: "TelecomFeaturesTests", dependencies: ["TelecomFeatures"], path: "Modules/TelecomFeatures/Tests"),
    ]
)
