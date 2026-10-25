// swift-tools-version:5.9
import PackageDescription

// Yalnızca platformdan bağımsız Domain + Data katmanlarını `swift test` ile test etmek için (UI hariç).
let package = Package(
    name: "YdsCore",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [.library(name: "YdsCore", targets: ["YdsCore"])],
    targets: [
        .target(name: "YdsCore", path: "YdsApp", sources: ["Domain", "Data"]),
        .testTarget(name: "YdsCoreTests", dependencies: ["YdsCore"], path: "YdsAppTests")
    ]
)
