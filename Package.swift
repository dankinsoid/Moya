// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Moya",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v3)
    ],
    products: [
        .library(name: "Moya", targets: ["Moya"]),
        .library(name: "CombineMoya", targets: ["CombineMoya"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.0.0")),
				.package(url: "https://github.com/dankinsoid/CombineOperators.git", .upToNextMajor(from: "1.40.0")), // dev
    ],
    targets: [
        .target(name: "Moya", dependencies: ["Alamofire"]),
			.target(name: "CombineMoya", dependencies: ["Moya", "CombineOperators", .product(name: "CombineCocoa", package: "CombineOperators")]),
			.testTarget(name: "MoyaTests", dependencies: ["Moya", "CombineOperators", .product(name: "CombineCocoa", package: "CombineOperators"), "CombineMoya"])
    ]
)

#if canImport(PackageConfig)
import PackageConfig

let config = PackageConfiguration([
    "rocket": [
	"before": [
            "scripts/update_changelog.sh",
            "scripts/update_podspec.sh"
	],
	"after": [
            "rake create_release\\[\"$VERSION\"\\]",
            "scripts/update_docs_website.sh"
	]
    ]
]).write()
#endif
