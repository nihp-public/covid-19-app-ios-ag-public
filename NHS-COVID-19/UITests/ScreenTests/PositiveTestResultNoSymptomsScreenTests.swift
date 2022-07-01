//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class PositiveTestResultNoIsolationScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<PositiveTestResultNoIsolationScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = PositiveTestResultNoIsolationScreen(app: app)

            XCTAssert(screen.title.exists)
            XCTAssert(screen.indicationLabel.exists)
            XCTAssert(screen.explanationLabel.exists)
            XCTAssert(screen.onlineServicesLink.exists)
            XCTAssert(screen.continueButton.exists)
        }
    }

    func testTapOnlineServices() throws {
        try runner.run { app in
            let screen = PositiveTestResultNoIsolationScreen(app: app)

            screen.onlineServicesLink.tap()
            XCTAssert(screen.onlineServicesLinkAlertTitle.exists)
        }
    }

    func testShareKeys() throws {
        try runner.run { app in
            let screen = PositiveTestResultNoIsolationScreen(app: app)

            screen.continueButton.tap()
            XCTAssert(screen.continueAlertTitle.exists)
        }
    }
}

private extension PositiveTestResultNoIsolationScreen {

    var onlineServicesLinkAlertTitle: XCUIElement {
        app.staticTexts[PositiveTestResultNoIsolationScreenScenario.onlineServicesLinkTapped]
    }

    var continueAlertTitle: XCUIElement {
        app.staticTexts[PositiveTestResultNoIsolationScreenScenario.continueTapped]
    }
}
