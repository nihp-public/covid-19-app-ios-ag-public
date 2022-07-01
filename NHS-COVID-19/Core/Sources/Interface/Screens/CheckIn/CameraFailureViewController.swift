//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol CameraFailureViewControllerInteracting {
    func goHome()
}

public class CameraFailureViewController: CheckInStatusViewController {

    public typealias Interacting = CameraFailureViewControllerInteracting

    private var interactor: Interacting

    public init(interactor: Interacting) {
        self.interactor = interactor
        super.init(status: CameraFailureErrorDetail(goHome: interactor.goHome))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private struct CameraFailureErrorDetail: StatusDetail {
    let icon = UIImage(.error)
    let title = localize(.checkin_camera_failure_title)
    var explanation: String? = localize(.checkin_camera_failure_description)
    let actionButtonTitle = localize(.checkin_camera_failure_button_title)

    let goHome: () -> Void

    func act() {
        goHome()
    }
}
