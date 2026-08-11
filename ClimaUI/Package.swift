// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClimaUI",
    platforms: [.iOS(.v16)],
    products: [
        // Biblioteca do Design System (tokens + componentes) — o app consome esta.
        .library(name: "ClimaUI", targets: ["ClimaUI"]),
        // Catálogo navegável (Component Playground) — uma página por componente.
        .library(name: "ClimaUICatalog", targets: ["ClimaUICatalog"]),
    ],
    targets: [
        .target(name: "ClimaUI"),
        .target(name: "ClimaUICatalog", dependencies: ["ClimaUI"]),
        .testTarget(name: "ClimaUITests", dependencies: ["ClimaUI"]),
    ]
)
