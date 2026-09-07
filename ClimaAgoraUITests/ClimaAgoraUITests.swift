//
//  ClimaAgoraUITests.swift
//  ClimaAgoraUITests
//
//  Created by Fernando on 17/03/26.
//

import XCTest

final class ClimaAgoraUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testOpenSearchAndClose() throws {
        let app = XCUIApplication()
        app.launch()
        let searchButton = app.buttons["home.search.button"]
        XCTAssertTrue(searchButton.waitForExistence(timeout: 5))
        searchButton.tap()

        let searchField = app.textFields["climaui.textfield.input"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))

        let cancelButton = app.buttons["search.cancel.button"]
        XCTAssertTrue(cancelButton.exists)
        cancelButton.tap()
    }

    @MainActor
    func testOpenSettings() throws {
        let app = XCUIApplication()
        app.launch()
        let settingsButton = app.buttons["home.settings.button"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()
        XCTAssertTrue(app.staticTexts["Configurações"].waitForExistence(timeout: 5))
    }
}
