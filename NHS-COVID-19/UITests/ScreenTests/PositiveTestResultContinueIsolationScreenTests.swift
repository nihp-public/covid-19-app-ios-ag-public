//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest
@testable import Scenarios

class PositiveTestResultContinueIsolationScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<PositiveTestResultContinueIsolationScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = PositiveTestResultContinueIsolationScreen(app: app)
            XCTAssert(screen.daysIsolateLabel(daysRemaining: runner.scenario.daysToIsolate).exists)
            XCTAssert(screen.indicationLabel.exists)
            XCTAssert(screen.explanationLabel.allExist)
            XCTAssert(screen.onlineServicesLink.exists)
            XCTAssert(screen.exposureFAQLink.exists)
            XCTAssert(screen.continueButton.exists)
        }
    }
    
    func testTapOnlineServices() throws {
        try runner.run { app in
            let screen = PositiveTestResultContinueIsolationScreen(app: app)
            
            screen.onlineServicesLink.tap()
            XCTAssert(screen.onlineServicesLinkAlertTitle.exists)
        }
    }
    
    func testTapExposureFAQ() throws {
        try runner.run { app in
            let screen = PositiveTestResultContinueIsolationScreen(app: app)
            
            screen.exposureFAQLink.tap()
            XCTAssert(screen.exposureFAQLinkAlertTitle.exists)
        }
    }
    
    func testShareKeys() throws {
        try runner.run { app in
            let screen = PositiveTestResultContinueIsolationScreen(app: app)
            
            screen.continueButton.tap()
            XCTAssert(screen.continueAlertTitle.exists)
        }
    }
}

private extension PositiveTestResultContinueIsolationScreen {
    
    var onlineServicesLinkAlertTitle: XCUIElement {
        app.staticTexts[PositiveTestResultContinueIsolationScreenScenario.onlineServicesLinkTapped]
    }
    
    var exposureFAQLinkAlertTitle: XCUIElement {
        app.staticTexts[PositiveTestResultStartIsolationScreenScenario.exposureFAQLinkTapped]
    }
    
    var continueAlertTitle: XCUIElement {
        app.staticTexts[PositiveTestResultContinueIsolationScreenScenario.primaryButtonTapped]
    }
    
    var noThanksAlertTitle: XCUIElement {
        app.staticTexts[PositiveTestResultContinueIsolationScreenScenario.noThanksLinkTapped]
    }
    
}
