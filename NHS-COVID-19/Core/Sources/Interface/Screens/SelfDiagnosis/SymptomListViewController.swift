//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import SwiftUI
import UIKit

public protocol SymptomListViewControllerInteracting {
    func didTapReportButton() -> Result<Void, UIValidationError>
    func didTapNoSymptomsButton()
    func didTapCancel()
}

public class SymptomListViewController: UIViewController {

    public typealias Interacting = SymptomListViewControllerInteracting

    private let interactor: Interacting

    private let symptoms: [SymptomInfo]
    private let indexOfSymptomToScrollToOnAppearance: Int?

    public init(symptoms: [SymptomInfo], scrollToSymptomAt symptomIndex: Int?, interactor: Interacting) {
        self.symptoms = symptoms
        self.interactor = interactor
        indexOfSymptomToScrollToOnAppearance = symptomIndex
        super.init(nibName: nil, bundle: nil)

        title = localize(.diagnosis_questionnaire_title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var errorBox: ErrorBox = {
        ErrorBox(localize(.symptom_list_error_heading), description: localize(.symptom_list_error_description))
    }()

    private lazy var errorBoxVC: UIHostingController<ErrorBox> = {
        UIHostingController(rootView: errorBox)
    }()

    private lazy var scrollView: UIScrollView = {
        UIScrollView()
    }()

    private lazy var symptomStack: UIStackView = {
        UIStackView()
    }()

    override public func viewDidAppear(_ animated: Bool) {
        if let symptomIndex = indexOfSymptomToScrollToOnAppearance {
            DispatchQueue.main.async {
                let yPos = self.symptomStack.frame.origin.y + self.symptomStack.arrangedSubviews[symptomIndex].frame.origin.y - .standardSpacing
                self.scrollView.setContentOffset(CGPoint(x: 0, y: yPos), animated: true)
                UIAccessibility.post(notification: .screenChanged, argument: self.symptomStack.arrangedSubviews[symptomIndex])
            }
        }
    }

    private var symptomCardHeightConstraints = [(UIView, NSLayoutConstraint)]()

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        symptomCardHeightConstraints.forEach { view, constraint in
            view.sizeToFit()
            constraint.constant = view.bounds.height
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.cancel), style: .done, target: self, action: #selector(didTapCancel))

        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)

        let stepLabel = BaseLabel()
        stepLabel.text = localize(.step_label(index: 1, count: 2))
        stepLabel.accessibilityLabel = localize(.step_accessibility_label(index: 1, count: 2))
        stepLabel.textColor = UIColor(.secondaryText)
        stepLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        stepLabel.numberOfLines = 0
        stepLabel.adjustsFontForContentSizeCategory = true

        let heading = BaseLabel()
        heading.text = localize(.symptom_list_heading)
        heading.styleAsPageHeader()

        let description = BaseLabel()
        description.text = localize(.symptom_list_description)
        description.styleAsBody()

        let labelStack = UIStackView(arrangedSubviews: [stepLabel, heading, description])
        labelStack.axis = .vertical
        labelStack.layoutMargins = .standard
        labelStack.isLayoutMarginsRelativeArrangement = true
        labelStack.spacing = .standardSpacing

        symptomStack.axis = .vertical
        symptomStack.spacing = .stripeSpacing
        symptomStack.setContentHuggingPriority(.defaultLow, for: .horizontal)

        for symptom in symptoms {
            let symptomCard = SymptomCard(viewModel: symptom)
            let symptomCardVC = UIHostingController(rootView: symptomCard)
            symptomCardVC.view.backgroundColor = UIColor.clear
            symptomStack.addArrangedSubview(symptomCardVC.view)

            let heightConstraint = symptomCardVC.view.heightAnchor.constraint(equalToConstant: 0)
            heightConstraint.isActive = true
            symptomCardHeightConstraints.append((symptomCardVC.view, heightConstraint))
        }

        let reportButton = UIButton()
        reportButton.styleAsPrimary()
        reportButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        reportButton.setTitle(localize(.symptom_list_primary_action), for: .normal)
        reportButton.addTarget(self, action: #selector(didTapReportButton), for: .touchUpInside)

        let noSymptomsButton = UIButton()
        noSymptomsButton.setTitle(localize(.symptom_list_secondary_action), for: .normal)
        noSymptomsButton.styleAsSecondary()
        noSymptomsButton.addTarget(self, action: #selector(didTapNoSymptomsButton), for: .touchUpInside)

        let buttonStack = UIStackView(arrangedSubviews: [reportButton, noSymptomsButton])
        buttonStack.axis = .vertical
        buttonStack.layoutMargins = .standard
        buttonStack.isLayoutMarginsRelativeArrangement = true
        buttonStack.spacing = .standardSpacing

        errorBoxVC.view.backgroundColor = .clear
        let stack = UIStackView(arrangedSubviews: [errorBoxVC.view, labelStack, symptomStack, buttonStack])
        stack.axis = .vertical
        stack.spacing = .standardSpacing
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .standard

        scrollView.addFillingSubview(stack)
        view.addAutolayoutSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            stack.widthAnchor.constraint(equalTo: view.readableContentGuide.widthAnchor, multiplier: 1),
        ])
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        errorBoxVC.view.isHidden = true
    }

    @objc func didTapReportButton() {
        switch interactor.didTapReportButton() {
        case .success(()):
            break
        case .failure:
            errorBoxVC.view.isHidden = false
            scrollView.setContentOffset(.zero, animated: true)
            UIAccessibility.post(notification: .layoutChanged, argument: errorBoxVC)
        }
    }

    @objc func didTapNoSymptomsButton() {
        let alert = UIAlertController(
            title: localize(.symptom_list_discard_alert_title),
            message: localize(.symptom_list_discard_alert_body),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: localize(.symptom_list_discard_alert_cancel), style: .cancel))
        let discardAction = UIAlertAction(
            title: localize(.symptom_list_discard_alert_discard),
            style: .default,
            handler: { [weak self] _ in
                self?.interactor.didTapNoSymptomsButton()
            }
        )
        alert.addAction(discardAction)
        alert.preferredAction = discardAction

        present(alert, animated: true)
    }

    @objc func didTapCancel() {
        interactor.didTapCancel()
    }
}
