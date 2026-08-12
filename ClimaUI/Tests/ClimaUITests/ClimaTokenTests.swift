import XCTest
@testable import ClimaUI

final class ClimaTokenTests: XCTestCase {

    func testSpacingScaleIsMonotonic() {
        XCTAssertLessThan(ClimaSpacing.xs, ClimaSpacing.sm)
        XCTAssertLessThan(ClimaSpacing.sm, ClimaSpacing.md)
        XCTAssertLessThan(ClimaSpacing.md, ClimaSpacing.lg)
        XCTAssertLessThan(ClimaSpacing.lg, ClimaSpacing.xl)
    }

    func testRadiusScaleIsMonotonic() {
        XCTAssertLessThan(ClimaRadius.sm, ClimaRadius.md)
        XCTAssertLessThan(ClimaRadius.md, ClimaRadius.lg)
        XCTAssertLessThan(ClimaRadius.lg, ClimaRadius.xl)
        XCTAssertGreaterThan(ClimaRadius.pill, ClimaRadius.xl)
    }

    func testShadowPresets() {
        XCTAssertEqual(ClimaShadow.card.y, 4)
        XCTAssertEqual(ClimaShadow.subtle.radius, 4)
    }
}
