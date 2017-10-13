// swift-tools-version:4.0
import PackageDescription

let package = Package(
  name: "web",
  products: [
    .library(name: "web", targets: ["web", "web-swift-server"])
  ],
  dependencies: [
    .package(url: "https://github.com/swift-server/http.git", from: Version("0.1.0"))
  ],
  targets: [
    .target(name: "web"),
    .target(name: "web-swift-server", dependencies: ["web", .productItem(name: "HTTP", package: nil)]),

    .testTarget(name: "webTests", dependencies: ["web"]),
    .testTarget(name: "web-swift-serverTests", dependencies: ["web-swift-server"])
  ]
)
