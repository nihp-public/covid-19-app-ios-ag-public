//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Integration
import Interface
import Localization
import SwiftUI
import UIKit

public class NavigationButtonComponentScenario: Scenario {

    public static let name = "Navigation Button"
    public static let kind = ScenarioKind.component

    enum Showcases: CaseIterable {
        case checkIn
        case symptoms
        case selfIsolation

        func content() -> NavigationButton {
            switch self {
            case .checkIn:
                return NavigationButton(imageName: .qrCode, foregroundColor: Color(.background), backgroundColor: Color(.stylePurple), text: localize(.home_checkin_button_title)) {}
            case .symptoms:
                return NavigationButton(imageName: .thermometer, foregroundColor: Color(.background), backgroundColor: Color(.styleOrange), text: localize(.home_diagnosis_button_title)) {}
            case .selfIsolation:
                return NavigationButton(imageName: .selfIsolation, foregroundColor: Color(.background), backgroundColor: Color(.styleRed), text: localize(.home_self_isolation_button_title)) {}
            }
        }
    }

    static var appController: AppController {
        BasicAppController(rootViewController: UIHostingController(rootView: NavigationButtonView()))
    }
}

private struct NavigationButtonView: View {

    @State var preferredColourScheme: ColorScheme? = nil

    @SwiftUI.Environment(\.colorScheme) var colorScheme

    fileprivate init() {}

    var body: some View {
        NavigationView {
            List(NavigationButtonComponentScenario.Showcases.allCases, id: \.index) {
                $0.content()
            }
            .navigationBarItems(trailing: toggleColorSchemeButton)
            .navigationBarTitle("NavigationButton")
        }
        .preferredColorScheme(preferredColourScheme)

    }

    private var toggleColorSchemeButton: some View {
        Button(action: self.toggleColorScheme) {
            Image(systemName: colorScheme == .dark ? "moon.circle.fill" : "moon.circle")
                .frame(width: 44, height: 44)
        }
    }

    private func toggleColorScheme() {
        switch colorScheme {
        case .dark:
            preferredColourScheme = .light
        default:
            preferredColourScheme = .dark
        }
    }
}
