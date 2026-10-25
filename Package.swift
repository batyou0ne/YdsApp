// swift-tools-version:5.9
import PackageDescription

// Platformdan bağımsız Domain + Data katmanları ve Onboarding Presentation (ViewModel + Contract) katmanını `swift test` ile test etmek için (UI hariç).
let package = Package(
    name: "YdsCore",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [.library(name: "YdsCore", targets: ["YdsCore"])],
    targets: [
        .target(name: "YdsCore", path: "YdsApp", sources: ["Domain", "Data", "Presentation/Onboarding"]),
        .testTarget(name: "YdsCoreTests", dependencies: ["YdsCore"], path: "YdsAppTests")
    ]
)
