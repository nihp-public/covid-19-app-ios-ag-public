//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class AboutThisAppScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "About this app"

    public static let commonQuestionsTapped = "Common questions tapped"
    public static let termsOfUseTapped = "Terms of use tapped"
    public static let privacyNoticeTapped = "Privacy notice tapped"
    public static let accessibilityStatementTapped = "Accessibility statement tapped"
    public static let seeDataTapped = "See data tapped"
    public static let howThisAppWorksTapped = "How this app works tapped"
    public static let provideFeedbackTapped = "Provide feedback tapped"
    public static let downloadNHSAppTapped = "Download NHS App tapped"

    public static let appName = "NHS-COVID-19"
    public static let version = "1.0"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return AboutThisAppViewController(interactor: interactor, appName: appName, version: version)
        }
    }
}

private class Interactor: AboutThisAppViewController.Interacting {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapCommonQuestions() {
        viewController?.showAlert(title: AboutThisAppScreenScenario.commonQuestionsTapped)
    }

    func didTapTermsOfUse() {
        viewController?.showAlert(title: AboutThisAppScreenScenario.termsOfUseTapped)
    }

    func didTapPrivacyNotice() {
        viewController?.showAlert(title: AboutThisAppScreenScenario.privacyNoticeTapped)
    }

    func didTapAccessibilityStatement() {
        viewController?.showAlert(title: AboutThisAppScreenScenario.accessibilityStatementTapped)
    }

    func didTapSeeData() {
        viewController?.showAlert(title: AboutThisAppScreenScenario.seeDataTapped)
    }

    func didTapHowThisAppWorks() {
        viewController?.showAlert(title: AboutThisAppScreenScenario.howThisAppWorksTapped)
    }

    func didTapProvideFeedback() {
        viewController?.showAlert(title: AboutThisAppScreenScenario.provideFeedbackTapped)
    }

    func didTapDownloadNHSApp() {
        viewController?.showAlert(title: AboutThisAppScreenScenario.downloadNHSAppTapped)
    }
}
