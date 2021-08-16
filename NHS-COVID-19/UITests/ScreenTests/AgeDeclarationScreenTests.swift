//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class AgeDeclarationScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<AgeDeclarationScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = AgeDeclarationScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            XCTAssertTrue(screen.heading.exists)
            XCTAssertTrue(screen.description.exists)
            XCTAssertTrue(screen.question.exists)
            XCTAssertTrue(screen.yesRadioButton(selected: false).exists)
            XCTAssertTrue(screen.noRadioButton(selected: false).exists)
            XCTAssertTrue(screen.continueButton.exists)
            
            XCTAssertFalse(screen.error.exists)
            XCTAssertFalse(screen.yesRadioButton(selected: true).exists)
            XCTAssertFalse(screen.noRadioButton(selected: true).exists)
        }
    }
    
    func testYesButton() throws {
        try runner.run { app in
            let screen = AgeDeclarationScreen(app: app)
            screen.yesRadioButton(selected: false).tap()
            XCTAssertTrue(screen.yesRadioButton(selected: true).exists)
            
            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.yesOptionAlertTitle].exists)
        }
    }
    
    func testNoButton() throws {
        try runner.run { app in
            let screen = AgeDeclarationScreen(app: app)
            screen.noRadioButton(selected: false).tap()
            XCTAssertTrue(screen.noRadioButton(selected: true).exists)
            
            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.noOptionAlertTitle].exists)
        }
    }
    
    func testErrorAppearance() throws {
        try runner.run { app in
            let screen = AgeDeclarationScreen(app: app)
            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssertTrue(screen.error.exists)
        }
    }
    
    func testErrorDisappearance() throws {
        try runner.run { app in
            let screen = AgeDeclarationScreen(app: app)
            screen.continueButton.tap()
            XCTAssertTrue(screen.error.exists)
            
            screen.yesRadioButton(selected: false).tap()
            screen.continueButton.tap()
            XCTAssertFalse(screen.error.exists)
        }
    }
}
