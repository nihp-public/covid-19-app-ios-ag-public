//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct VenueCheckInInformationScreen {

    var app: XCUIApplication

    var screenTitle: XCUIElement {
        app.staticTexts[localized: .checkin_information_title_new]
    }

    var helpScanningTitle: XCUIElement {
        app.staticTexts[localized: .checkin_information_help_scanning_section_title]
    }

    var helpScanningDescription: XCUIElement {
        app.staticTexts[localized: .checkin_information_help_scanning_section_description]
    }

    var whatsAQRCodeTitle: XCUIElement {
        app.staticTexts[localized: .checkin_information_whats_a_qr_code_section_title]
    }

    var whatsAQRCodeDescription: XCUIElement {
        app.staticTexts[localized: .checkin_information_whats_a_qr_code_section_description]
    }

    var qrCodePosterEnglandHospitalityLabel: XCUIElement {
        app.staticTexts[localized: .qr_code_poster_description_hospitality]
    }

    var qrCodePosterEnglandHospitalityImage: XCUIElement {
        app.images[localized: .qr_code_poster_accessibility_label_hospitality]
    }

    var qrCodePosterEnglandLabel: XCUIElement {
        app.staticTexts[localized: .qr_code_poster_description]
    }

    var qrCodePosterEnglandImage: XCUIElement {
        app.images[localized: .qr_code_poster_accessibility_label]
    }

    var qrCodePosterWalesDescription: XCUIElement {
        app.staticTexts[localized: .qr_code_poster_wales_description]
    }

    var qrCodePosterWalesImage: XCUIElement {
        app.images[localized: .qr_code_poster_wales_accessibility_label]
    }

    var howItWorksTitle: XCUIElement {
        app.staticTexts[localized: .checkin_information_how_it_works_section_title]
    }

    var howItWorksDescription: XCUIElement {
        app.staticTexts[localized: .checkin_information_how_it_works_section_description]
    }

    var cancelButton: XCUIElement {
        app.buttons[localize(.cancel)]
    }

    var dismissAlert: XCUIElement {
        app.staticTexts[VenueCheckInInformationScreenScenario.didTapDismissAlertTitle]
    }
}
