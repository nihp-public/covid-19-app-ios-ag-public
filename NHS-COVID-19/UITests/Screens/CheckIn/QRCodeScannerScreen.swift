//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import XCTest

struct QRCodeScannerScreen {

    var app: XCUIApplication

    var screenTitle: XCUIElement {
        app.staticTexts[localized: .checkin_camera_qrcode_scanner_title]
    }

    var helpButton: XCUIElement {
        app.staticTexts[localized: .checkin_camera_qrcode_scanner_help_button_title]
    }

    var statusLabel: XCUIElement {
        app.staticTexts[localized: .qrcoder_scanner_status_requesting_permission]
    }

    var descriptionLabel: XCUIElement {
        app.staticTexts[localized: .checkin_camera_qrcode_scanner_description_label]
    }

}
